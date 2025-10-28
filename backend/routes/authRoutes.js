import express from "express";
import { signupUser, logoutUser } from "../controllers/authController.js";

const router = express.Router();

// 🔹 Sign up route
router.post("/signup", signupUser);

// 🔹 Log out route (placeholder)
router.post("/logout", logoutUser);

export default router;
