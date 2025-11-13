import 'dart:math';
import 'dart:typed_data';  
import 'package:flutter/foundation.dart';  
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:camera/camera.dart';
import 'dart:ui';

class PoseDetectorService {
  late PoseDetector _poseDetector;
  bool _isInitialized = false;

  // Initialize the pose detector
  Future<void> initialize() async {
    final options = PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
      model: PoseDetectionModel.accurate,
    );
    _poseDetector = PoseDetector(options: options);
    _isInitialized = true;
  }

  // Process a camera image and detect poses
  Future<List<Pose>> detectPoses(CameraImage image, InputImageRotation rotation) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Convert CameraImage to InputImage
    final inputImage = _convertCameraImage(image, rotation);
    if (inputImage == null) return [];

    // Detect poses
    final poses = await _poseDetector.processImage(inputImage);
    return poses;
  }

  // Convert CameraImage to InputImage for ML Kit
  InputImage? _convertCameraImage(CameraImage image, InputImageRotation rotation) {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final inputImageData = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: inputImageData,
      );
    } catch (e) {
      print('Error converting camera image: $e');
      return null;
    }
  }

  // Get angle between three points (useful for form analysis)
  double getAngle(PoseLandmark firstPoint, PoseLandmark midPoint, PoseLandmark lastPoint) {
    double result = (atan2(lastPoint.y - midPoint.y, lastPoint.x - midPoint.x) -
            atan2(firstPoint.y - midPoint.y, firstPoint.x - midPoint.x)) *
        (180 / pi);

    result = result.abs();
    if (result > 180) {
      result = 360.0 - result;
    }
    return result;
  }

  // Analyze squat form
  Map<String, dynamic> analyzeSquatForm(Pose pose) {
    final landmarks = pose.landmarks;
    
    // Get key points for squat analysis
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final leftKnee = landmarks[PoseLandmarkType.leftKnee];
    final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
    
    final rightHip = landmarks[PoseLandmarkType.rightHip];
    final rightKnee = landmarks[PoseLandmarkType.rightKnee];
    final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];

    if (leftHip == null || leftKnee == null || leftAnkle == null ||
        rightHip == null || rightKnee == null || rightAnkle == null) {
      return {'isValid': false, 'feedback': 'Cannot detect all body points'};
    }

    // Calculate knee angles
    final leftKneeAngle = getAngle(leftHip, leftKnee, leftAnkle);
    final rightKneeAngle = getAngle(rightHip, rightKnee, rightAnkle);
    final avgKneeAngle = (leftKneeAngle + rightKneeAngle) / 2;

    // Squat depth analysis
    String phase = 'standing';
    String feedback = '';
    
    if (avgKneeAngle > 160) {
      phase = 'standing';
      feedback = 'Ready to squat';
    } else if (avgKneeAngle > 120) {
      phase = 'partial';
      feedback = 'Quarter squat';
    } else if (avgKneeAngle > 90) {
      phase = 'parallel';
      feedback = 'Good depth! Parallel squat';
    } else {
      phase = 'deep';
      feedback = 'Deep squat - excellent!';
    }

    return {
      'isValid': true,
      'phase': phase,
      'leftKneeAngle': leftKneeAngle,
      'rightKneeAngle': rightKneeAngle,
      'avgKneeAngle': avgKneeAngle,
      'feedback': feedback,
    };
  }

  // Clean up resources
  void dispose() {
    _poseDetector.close();
  }
}