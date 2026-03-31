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
  final String readyCue;
  final String descentCue;
  final String bottomCue;
  final String ascentCue;
  final String repCompleteCue;
  final double minEccentricSeconds;
  final double minConcentricSeconds;
  final String fastEccentricCue;
  final String fastConcentricCue;

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
    this.readyCue = "Ready? Begin your descent.",
    this.descentCue = "Lowering... keep it controlled.",
    this.bottomCue = "Good depth! Now push up.",
    this.ascentCue = "Push through!",
    this.repCompleteCue = "Rep Complete! Next one.",
    this.minEccentricSeconds = 0.4,
    this.minConcentricSeconds = 0.3,
    this.fastEccentricCue = "⚠️ TOO FAST - Lower with control!",
    this.fastConcentricCue = "⚠️ TOO FAST - Avoid bouncing out of the bottom!",
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
      readyCue: "Set your arch and brace. Lower with control.",
      descentCue: "Lower to chest under control.",
      bottomCue: "Good touch. Press strong!",
      ascentCue: "Drive the bar up evenly.",
      repCompleteCue: "Bench rep locked out. Go again.",
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
      standingThreshold: 155.0,
      bottomThreshold: 65.0,
      optimalAngle: "Side (90°)",
      cameraHeight: "Waist Height",
      readyCue: "Hinge forward. Arms hang straight.",
      descentCue: "Lower the bar with control.",
      bottomCue: "Bar at torso! Squeeze your back.",
      ascentCue: "Drive elbows back!",
      repCompleteCue: "Full extension. Next rep.",
    ),
    'barbell row': ExerciseConfig(
      name: "Barbell Row",
      vertexJoint: PoseLandmarkType.leftElbow,
      pointA: PoseLandmarkType.leftShoulder,
      pointB: PoseLandmarkType.leftWrist,
      standingThreshold: 155.0,
      bottomThreshold: 65.0,
      optimalAngle: "Side (90°)",
      cameraHeight: "Waist Height",
      readyCue: "Hinge forward. Arms hang straight.",
      descentCue: "Lower the bar with control.",
      bottomCue: "Bar at torso! Squeeze your back.",
      ascentCue: "Drive elbows back!",
      repCompleteCue: "Full extension. Next rep.",
    ),
    'overhead': ExerciseConfig(
      name: "Overhead Press",
      vertexJoint: PoseLandmarkType.leftElbow,
      pointA: PoseLandmarkType.leftShoulder,
      pointB: PoseLandmarkType.leftWrist,
      standingThreshold: 160.0,
      bottomThreshold: 65.0,
      optimalAngle: "Front",
      cameraHeight: "Chest Height",
      readyCue: "Bar at shoulders. Stay braced.",
      descentCue: "Lower to shoulders.",
      bottomCue: "At shoulders. Press up.",
      ascentCue: "Press overhead.",
      repCompleteCue: "Lockout. Next rep.",
      minEccentricSeconds: 0.45,
      fastEccentricCue: "⚠️ TOO FAST - Lower to shoulders with control!",
      fastConcentricCue: "⚠️ TOO FAST - Press more smoothly!",
    ),
    'overhead press': ExerciseConfig(
      name: "Overhead Press",
      vertexJoint: PoseLandmarkType.leftElbow,
      pointA: PoseLandmarkType.leftShoulder,
      pointB: PoseLandmarkType.leftWrist,
      standingThreshold: 160.0,
      bottomThreshold: 65.0,
      optimalAngle: "Front",
      cameraHeight: "Chest Height",
      readyCue: "Bar at shoulders. Stay braced.",
      descentCue: "Lower to shoulders.",
      bottomCue: "At shoulders. Press up.",
      ascentCue: "Press overhead.",
      repCompleteCue: "Lockout. Next rep.",
      minEccentricSeconds: 0.45,
      fastEccentricCue: "⚠️ TOO FAST - Lower to shoulders with control!",
      fastConcentricCue: "⚠️ TOO FAST - Press more smoothly!",
    ),
    'shoulder press': ExerciseConfig(
      name: "Overhead Press",
      vertexJoint: PoseLandmarkType.leftElbow,
      pointA: PoseLandmarkType.leftShoulder,
      pointB: PoseLandmarkType.leftWrist,
      standingThreshold: 160.0,
      bottomThreshold: 65.0,
      optimalAngle: "Front",
      cameraHeight: "Chest Height",
      readyCue: "Bar at shoulders. Stay braced.",
      descentCue: "Lower to shoulders.",
      bottomCue: "At shoulders. Press up.",
      ascentCue: "Press overhead.",
      repCompleteCue: "Lockout. Next rep.",
      minEccentricSeconds: 0.45,
      fastEccentricCue: "⚠️ TOO FAST - Lower to shoulders with control!",
      fastConcentricCue: "⚠️ TOO FAST - Press more smoothly!",
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
