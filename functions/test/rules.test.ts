import { readFileSync } from "node:fs";
import { after, before, beforeEach, describe, it } from "node:test";
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  type RulesTestEnvironment,
} from "@firebase/rules-unit-testing";
import {
  deleteDoc,
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
  updateDoc,
  writeBatch,
  type Firestore,
} from "firebase/firestore";

let env: RulesTestEnvironment;

const asUser = (uid: string, email = `${uid}@alustudent.com`): Firestore =>
  env
    .authenticatedContext(uid, { email, email_verified: true })
    .firestore() as unknown as Firestore;

const report = (overrides: Record<string, unknown> = {}) => ({
  title: "Broken sink",
  description: "It leaks",
  imageUrl: "",
  status: "awaitingApproval",
  category: "water",
  upvotes: 0,
  location: "Block A",
  reportedBy: "student",
  reportedByName: "Student",
  createdAt: new Date(0),
  approvedAt: null,
  resolvedAt: null,
  verifiedAt: null,
  lastNudgedAt: null,
  nudges: 0,
  reopenCount: 0,
  assignedDepartmentId: null,
  updatedBy: "student",
  ...overrides,
});

const seedReport = (overrides: Record<string, unknown> = {}) =>
  env.withSecurityRulesDisabled(async (context) => {
    await setDoc(
      doc(context.firestore() as unknown as Firestore, "reports/r1"),
      report(overrides),
    );
  });

before(async () => {
  env = await initializeTestEnvironment({
    projectId: "demo-bugbounty",
    firestore: { rules: readFileSync("../firestore.rules", "utf8") },
  });
});

after(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore() as unknown as Firestore;
    const user = (role: string, departmentId: string | null, suspended = false) => ({
      name: "Student",
      email: "x@alustudent.com",
      role,
      departmentId,
      suspended,
      celebrated: [],
    });
    await setDoc(doc(db, "users/student"), user("student", null));
    await setDoc(doc(db, "users/other"), user("student", null));
    await setDoc(doc(db, "users/banned"), user("student", null, true));
    await setDoc(doc(db, "users/plumber"), user("faculty", "plumbing"));
    await setDoc(doc(db, "users/electrician"), user("faculty", "electrical"));
    await setDoc(doc(db, "users/admin"), user("admin", null));
    await setDoc(doc(db, "departments/plumbing"), {
      label: "Plumbing",
      categories: ["water"],
    });
    await setDoc(doc(db, "departments/electrical"), {
      label: "Electrical",
      categories: ["electricity"],
    });
    await setDoc(doc(db, "users/student/xpEvents/reportFiled:r1"), {
      reason: "reportFiled",
      reportId: "r1",
      seen: false,
    });
    await setDoc(doc(db, "leaderboard/student"), { name: "Student", xp: 10 });
  });
});

describe("profiles", () => {
  it("blocks self promotion", async () => {
    const db = asUser("student");
    await assertFails(updateDoc(doc(db, "users/student"), { role: "admin" }));
    await assertFails(
      updateDoc(doc(asUser("banned"), "users/banned"), { suspended: false }),
    );
    await assertFails(
      setDoc(doc(db, "users/newcomer"), { role: "admin", suspended: false }),
    );
  });

  it("lets a user rename themselves", async () => {
    await assertSucceeds(
      updateDoc(doc(asUser("student"), "users/student"), { name: "New" }),
    );
  });

  it("keeps profiles private from peers", async () => {
    await assertFails(getDoc(doc(asUser("other"), "users/student")));
    await assertSucceeds(getDoc(doc(asUser("admin"), "users/student")));
  });

  it("lets admins suspend others but not themselves", async () => {
    const db = asUser("admin");
    await assertSucceeds(updateDoc(doc(db, "users/student"), { suspended: true }));
    await assertFails(updateDoc(doc(db, "users/admin"), { suspended: true }));
    await assertFails(updateDoc(doc(db, "users/student"), { role: "admin" }));
  });

  it("lets a suspended user read only their own profile", async () => {
    const db = asUser("banned");
    await assertSucceeds(getDoc(doc(db, "users/banned")));
    await assertFails(getDoc(doc(db, "reports/r1")));
    await assertFails(updateDoc(doc(db, "users/banned"), { name: "Back" }));
  });
});

