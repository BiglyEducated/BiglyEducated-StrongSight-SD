import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:ui';
import '../logic/rep_counter.dart';
import '../logic/form_checker.dart';
import '../logic/angle_calculator.dart';
import '../models/exercise_config.dart';
import '../models/pose_analysis_result.dart';

class PoseDetectorService {
  late PoseDetector _poseDetector;
  RepCounter? _repCounter;
  final FormChecker _formChecker = FormChecker();
  bool _isInitialized = false;
  String? _currentExercise;

  // Smoothing - stores exponential moving average of each landmark position
  static const double _smoothingFactor = 0.4; // lower = smoother but more lag
  final Map<PoseLandmarkType, _SmoothedLandmark> _smoothedLandmarks = {};

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(
        mode: PoseDetectionMode.stream,
        model: PoseDetectionModel.accurate,
      ),
    );
    _isInitialized = true;
  }

  void setExercise(String exerciseName) {
    print('setExercise: "$exerciseName"');
    final key = exerciseName.toLowerCase();
    print('Looking for: "$key"');
    final config = ExerciseLibrary.configs[key];
    if (config != null) {
      print('Found: ${config.name}');
      _repCounter = RepCounter(config);
      _formChecker.reset();
      _smoothedLandmarks.clear();
      _currentExercise = key;
    } else {
      print('NOT FOUND. Available: ${ExerciseLibrary.configs.keys}');
    }
  }

  Future<List<Pose>> detectPoses(CameraImage image, InputImageRotation rotation) async {
    if (!_isInitialized) throw Exception('Not initialized');
    final inputImage = _inputImageFromCameraImage(image, rotation);
    if (inputImage == null) return [];
    return await _poseDetector.processImage(inputImage);
  }

  PoseAnalysisResult analyzeSquatForm(Pose pose) => _analyzeExerciseForm(pose);
  PoseAnalysisResult analyzeBenchForm(Pose pose) => _analyzeExerciseForm(pose);

  PoseAnalysisResult _analyzeExerciseForm(Pose rawPose) {
    final pose = _smoothPose(rawPose);
    if (_repCounter == null || _currentExercise == null) {
      print('ERROR: repCounter=${_repCounter == null}, exercise=$_currentExercise');
      return PoseAnalysisResult.invalid('No exercise selected');
    }

    final config = _repCounter!.config;
    final vertex = pose.landmarks[config.vertexJoint];
    final pointA = pose.landmarks[config.pointA];
    final pointB = pose.landmarks[config.pointB];

    final confidenceCheck = _formChecker.checkTrackingConfidence(vertex, pointA, pointB);
    if (confidenceCheck.hasError) {
      return PoseAnalysisResult.invalid(confidenceCheck.errorMessage ?? 'Low confidence');
    }

    final angle = AngleCalculator.calculateAngle(pointA!, vertex!, pointB!);
    _repCounter!.update(angle);

    FormCheckResult formCheck;
    if (_currentExercise == 'squat') {
      formCheck = _formChecker.checkAllSquatForm(pose, _repCounter!.currentState);
    } else if (_currentExercise == 'bench' || _currentExercise == 'bench press') {
      formCheck = _formChecker.checkAllBenchForm(pose, _repCounter!.currentState);
    } else if (_currentExercise == 'row' || _currentExercise == 'barbell row') {
      formCheck = _formChecker.checkBenchSymmetry(pose, _repCounter!.currentState);
    } else if (_currentExercise == 'overhead' || _currentExercise == 'overhead press') {
      formCheck = _formChecker.checkBenchSymmetry(pose, _repCounter!.currentState);
    } else if (_currentExercise == 'deadlift') {
      formCheck = _formChecker.checkAllDeadliftForm(pose, _repCounter!.currentState);
    } else {
      formCheck = FormCheckResult(hasError: false);
    }

    return PoseAnalysisResult.fromAnalysis(
      count: _repCounter!.count,
      state: _repCounter!.currentState,
      feedbackMessage: _repCounter!.feedbackMessage,
      angle: angle,
      hasFormError: formCheck.hasError,
      formErrorMessage: formCheck.errorMessage,
      exerciseName: config.name,
    );
  }

  InputImage? _inputImageFromCameraImage(CameraImage image, InputImageRotation rotation) {
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null || image.planes.isEmpty) return null;
    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  // Applies EMA smoothing to all landmarks in a pose
  Pose _smoothPose(Pose pose) {
    final smoothed = <PoseLandmarkType, PoseLandmark>{};

    for (final entry in pose.landmarks.entries) {
      final type = entry.key;
      final raw = entry.value;

      if (!_smoothedLandmarks.containsKey(type)) {
        _smoothedLandmarks[type] = _SmoothedLandmark(raw.x, raw.y, raw.z);
      } else {
        final prev = _smoothedLandmarks[type]!;
        final alpha = _smoothingFactor;
        prev.x = alpha * raw.x + (1 - alpha) * prev.x;
        prev.y = alpha * raw.y + (1 - alpha) * prev.y;
        prev.z = alpha * raw.z + (1 - alpha) * prev.z;
      }

      final s = _smoothedLandmarks[type]!;
      smoothed[type] = PoseLandmark(
        type: type,
        x: s.x,
        y: s.y,
        z: s.z,
        likelihood: raw.likelihood,
      );
    }

    return Pose(landmarks: smoothed);
  }

  void dispose() {
    _poseDetector.close();
  }
}

class _SmoothedLandmark {
  double x, y, z;
  _SmoothedLandmark(this.x, this.y, this.z);
}
