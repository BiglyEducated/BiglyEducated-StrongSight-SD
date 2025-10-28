import { getAuth } from "firebase-admin/auth";

// 🧩 Sign-up Controller
export const signupUser = async (req, res) => {
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
      console.log("✅ Successfully created new user:", userRecord.uid);
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
