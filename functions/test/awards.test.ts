import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  awardsFor,
  shouldRevokeOnDelete,
  storagePathOf,
  type ReportSnapshot,
} from "../src/awards";

const now = new Date("2026-11-05T10:00:00Z");
const base: ReportSnapshot = {
  reportedBy: "student",
  status: "awaitingApproval",
  description: "short",
  imageUrl: "",
  nudges: 0,
  reopenCount: 0,
  verifiedAt: null,
  updatedBy: "student",
};
const keys = (before: ReportSnapshot | null, after: ReportSnapshot): string[] =>
  awardsFor("r1", before, after, now).map((award) => award.key);

describe("awardsFor", () => {
  it("pays filing only for a bare report", () => {
    assert.deepEqual(keys(null, base), ["reportFiled:r1"]);
  });

  it("pays evidence on creation", () => {
    const after = { ...base, imageUrl: "http://x", description: "x".repeat(30) };
    assert.deepEqual(keys(null, after), [
      "reportFiled:r1",
      "photoAdded:r1",
      "detailAdded:r1",
    ]);
  });

  it("pays approval and resolution", () => {
    const active = { ...base, status: "inProgress" as const, updatedBy: "staff" };
    assert.deepEqual(keys(base, active), ["reportApproved:r1"]);
    assert.deepEqual(keys(active, { ...active, status: "resolved" }), [
      "reportResolved:r1",
    ]);
  });

  it("pays no approval when reopening a declined report", () => {
    const declined = { ...base, status: "declined" as const };
    const reopened = { ...declined, status: "inProgress" as const, updatedBy: "staff" };
    assert.deepEqual(keys(declined, reopened), []);
  });

  it("pays the reporter for still broken but not a staff reopen", () => {
    const resolved = { ...base, status: "resolved" as const };
    const active = { ...resolved, status: "inProgress" as const, reopenCount: 1 };
    assert.deepEqual(keys(resolved, active), ["fixChecked:r1"]);
    assert.deepEqual(keys(resolved, { ...active, updatedBy: "staff" }), []);
  });

  it("pays a confirmed fix", () => {
    const resolved = { ...base, status: "resolved" as const };
    assert.deepEqual(keys(resolved, { ...resolved, verifiedAt: now }), [
      "fixChecked:r1",
    ]);
  });

  it("scopes nudges to the UTC day", () => {
    assert.deepEqual(keys(base, { ...base, nudges: 1 }), [
      "nudgeSent:r1:2026-11-05",
    ]);
  });
});

describe("shouldRevokeOnDelete", () => {
  it("only revokes while awaiting approval", () => {
    assert.equal(shouldRevokeOnDelete(base), true);
    assert.equal(shouldRevokeOnDelete({ ...base, status: "resolved" }), false);
  });
});

describe("storagePathOf", () => {
  it("decodes report paths", () => {
    const url =
      "https://firebasestorage.googleapis.com/v0/b/x/o/reports%2Fu%2Fr%2Fa.jpg?alt=media";
    assert.equal(storagePathOf(url), "reports/u/r/a.jpg");
  });

  it("ignores anything else", () => {
    assert.equal(storagePathOf("https://example.com/a.jpg"), null);
    assert.equal(storagePathOf(""), null);
  });
});
