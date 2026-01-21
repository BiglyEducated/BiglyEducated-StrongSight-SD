import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

// The four-state system used to track repetitions (Section 6.3.7)
enum ExerciseState { standing, descent, bottom, ascending }

class ExerciseConfig {
  final String name;
  
  // Generic biomechanical naming for any exercise (Section 6.3.2)
  final PoseLandmarkType vertexJoint; // The central connecting joint (e.g., Knee)
  final PoseLandmarkType pointA;      // First outer joint (e.g., Hip)
  final PoseLandmarkType pointB;      // Second outer joint (e.g., Ankle)

  // Machine-readable metrics and thresholds (Section 6.1.1)
  final double standingThreshold;     // Angle defining the "Standing" state
  final double bottomThreshold;       // Angle required to reach "Bottom" state
  final double velocityLimit;         // Degrees per frame for stabilization (Section 6.3.7)
  
  // Setup recommendations for users (Section 6.3.8)
  final String optimalAngle;
  final String cameraHeight;

  ExerciseConfig({
    required this.name,
    required this.vertexJoint,
    required this.pointA,
    required this.pointB,
    this.standingThreshold = 160.0,
    this.bottomThreshold = 95.0,
    this.velocityLimit = 5.0, // Threshold to prevent premature transitions
    required this.optimalAngle,
    required this.cameraHeight,
  });
}

class ExerciseLibrary {
  // Master configuration library based on Section 6.1 and 6.3.8
  static final Map<String, ExerciseConfig> configs = {
    'squat': ExerciseConfig(
      name: "Squat",
      vertexJoint: PoseLandmarkType.leftKnee,
      pointA: PoseLandmarkType.leftHip,
      pointB: PoseLandmarkType.leftAnkle,
      standingThreshold: 170.0, // Adjusted per practical testing (Section 6.4.1)
      bottomThreshold: 95.0,   // Good squat depth (Section 6.4.1)
      optimalAngle: "Front",
      cameraHeight: "Chest Height",
    ),
    'bench': ExerciseConfig(
      name: "Bench Press",
      vertexJoint: PoseLandmarkType.leftElbow,
      pointA: PoseLandmarkType.leftShoulder,
      pointB: PoseLandmarkType.leftWrist,
      standingThreshold: 175.0, // Fully locked out (Section 6.1.3)
      bottomThreshold: 65.0,    // Elbow-to-torso angle (Section 6.1.3)
      optimalAngle: "Side (45°)",
      cameraHeight: "Bench Height",
    ),
    'deadlift': ExerciseConfig(
      name: "Deadlift",
      vertexJoint: PoseLandmarkType.leftHip,
      pointA: PoseLandmarkType.leftShoulder,
      pointB: PoseLandmarkType.leftKnee,
      standingThreshold: 175.0, // Fully standing upright (Section 6.1.4)
      bottomThreshold: 115.0,   // Midpoint of 100-130 range (Section 6.1.4)
      optimalAngle: "Side (90°)",
      cameraHeight: "Hip Height",
    ),
    'row': ExerciseConfig(
      name: "Barbell Row",
      vertexJoint: PoseLandmarkType.leftElbow,
      pointA: PoseLandmarkType.leftShoulder,
      pointB: PoseLandmarkType.leftWrist,
      standingThreshold: 175.0, // Arms extended (Section 6.1.5)
      bottomThreshold: 85.0,    // Elbow flex 70-100 range (Section 6.1.5)
      optimalAngle: "Side (90°)",
      cameraHeight: "Waist Height",
    ),
    'overhead': ExerciseConfig(
      name: "Overhead Press",
      vertexJoint: PoseLandmarkType.leftElbow,
      pointA: PoseLandmarkType.leftShoulder,
      pointB: PoseLandmarkType.leftWrist,
      standingThreshold: 175.0, // Arms locked overhead (Section 6.1.6)
      bottomThreshold: 10.0,    // Elbows 5-15 forward of bar (Section 6.1.6)
      optimalAngle: "Front",
      cameraHeight: "Chest Height",
    ),
  };
}