describe("xp", () => {
  it("cannot be written by clients", async () => {
    const db = asUser("student");
    await assertFails(
      setDoc(doc(db, "users/student/xpEvents/fake"), { reason: "reportFiled" }),
    );
    await assertFails(setDoc(doc(db, "leaderboard/student"), { xp: 99999 }));
    await assertFails(
      updateDoc(doc(db, "users/student/xpEvents/reportFiled:r1"), {
        reason: "reportResolved",
      }),
    );
  });

  it("can be marked seen by its owner", async () => {
    await assertSucceeds(
      updateDoc(doc(asUser("student"), "users/student/xpEvents/reportFiled:r1"), {
        seen: true,
      }),
    );
    await assertFails(
      updateDoc(doc(asUser("other"), "users/student/xpEvents/reportFiled:r1"), {
        seen: true,
      }),
    );
  });
});

describe("invites", () => {
  const invite = { role: "faculty", departmentId: "plumbing" };

  it("can only be created by admins", async () => {
    await assertFails(
      setDoc(doc(asUser("student"), "invites/a@b.com"), {
        ...invite,
        invitedBy: "student",
        createdAt: serverTimestamp(),
      }),
    );
    await assertSucceeds(
      setDoc(doc(asUser("admin"), "invites/a@b.com"), {
        ...invite,
        invitedBy: "admin",
        createdAt: serverTimestamp(),
      }),
    );
  });

  it("requires a real team for faculty", async () => {
    await assertFails(
      setDoc(doc(asUser("admin"), "invites/a@b.com"), {
        role: "faculty",
        departmentId: "ghost",
        invitedBy: "admin",
        createdAt: serverTimestamp(),
      }),
    );
  });
});

