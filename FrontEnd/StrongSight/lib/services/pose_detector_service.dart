import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:ui';
import '../logic/rep_counter.dart';
import '../logic/form_checker.dart';
import '../logic/angle_calculator.dart';
import '../models/exercise_config.dart';
import '../models/pose_analysis_result.dart';

/// Service for pose detection and exercise analysis
/// Coordinates between ML Kit, RepCounter, and FormChecker
class PoseDetectorService {
  late PoseDetector _poseDetector;
  RepCounter? _repCounter;
  final FormChecker _formChecker = FormChecker();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Initialize the pose detector with ML Kit
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

  /// Set the current exercise being performed
  void setExercise(String exerciseName) {
    final config = ExerciseLibrary.configs[exerciseName.toLowerCase()];
    if (config != null) {
      _repCounter = RepCounter(config);
      _formChecker.reset();
    }
  }

  /// Detect poses from camera image
  Future<List<Pose>> detectPoses(
    CameraImage image,
    InputImageRotation rotation,
  ) async {
    if (!_isInitialized) {
      throw Exception('PoseDetectorService not initialized');
    }

    final inputImage = _inputImageFromCameraImage(image, rotation);
    if (inputImage == null) return [];

    return await _poseDetector.processImage(inputImage);
  }

  /// Analyze squat form and return structured result
  PoseAnalysisResult analyzeSquatForm(Pose pose) {
    if (_repCounter == null) {
      return PoseAnalysisResult.invalid('No exercise selected');
    }

    final config = _repCounter!.config;
    final vertex = pose.landmarks[config.vertexJoint];
    final pointA = pose.landmarks[config.pointA];
    final pointB = pose.landmarks[config.pointB];

    // Check tracking confidence
    final confidenceCheck = _formChecker.checkTrackingConfidence(
      vertex,
      pointA,
      pointB,
    );

    if (confidenceCheck.hasError) {
      return PoseAnalysisResult.invalid(
        confidenceCheck.errorMessage ?? 'Low tracking confidence',
      );
    }

    // Calculate knee angle
    final angle = AngleCalculator.calculateAngle(pointA!, vertex!, pointB!);

    // Update rep counter
    _repCounter!.update(angle);

    // Check for form errors
    final formCheck = _formChecker.checkKneeCave(
      pose,
      _repCounter!.currentState,
    );

    // Build result
    return PoseAnalysisResult.fromAnalysis(
      count: _repCounter!.count,
      state: _repCounter!.currentState,
      feedbackMessage: _repCounter!.feedbackMessage,
      angle: angle,
      hasFormError: formCheck.hasError,
      formErrorMessage: formCheck.errorMessage,
    );
  }

  /// Convert CameraImage to InputImage for ML Kit
  InputImage? _inputImageFromCameraImage(
    CameraImage image,
    InputImageRotation rotation,
  ) {
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

  /// Clean up resources
  void dispose() {
    _poseDetector.close();
  }
}
