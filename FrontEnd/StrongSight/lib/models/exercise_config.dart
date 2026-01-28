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
      standingThreshold: 170.0,
      bottomThreshold: 95.0,
      optimalAngle: "Front",
      cameraHeight: "Chest Height",
    ),
    'bench': ExerciseConfig(
      name: "Bench Press",
      vertexJoint: PoseLandmarkType.leftElbow,
      pointA: PoseLandmarkType.leftShoulder,
      pointB: PoseLandmarkType.leftWrist,
      standingThreshold: 165.0,
      bottomThreshold: 70.0,
      optimalAngle: "Side (45°)",
      cameraHeight: "Bench Height",
    ),
    'bench press': ExerciseConfig(
      name: "Bench Press",
      vertexJoint: PoseLandmarkType.leftElbow,
      pointA: PoseLandmarkType.leftShoulder,
      pointB: PoseLandmarkType.leftWrist,
      standingThreshold: 165.0,
      bottomThreshold: 70.0,
      optimalAngle: "Side (45°)",
      cameraHeight: "Bench Height",
    ),
    'deadlift': ExerciseConfig(
      name: "Deadlift",
      vertexJoint: PoseLandmarkType.leftHip,
      pointA: PoseLandmarkType.leftShoulder,
      pointB: PoseLandmarkType.leftKnee,
      standingThreshold: 165.0, // Reduced from 175 - easier lockout
      bottomThreshold: 120.0,   // Increased from 115 - easier starting position
      optimalAngle: "Side (90°)",
      cameraHeight: "Hip Height",
    ),
    'row': ExerciseConfig(
      name: "Barbell Row",
      vertexJoint: PoseLandmarkType.leftElbow,
      pointA: PoseLandmarkType.leftShoulder,
      pointB: PoseLandmarkType.leftWrist,
      standingThreshold: 150.0,
      bottomThreshold: 75.0,
      optimalAngle: "Side (90°)",
      cameraHeight: "Waist Height",
    ),
    'barbell row': ExerciseConfig(
      name: "Barbell Row",
      vertexJoint: PoseLandmarkType.leftElbow,
      pointA: PoseLandmarkType.leftShoulder,
      pointB: PoseLandmarkType.leftWrist,
      standingThreshold: 150.0,
      bottomThreshold: 75.0,
      optimalAngle: "Side (90°)",
      cameraHeight: "Waist Height",
    ),
    'overhead': ExerciseConfig(
      name: "Overhead Press",
      vertexJoint: PoseLandmarkType.leftElbow,
      pointA: PoseLandmarkType.leftShoulder,
      pointB: PoseLandmarkType.leftWrist,
      standingThreshold: 140.0,
      bottomThreshold: 100.0,
      optimalAngle: "Front",
      cameraHeight: "Chest Height",
    ),
    'overhead press': ExerciseConfig(
      name: "Overhead Press",
      vertexJoint: PoseLandmarkType.leftElbow,
      pointA: PoseLandmarkType.leftShoulder,
      pointB: PoseLandmarkType.leftWrist,
      standingThreshold: 140.0,
      bottomThreshold: 100.0,
      optimalAngle: "Front",
      cameraHeight: "Chest Height",
    ),
    'bicep curls': ExerciseConfig(
      name: "Bicep Curls",
      vertexJoint: PoseLandmarkType.leftElbow,
      pointA: PoseLandmarkType.leftShoulder,
      pointB: PoseLandmarkType.leftWrist,
      standingThreshold: 175.0,
      bottomThreshold: 45.0,
      optimalAngle: "Front",
      cameraHeight: "Chest Height",
    ),
  };
}
