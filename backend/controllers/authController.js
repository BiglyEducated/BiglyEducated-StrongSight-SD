import { getAuth } from "firebase-admin/auth";
import admin from "firebase-admin";
import { auth, db } from "../config/firebase.js";

export const signupUser = async (req, res) => {
  const {
    email,
    password,
    displayName,
    phoneNumber,
    gender,
    weight,
    heightFt,
    heightIn,
  } = req.body;

  getAuth()
    .createUser({
      email: email,
      emailVerified: false,
      password: password,
      displayName: displayName,
      phoneNumber: phoneNumber,
      disabled: false,
    })
    .then(async (userRecord) => {
      console.log("✅ Successfully created new user:", userRecord.uid);

      // ✅ Create a Firestore user document with additional data
      await db.collection("users").doc(userRecord.uid).set({
        email,
        displayName,
        phoneNumber,
        gender,
        weight,
        heightFt,
        heightIn,
        createdAt: new Date(),
      });

      res.status(201).json({
        message: "User created successfully",
        uid: userRecord.uid,
        email: userRecord.email,
      });
    })
    .catch((error) => {
      console.log("❌ Error creating new user:", error);
      res.status(500).json({ error: error.message });
    });
};

// 🧩 Log-out Controller (placeholder for now)
export const logoutUser = async (req, res) => {
  try {
    // Normally, logout is handled client-side by deleting the user's token.
    // You could revoke tokens here if needed:
    // await getAuth().revokeRefreshTokens(uid);
    res.status(200).json({ message: "Logout endpoint placeholder" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

/**
 * Verify a Firebase ID token sent from the frontend.
 * Expects header: Authorization: Bearer <token>
 */
export const verifyToken = async (req, res) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ error: "No token provided" });
  }

  const idToken = authHeader.split(" ")[1];

  try {
    // ✅ Ask Firebase Admin SDK to verify and decode the token
    const decodedToken = await getAuth().verifyIdToken(idToken);

    // You can now access decodedToken.uid, decodedToken.email, etc.
    return res.status(200).json({
      message: "Token verified successfully",
      uid: decodedToken.uid,
      email: decodedToken.email,
    });
  } catch (error) {
    console.error("Token verification failed:", error);
    return res.status(401).json({ error: "Invalid or expired token" });
  }
};

