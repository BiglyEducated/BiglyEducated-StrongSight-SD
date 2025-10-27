import express from 'express';
import admin from 'firebase-admin';
import { readFileSync } from "fs";
const serviceAccount = JSON.parse(readFileSync("./serviceAccountKey.json", "utf8"));
import { getAuth } from "firebase-admin/auth";

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
const PORT = process.env.PORT || 5000;

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: serviceAccount.project_id,
});

const db = admin.firestore();

app.get('/test-firebase', async (req, res) => {
  try {
    const collections = await db.listCollections();
    const names = collections.map(c => c.id);
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


app.post('/signup', async (req, res) => {
  const { email, password, displayName } = req.body;

  getAuth()
    .createUser({
      email: email,
      emailVerified: false,
      password: password,
      displayName: displayName,
      disabled: false,
    })
    .then((userRecord) => {
      console.log('Successfully created new user:', userRecord.uid);
      res.status(201).json({
        message: 'User created successfully',
        uid: userRecord.uid,
        email: userRecord.email,
      });
    })
    .catch((error) => {
      console.log('Error creating new user:', error);
      res.status(500).json({ error: error.message });
    });
});


app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
