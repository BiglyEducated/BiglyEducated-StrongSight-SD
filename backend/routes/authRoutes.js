import express from "express";
import { signupUser, verifyToken, deleteUser, getUserInfo} from "../controllers/authController.js";
import { get } from "http";

const router = express.Router();

// 🔹 Sign up route
router.post("/signup", signupUser);
router.post("/verify-token", verifyToken); 

// 🔹 Log out route (placeholder)
router.post("/delete-user", deleteUser);

//
router.get('/get-userInfo', getUserInfo);

export default router;
