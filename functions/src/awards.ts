import { z } from "zod";
import xp from "./xp.json";

export type XpReason = keyof typeof xp;

export const xpFor = (reason: XpReason): number => xp[reason];

const minDetailLength = 30;

const reportSchema = z.object({
  reportedBy: z.string(),
  status: z.enum(["awaitingApproval", "inProgress", "resolved", "declined"]),
  description: z.string(),
  imageUrl: z.string(),
  nudges: z.number(),
  reopenCount: z.number(),
  verifiedAt: z.unknown(),
  updatedBy: z.string(),
});

export type ReportSnapshot = z.infer<typeof reportSchema>;

export const parseReport = (data: unknown): ReportSnapshot =>
  reportSchema.parse(data);

export interface Award {
  key: string;
  reason: XpReason;
  reportId: string;
}

const utcDay = (at: Date): string => at.toISOString().slice(0, 10);

export function awardsFor(
  reportId: string,
  before: ReportSnapshot | null,
  after: ReportSnapshot,
  now: Date,
): Award[] {
  const award = (reason: XpReason, scope: string = reportId): Award => ({
    key: `${reason}:${scope}`,
    reason,
    reportId,
  });
  const awards: Award[] = [];

  if (before === null) awards.push(award("reportFiled"));
  if (after.imageUrl.length > 0) awards.push(award("photoAdded"));
  if (after.description.length >= minDetailLength) awards.push(award("detailAdded"));
  if (before === null) return awards;

  const reporterActed = after.updatedBy === after.reportedBy;
  if (before.status === "awaitingApproval" && after.status === "inProgress") {
    awards.push(award("reportApproved"));
  }
  if (before.status !== "resolved" && after.status === "resolved") {
    awards.push(award("reportResolved"));
  }
  const confirmedFix = before.verifiedAt == null && after.verifiedAt != null;
  const saidStillBroken =
    before.status === "resolved" && after.status === "inProgress" && reporterActed;
  if (confirmedFix || saidStillBroken) awards.push(award("fixChecked"));
  if (after.nudges > before.nudges) {
    awards.push(award("nudgeSent", `${reportId}:${utcDay(now)}`));
  }
  return awards;
}

export const shouldRevokeOnDelete = (before: ReportSnapshot): boolean =>
  before.status === "awaitingApproval";

// Download URLs carry the object path URL-encoded after /o/.
export function storagePathOf(imageUrl: string): string | null {
  const match = /\/o\/([^?]+)/.exec(imageUrl);
  if (!match?.[1]) return null;
  const path = decodeURIComponent(match[1]);
  return path.startsWith("reports/") ? path : null;
}
