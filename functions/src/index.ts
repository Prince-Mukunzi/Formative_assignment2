import { initializeApp } from "firebase-admin/app";
import { FieldValue, getFirestore, type Firestore } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import { setGlobalOptions } from "firebase-functions/v2";
import { logger } from "firebase-functions";
import {
  onDocumentCreated,
  onDocumentWritten,
} from "firebase-functions/v2/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { z } from "zod";
import {
  awardsFor,
  parseReport,
  shouldRevokeOnDelete,
  storagePathOf,
} from "./awards";
import { grant, revoke } from "./ledger";
import { decideProvision, inviteSchema } from "./provision";

initializeApp();
setGlobalOptions({ region: "us-central1", maxInstances: 10 });

const db = (): Firestore => getFirestore();

const provisionInput = z.object({
  name: z.string().trim().min(1).max(80).optional(),
});

export const provisionAccount = onCall(async (request) => {
  const token = request.auth?.token;
  const uid = request.auth?.uid;
  if (!token || !uid) {
    throw new HttpsError("unauthenticated", "Sign in first.");
  }
  const email = token.email?.toLowerCase();
  if (!email || token.email_verified !== true) {
    throw new HttpsError("failed-precondition", "Verify your email first.");
  }
  const input = provisionInput.safeParse(request.data ?? {});
  if (!input.success) {
    throw new HttpsError("invalid-argument", "Name is invalid.");
  }
  const name = input.data.name ?? token.name ?? email.split("@")[0] ?? "Member";

  const userRef = db().doc(`users/${uid}`);
  const inviteRef = db().doc(`invites/${email}`);
  const leaderboardRef = db().doc(`leaderboard/${uid}`);

  return db().runTransaction(async (tx) => {
    const existing = await tx.get(userRef);
    if (existing.exists) return { role: existing.get("role") as string };

    const inviteDoc = await tx.get(inviteRef);
    const invite = inviteDoc.exists ? inviteSchema.parse(inviteDoc.data()) : null;
    const decision = decideProvision(email, invite);
    if (decision.kind === "refused") {
      throw new HttpsError("permission-denied", "This email has no access.");
    }

    tx.set(userRef, {
      name,
      email,
      role: decision.role,
      departmentId: decision.departmentId,
      suspended: false,
      celebrated: [],
      createdAt: FieldValue.serverTimestamp(),
    });
    if (invite) tx.delete(inviteRef);
    if (decision.role === "student") tx.set(leaderboardRef, { name, xp: 0 });
    return { role: decision.role };
  });
});

export const onInviteCreated = onDocumentCreated(
  "invites/{email}",
  async (event) => {
    const invite = inviteSchema.parse(event.data?.data());
    const email = event.params.email;
    const matches = await db()
      .collection("users")
      .where("email", "==", email)
      .limit(1)
      .get();
    const user = matches.docs[0];
    if (!user) return;

    const batch = db().batch();
    batch.update(user.ref, {
      role: invite.role,
      departmentId: invite.role === "faculty" ? invite.departmentId : null,
    });
    batch.delete(db().doc(`leaderboard/${user.id}`));
    batch.delete(db().doc(`invites/${email}`));
    await batch.commit();
  },
);

async function deleteImage(imageUrl: string): Promise<void> {
  const path = storagePathOf(imageUrl);
  if (!path) return;
  await getStorage().bucket().file(path).delete({ ignoreNotFound: true });
}

export const onReportWritten = onDocumentWritten(
  "reports/{reportId}",
  async (event) => {
    const reportId = event.params.reportId;
    const beforeData = event.data?.before.data();
    const afterData = event.data?.after.data();
    const before = beforeData ? parseReport(beforeData) : null;

    if (!afterData) {
      if (!before) return;
      if (shouldRevokeOnDelete(before)) await revoke(db(), before.reportedBy, reportId);
      await deleteImage(before.imageUrl);
      await db().recursiveDelete(db().doc(`reports/${reportId}`));
      return;
    }

    const after = parseReport(afterData);
    if (before && before.imageUrl !== after.imageUrl) {
      await deleteImage(before.imageUrl);
    }
    const awards = awardsFor(reportId, before, after, new Date(event.time));
    for (const award of awards) await grant(db(), after.reportedBy, award);
    logger.debug("report processed", { reportId, awards: awards.length });
  },
);

export const onUpvoteCreated = onDocumentCreated(
  "reports/{reportId}/upvotes/{uid}",
  async (event) => {
    const { reportId, uid } = event.params;
    await grant(db(), uid, {
      key: `upvoteGiven:${reportId}`,
      reason: "upvoteGiven",
      reportId,
    });
  },
);
