import { getAuth } from "firebase-admin/auth";
import admin from "firebase-admin";
import { auth, db } from "../config/firebase.js";

export const signupUser = async (req, res) => {
  const {
    uid,
    email,
    displayName,
    phoneNumber,
    gender,
    weight,
    heightFt,
    heightIn,
  } = req.body;

  try {
    // Store user data in Firestore (Firebase user already created on frontend)
    await db.collection("users").doc(uid).set({
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
      message: "User data stored successfully",
      uid: uid,
      email: email,
    });
  } catch (error) {
    console.log("❌ Error storing user data:", error);
    res.status(500).json({ error: error.message });
  }
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

/**
 * DELETE /delete-user
 * Deletes a user from Firebase Authentication
 */
export const deleteUser = async (req, res) => {
  try {
    // Get the token from headers (Authorization: Bearer <token>)
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({ error: "Missing or invalid token" });
    }

    const idToken = authHeader.split("Bearer ")[1];
    const decodedToken = await getAuth().verifyIdToken(idToken);

    // Delete the user from Firebase Authentication
    await getAuth().deleteUser(decodedToken.uid);

    // Optionally: also remove from Firestore if you have a user profile there
    await db.collection("users").doc(decodedToken.uid).delete();

    return res.status(200).json({ message: `User ${decodedToken.uid} deleted successfully.` });
  } catch (error) {
    console.error("❌ Error deleting user:", error);
    return res.status(500).json({ error: error.message });
  }
};

/**
 * GET USER INFO
 * Fetches user information from Firebase 
 */ 
export const getUserInfo = async (req, res) => {
  try {
    // Extract token from header
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({ error: "Missing or invalid token" });
    }

    const idToken = authHeader.split("Bearer ")[1];

    // Verify token and extract UID
    const decodedToken = await getAuth().verifyIdToken(idToken);
    const uid = decodedToken.uid;

    // Fetch user info from Firestore
    const userDoc = await db.collection("users").doc(uid).get();

    if (!userDoc.exists) {
      return res.status(404).json({ error: "User not found in Firestore" });
    }

    //Return data
    return res.status(200).json({
      message: "User data fetched successfully",
      data: userDoc.data(),
    });
  } catch (error) {
    console.error("Error fetching user info:", error);
    return res.status(500).json({ error: error.message });
  }
};

