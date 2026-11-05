import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { decideProvision } from "../src/provision";

describe("decideProvision", () => {
  it("makes a student from the ALU domain", () => {
    assert.deepEqual(decideProvision("a@alustudent.com", null), {
      kind: "granted",
      role: "student",
      departmentId: null,
    });
  });

  it("refuses any other domain", () => {
    assert.deepEqual(decideProvision("a@gmail.com", null), { kind: "refused" });
    assert.deepEqual(decideProvision("a@alustudent.com.evil.io", null), {
      kind: "refused",
    });
    assert.deepEqual(decideProvision("a@notalustudent.com", null), {
      kind: "refused",
    });
  });

  it("gives faculty the invited team on any domain", () => {
    assert.deepEqual(
      decideProvision("a@gmail.com", { role: "faculty", departmentId: "plumbing" }),
      { kind: "granted", role: "faculty", departmentId: "plumbing" },
    );
  });

  it("lets an invite outrank the student domain", () => {
    assert.deepEqual(decideProvision("a@alustudent.com", { role: "admin" }), {
      kind: "granted",
      role: "admin",
      departmentId: null,
    });
  });
});
