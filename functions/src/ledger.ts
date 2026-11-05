import { FieldValue, type Firestore } from "firebase-admin/firestore";
import { xpFor, type Award, type XpReason } from "./awards";

export async function grant(db: Firestore, uid: string, award: Award): Promise<void> {
  const eventRef = db.doc(`users/${uid}/xpEvents/${award.key}`);
  const leaderboardRef = db.doc(`leaderboard/${uid}`);
  await db.runTransaction(async (tx) => {
    const event = await tx.get(eventRef);
    if (event.exists) return;
    tx.set(eventRef, {
      reason: award.reason,
      reportId: award.reportId,
      at: FieldValue.serverTimestamp(),
      seen: false,
    });
    tx.set(
      leaderboardRef,
      { xp: FieldValue.increment(xpFor(award.reason)) },
      { merge: true },
    );
  });
}

export async function revoke(db: Firestore, uid: string, reportId: string): Promise<void> {
  const events = await db
    .collection(`users/${uid}/xpEvents`)
    .where("reportId", "==", reportId)
    .get();
  if (events.empty) return;
  const total = events.docs.reduce(
    (sum, event) => sum + xpFor(event.get("reason") as XpReason),
    0,
  );
  const batch = db.batch();
  for (const event of events.docs) batch.delete(event.ref);
  batch.set(
    db.doc(`leaderboard/${uid}`),
    { xp: FieldValue.increment(-total) },
    { merge: true },
  );
  await batch.commit();
}
