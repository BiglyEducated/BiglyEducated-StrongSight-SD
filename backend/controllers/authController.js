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
    age,
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
      age,
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

export const editUserInfo = async (req, res) => {
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

    // Extract fields from request body
    const { displayName, email, phoneNumber, heightFt, heightIn, weight, age } = req.body;

    // Build update object with only provided fields
    const updateData = {};
    if (displayName !== undefined) updateData.displayName = displayName;
    if (email !== undefined) updateData.email = email;
    if (phoneNumber !== undefined) updateData.phoneNumber = phoneNumber;
    if (heightFt !== undefined) updateData.heightFt = heightFt;
    if (heightIn !== undefined) updateData.heightIn = heightIn;
    if (weight !== undefined) updateData.weight = weight;
    if (age !== undefined) updateData.age = age;

    // Add updatedAt timestamp
    updateData.updatedAt = new Date();

    // Check if there's anything to update
    if (Object.keys(updateData).length === 1) { // Only updatedAt
      return res.status(400).json({ error: "No fields provided to update" });
    }

    // Check if user exists
    const userDoc = await db.collection("users").doc(uid).get();
    if (!userDoc.exists) {
      return res.status(404).json({ error: "User not found in Firestore" });
    }

    // Update user document in Firestore
    await db.collection("users").doc(uid).update(updateData);

    // Return updated data
    return res.status(200).json({
      message: "User info updated successfully",
      data: updateData,
    });
  } catch (error) {
    console.error("Error updating user info:", error);
    return res.status(500).json({ error: error.message });
  }
}

export const getUserWorkouts = async (req, res) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({ error: "Missing or invalid token" });
    }

    const idToken = authHeader.split("Bearer ")[1];
    const decodedToken = await getAuth().verifyIdToken(idToken);
    const uid = decodedToken.uid;

    const snapshot = await db
      .collection("workouts_completed")
      .where("uid", "==", uid)
      .get();

    if (snapshot.empty) {
      return res.status(200).json({
        message: "No workouts found for this user",
        data: {},
      });
    }

    // Transform workouts into Map format with date as key
    const workoutsByDate = {};

    snapshot.docs.forEach(doc => {
      const data = doc.data();
      
      // Convert Firestore Timestamp to ISO date string (YYYY-MM-DD)
      let dateString;
      if (data.date?.toDate) {
        // Firestore Timestamp
        dateString = data.date.toDate().toISOString().split('T')[0];
      } else if (typeof data.date === 'string') {
        // Already a string
        dateString = data.date.split('T')[0];
      } else {
        // Fallback to today
        dateString = new Date().toISOString().split('T')[0];
      }

      // Build the workout object in the new format
      workoutsByDate[dateString] = {
        id: doc.id,
        workoutName: data.workoutName || data.title || "Untitled",
        date: dateString,
        exercises: (data.exercises || []).map(ex => ({
          name: ex.name,
          equipment: {
            id: ex.equipment?.id || "unknown",
            name: ex.equipment?.name || "Unknown",
          },
          sets: (ex.sets || []).map(set => ({
            reps: set.reps || 0,
            weight: set.weight || 0,
          })),
        })),
      };
    });

    return res.status(200).json({
      message: "User workouts fetched successfully",
      data: workoutsByDate,
    });
  } catch (error) {
    console.error("Error fetching user workouts:", error);
    return res.status(500).json({ error: error.message });
  }
};

/**
 * GET USER WORKOUTS BY DATE RANGE
 * Expects query params: start (ISO string), end (ISO string)
 * Returns workouts for the user within the date range (inclusive)
 */
export const getUserWorkoutsByDate = async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({ error: "Missing or invalid token" });
    }

    const idToken = authHeader.split("Bearer ")[1];
    const decodedToken = await getAuth().verifyIdToken(idToken);
    const uid = decodedToken.uid;

    // Parse date range from query params
    const { start, end } = req.query;
    if (!start || !end) {
      return res.status(400).json({ error: "Missing start or end date" });
    }
    const startDate = new Date(start);
    const endDate = new Date(end);

    // Query workouts_completed for this user and date range
    const workoutsSnapshot = await db
      .collection("workouts_completed")
      .where("uid", "==", uid)
      .where("date", ">=", startDate)
      .where("date", "<=", endDate)
      .get();

    if (workoutsSnapshot.empty) {
      return res.status(200).json({
        message: "No workouts found for this user in the date range",
        data: {},
      });
    }

    // Transform workouts into Map format with date as key
    const workoutsByDate = {};

    workoutsSnapshot.docs.forEach(doc => {
      const data = doc.data();
      
      // Convert Firestore Timestamp to ISO date string (YYYY-MM-DD)
      let dateString;
      if (data.date?.toDate) {
        // Firestore Timestamp
        dateString = data.date.toDate().toISOString().split('T')[0];
      } else if (typeof data.date === 'string') {
        // Already a string
        dateString = data.date.split('T')[0];
      } else {
        // Fallback to today
        dateString = new Date().toISOString().split('T')[0];
      }

      // Build the workout object in the new format
      workoutsByDate[dateString] = {
        id: doc.id,
        workoutName: data.workoutName || data.title || "Untitled",
        date: dateString,
        exercises: (data.exercises || []).map(ex => ({
          name: ex.name,
          equipment: {
            id: ex.equipment?.id || "unknown",
            name: ex.equipment?.name || "Unknown",
          },
          sets: (ex.sets || []).map(set => ({
            reps: set.reps || 0,
            weight: set.weight || 0,
          })),
        })),
      };
    });

    return res.status(200).json({
      message: "User workouts fetched successfully for date range",
      data: workoutsByDate,
    });
  } catch (error) {
    console.error("Error fetching user workouts by date:", error);
    return res.status(500).json({ error: error.message });
  }
};

/**
 * ADD WORKOUT
 * Expects body: { workoutName, date (ISO string), exercises }
 * Requires Authorization: Bearer <token>
 */
export const addWorkout = async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({ error: "Missing or invalid token" });
    }

    const idToken = authHeader.split("Bearer ")[1];
    const decodedToken = await getAuth().verifyIdToken(idToken);
    const uid = decodedToken.uid;

    const { workoutName, date, exercises } = req.body;

    if (!workoutName || !date || !exercises) {
      return res.status(400).json({ error: "Missing required workout fields" });
    }

    // Convert date to Firestore Timestamp if it's a string
    const workoutDate = typeof date === "string" ? new Date(date) : date;

    const workoutData = {
      workoutName,
      date: workoutDate, // Firestore will store as Timestamp
      exercises, // Already in correct format: { name, equipment: { id, name }, sets: [{ reps, weight }] }
      uid,
    };

    const docRef = await db.collection("workouts_completed").add(workoutData);

    return res.status(201).json({
      message: "Workout added successfully",
      id: docRef.id,
      data: {
        id: docRef.id,
        workoutName,
        date: date, // Return as ISO string
        exercises,
      },
    });
  } catch (error) {
    console.error("Error adding workout:", error);
    return res.status(500).json({ error: error.message });
  }
};
