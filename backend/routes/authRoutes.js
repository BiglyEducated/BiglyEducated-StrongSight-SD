import express from "express";
import { signupUser, verifyToken, deleteUser, getUserInfo, editUserInfo, addWorkout, getUserWorkouts, getUserWorkoutsByDate, deleteUserProfile} from "../controllers/authController.js";
import { get } from "http";

const router = express.Router();

// 🔹 Sign up route
router.post("/signup", signupUser);
router.post("/verify-token", verifyToken); 


//user apis
router.get('/get-userInfo', getUserInfo);
router.put('/edit-userInfo', editUserInfo);
router.delete('/delete-userProfile', deleteUserProfile);

//workouts
router.post('/add-workout', addWorkout);
router.get('/get-userWorkouts', getUserWorkouts);
router.get('/get-userWorkoutsDate', getUserWorkoutsByDate);
export default router;