describe("reports", () => {
  const newReport = () =>
    report({ createdAt: serverTimestamp() });

  it("lets students file their own", async () => {
    await assertSucceeds(setDoc(doc(asUser("student"), "reports/r2"), newReport()));
  });

  it("rejects forged reports", async () => {
    const db = asUser("student");
    await assertFails(
      setDoc(doc(db, "reports/r2"), { ...newReport(), reportedBy: "other" }),
    );
    await assertFails(
      setDoc(doc(db, "reports/r2"), { ...newReport(), status: "resolved" }),
    );
    await assertFails(setDoc(doc(db, "reports/r2"), { ...newReport(), upvotes: 50 }));
    await assertFails(
      setDoc(doc(asUser("plumber"), "reports/r2"), {
        ...newReport(),
        reportedBy: "plumber",
        updatedBy: "plumber",
      }),
    );
    await assertFails(setDoc(doc(asUser("banned"), "reports/r2"), newReport()));
  });

  it("limits reporter edits to pending reports", async () => {
    await seedReport();
    await assertSucceeds(
      updateDoc(doc(asUser("student"), "reports/r1"), {
        title: "New",
        updatedBy: "student",
      }),
    );
    await assertFails(
      updateDoc(doc(asUser("other"), "reports/r1"), {
        title: "Hack",
        updatedBy: "other",
      }),
    );
    await seedReport({ status: "inProgress" });
    await assertFails(
      updateDoc(doc(asUser("student"), "reports/r1"), {
        title: "New",
        updatedBy: "student",
      }),
    );
  });

  it("stops students approving their own report", async () => {
    await seedReport();
    await assertFails(
      updateDoc(doc(asUser("student"), "reports/r1"), {
        status: "inProgress",
        approvedAt: serverTimestamp(),
        updatedBy: "student",
      }),
    );
  });

  it("lets only the owning team triage", async () => {
    await seedReport();
    const approve = (uid: string) => ({
      status: "inProgress",
      approvedAt: serverTimestamp(),
      updatedBy: uid,
    });
    await assertFails(
      updateDoc(doc(asUser("electrician"), "reports/r1"), approve("electrician")),
    );
    await assertSucceeds(
      updateDoc(doc(asUser("plumber"), "reports/r1"), approve("plumber")),
    );
  });

  it("follows reassignment over category", async () => {
    await seedReport({ assignedDepartmentId: "electrical" });
    const decline = (uid: string) => ({ status: "declined", updatedBy: uid });
    await assertFails(
      updateDoc(doc(asUser("plumber"), "reports/r1"), decline("plumber")),
    );
    await assertSucceeds(
      updateDoc(doc(asUser("electrician"), "reports/r1"), decline("electrician")),
    );
  });

  it("requires updatedBy to be the caller", async () => {
    await seedReport();
    await assertFails(
      updateDoc(doc(asUser("plumber"), "reports/r1"), {
        status: "declined",
        updatedBy: "student",
      }),
    );
  });

  it("enforces the nudge cooldown", async () => {
    await seedReport();
    const nudge = {
      nudges: 1,
      lastNudgedAt: serverTimestamp(),
      updatedBy: "student",
    };
    await assertSucceeds(updateDoc(doc(asUser("student"), "reports/r1"), nudge));
    await assertFails(
      updateDoc(doc(asUser("student"), "reports/r1"), { ...nudge, nudges: 2 }),
    );
  });

  it("couples upvotes to an upvote doc", async () => {
    await seedReport();
    const db = asUser("other");
    await assertFails(
      updateDoc(doc(db, "reports/r1"), { upvotes: 1, updatedBy: "other" }),
    );
    const up = writeBatch(db);
    up.update(doc(db, "reports/r1"), { upvotes: 1, updatedBy: "other" });
    up.set(doc(db, "reports/r1/upvotes/other"), {
      uid: "other",
      createdAt: serverTimestamp(),
    });
    await assertSucceeds(up.commit());

    const again = writeBatch(db);
    again.update(doc(db, "reports/r1"), { upvotes: 2, updatedBy: "other" });
    again.set(doc(db, "reports/r1/upvotes/other"), {
      uid: "other",
      createdAt: serverTimestamp(),
    });
    await assertFails(again.commit());

    const down = writeBatch(db);
    down.update(doc(db, "reports/r1"), { upvotes: 0, updatedBy: "other" });
    down.delete(doc(db, "reports/r1/upvotes/other"));
    await assertSucceeds(down.commit());
  });

  it("lets the reporter settle a resolved report", async () => {
    await seedReport({ status: "resolved", resolvedAt: new Date(0) });
    await assertSucceeds(
      updateDoc(doc(asUser("student"), "reports/r1"), {
        verifiedAt: serverTimestamp(),
        updatedBy: "student",
      }),
    );
    await seedReport({ status: "resolved", resolvedAt: new Date(0) });
    await assertSucceeds(
      updateDoc(doc(asUser("student"), "reports/r1"), {
        status: "inProgress",
        approvedAt: serverTimestamp(),
        resolvedAt: null,
        verifiedAt: null,
        reopenCount: 1,
        updatedBy: "student",
      }),
    );
  });

  it("lets staff run the whole lifecycle", async () => {
    const db = asUser("admin");
    await seedReport({ status: "inProgress" });
    await assertSucceeds(
      updateDoc(doc(db, "reports/r1"), {
        status: "resolved",
        resolvedAt: serverTimestamp(),
        updatedBy: "admin",
      }),
    );
    await assertSucceeds(
      updateDoc(doc(db, "reports/r1"), {
        status: "inProgress",
        approvedAt: serverTimestamp(),
        resolvedAt: null,
        verifiedAt: null,
        reopenCount: 1,
        updatedBy: "admin",
      }),
    );
    await assertSucceeds(
      updateDoc(doc(db, "reports/r1"), {
        assignedDepartmentId: "electrical",
        updatedBy: "admin",
      }),
    );
    await assertSucceeds(
      updateDoc(doc(asUser("electrician"), "reports/r1"), {
        assignedDepartmentId: "plumbing",
        updatedBy: "electrician",
      }),
    );
  });

  it("limits deletion", async () => {
    await seedReport({ status: "inProgress" });
    await assertFails(deleteDoc(doc(asUser("student"), "reports/r1")));
    await assertFails(deleteDoc(doc(asUser("plumber"), "reports/r1")));
    await assertSucceeds(deleteDoc(doc(asUser("admin"), "reports/r1")));
    await seedReport();
    await assertSucceeds(deleteDoc(doc(asUser("student"), "reports/r1")));
  });
});
