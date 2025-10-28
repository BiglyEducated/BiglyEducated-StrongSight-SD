import express from "express";
import { signupUser, verifyToken, logoutUser } from "../controllers/authController.js";

const router = express.Router();

// 🔹 Sign up route
router.post("/signup", signupUser);
router.post("/verify-token", verifyToken); 

// 🔹 Log out route (placeholder)
router.post("/logout", logoutUser);

export default router;
