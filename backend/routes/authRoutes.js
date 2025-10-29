import express from "express";
import { signupUser, verifyToken, deleteUser } from "../controllers/authController.js";

const router = express.Router();

// 🔹 Sign up route
router.post("/signup", signupUser);
router.post("/verify-token", verifyToken); 

// 🔹 Log out route (placeholder)
router.post("/delete-user", deleteUser);

export default router;
