import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

enum ExerciseState { standing, descent, bottom, ascending }

class ExerciseConfig {
  final String name;
  final PoseLandmarkType vertexJoint;
  final PoseLandmarkType pointA;
  final PoseLandmarkType pointB;
  final double standingThreshold;
  final double bottomThreshold;
  final double velocityLimit;
  final String optimalAngle;
  final String cameraHeight;

  ExerciseConfig({
    required this.name,
    required this.vertexJoint,
    required this.pointA,
    required this.pointB,
    this.standingThreshold = 160.0,
    this.bottomThreshold = 95.0,
    this.velocityLimit = 5.0,
    required this.optimalAngle,
    required this.cameraHeight,
  });
}

class ExerciseLibrary {
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
      standingThreshold: 165.0,
      bottomThreshold: 120.0,
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
