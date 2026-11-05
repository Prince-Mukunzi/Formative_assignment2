import { z } from "zod";

export const studentDomain = "@alustudent.com";

export const inviteSchema = z.discriminatedUnion("role", [
  z.object({ role: z.literal("admin") }),
  z.object({ role: z.literal("faculty"), departmentId: z.string() }),
]);

export type Invite = z.infer<typeof inviteSchema>;

export type Provision =
  | { kind: "granted"; role: "student" | "faculty" | "admin"; departmentId: string | null }
  | { kind: "refused" };

export function decideProvision(email: string, invite: Invite | null): Provision {
  if (invite?.role === "admin") {
    return { kind: "granted", role: "admin", departmentId: null };
  }
  if (invite?.role === "faculty") {
    return { kind: "granted", role: "faculty", departmentId: invite.departmentId };
  }
  return email.endsWith(studentDomain)
    ? { kind: "granted", role: "student", departmentId: null }
    : { kind: "refused" };
}
