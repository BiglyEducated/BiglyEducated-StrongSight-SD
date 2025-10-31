// backend/config/firebase.js
import admin from "firebase-admin";
import { readFileSync } from "fs";

const serviceAccount = JSON.parse(
  readFileSync("./serviceAccountKey.json", "utf8")
);

// ✅ Initialize only once
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: serviceAccount.project_id,
  });
}

export const db = admin.firestore();
export const auth = admin.auth();
export default admin;
