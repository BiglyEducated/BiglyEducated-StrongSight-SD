import express from "express";
import admin from "firebase-admin";
import { readFileSync } from "fs";
import authRoutes from "./routes/authRoutes.js";

const serviceAccount = JSON.parse(readFileSync("./serviceAccountKey.json", "utf8"));
const app = express();
const PORT = process.env.PORT || 5000;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: serviceAccount.project_id,
});

// Firestore instance
const db = admin.firestore();

// ✅ Test connection route (keep it here)
app.get("/test-firebase", async (req, res) => {
  try {
    const collections = await db.listCollections();
    const names = collections.map((c) => c.id);
    res.json({
      message: "✅ Connected to Firestore!",
      project: serviceAccount.project_id,
      collections: names,
    });
  } catch (error) {
    res.status(500).json({
      message: "❌ Failed to connect to Firestore",
      code: error.code,
      details: error.details,
    });
  }
});

// ✅ Use Auth Routes
app.use("/api/auth", authRoutes);

app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

