import assert from "node:assert/strict";
import { before, beforeEach, describe, it } from "node:test";
import { initializeApp } from "firebase-admin/app";
import { getFirestore, type Firestore } from "firebase-admin/firestore";
import type { Award } from "../src/awards";
import { grant, revoke } from "../src/ledger";

let db: Firestore;

const filed: Award = { key: "reportFiled:r1", reason: "reportFiled", reportId: "r1" };
const approved: Award = {
  key: "reportApproved:r1",
  reason: "reportApproved",
  reportId: "r1",
};
const other: Award = { key: "reportFiled:r2", reason: "reportFiled", reportId: "r2" };

const xp = async (): Promise<unknown> =>
  (await db.doc("leaderboard/u1").get()).get("xp");

before(() => {
  initializeApp({ projectId: "demo-bugbounty" }, "ledger-test");
});

beforeEach(async () => {
  const { getApp } = await import("firebase-admin/app");
  db = getFirestore(getApp("ledger-test"));
  await db.recursiveDelete(db.collection("users"));
  await db.recursiveDelete(db.collection("leaderboard"));
  await db.doc("leaderboard/u1").set({ name: "U", xp: 0 });
});

describe("ledger", () => {
  it("pays each key once even when triggers retry", async () => {
    await Promise.all([grant(db, "u1", filed), grant(db, "u1", filed)]);
    await grant(db, "u1", filed);
    assert.equal(await xp(), 10);
  });

  it("revokes only the withdrawn report", async () => {
    await grant(db, "u1", filed);
    await grant(db, "u1", approved);
    await grant(db, "u1", other);
    assert.equal(await xp(), 45);
    await revoke(db, "u1", "r1");
    assert.equal(await xp(), 10);
    const left = await db.collection("users/u1/xpEvents").get();
    assert.deepEqual(left.docs.map((doc) => doc.id), ["reportFiled:r2"]);
  });

  it("does nothing when there is nothing to revoke", async () => {
    await revoke(db, "u1", "missing");
    assert.equal(await xp(), 0);
  });
});
