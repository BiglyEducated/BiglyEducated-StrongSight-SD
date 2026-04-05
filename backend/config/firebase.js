// backend/config/firebase.js
import admin from "firebase-admin";
import { readFileSync } from "fs";

// Support both local file and environment variable (for Render deployment)
const serviceAccount = process.env.SERVICE_ACCOUNT_JSON
  ? JSON.parse(process.env.SERVICE_ACCOUNT_JSON)
  : JSON.parse(readFileSync("./serviceAccountKey.json", "utf8"));

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
