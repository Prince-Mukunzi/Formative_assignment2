import { applicationDefault, initializeApp } from "firebase-admin/app";
import { FieldValue, getFirestore } from "firebase-admin/firestore";

const departments = [
  { id: "facilities", label: "Facilities", categories: ["facilities"] },
  { id: "plumbing", label: "Plumbing", categories: ["water"] },
  { id: "electrical", label: "Electrical", categories: ["electricity"] },
  { id: "furniture", label: "Furniture", categories: ["furniture"] },
  { id: "sanitation", label: "Sanitation", categories: ["sanitation"] },
  { id: "safety", label: "Safety", categories: ["safety"] },
];

const locations = [
  "Block A",
  "Block B",
  "Block C",
  "Dorm A",
  "Dorm B",
  "Dorm C",
  "East Wing",
  "Library",
  "Main Hall",
  "Science Block",
];

async function main(): Promise<void> {
  const [projectId, adminEmail] = process.argv.slice(2);
  if (!projectId || !adminEmail) {
    throw new Error("Usage: npm run seed -- <projectId> <firstAdminEmail>");
  }
  initializeApp({ credential: applicationDefault(), projectId });
  const db = getFirestore();
  const batch = db.batch();
  for (const { id, ...department } of departments) {
    batch.set(db.doc(`departments/${id}`), department);
  }
  batch.set(db.doc("config/locations"), { items: locations });
  batch.set(db.doc(`invites/${adminEmail.toLowerCase()}`), {
    role: "admin",
    invitedBy: "seed",
    createdAt: FieldValue.serverTimestamp(),
  });
  await batch.commit();
}

main().catch((error: unknown) => {
  process.stderr.write(`${String(error)}\n`);
  process.exit(1);
});
