import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:io' show Platform;

/// Converts integer rotation to InputImageRotation
InputImageRotation rotationIntToImageRotation(int rotation) {
  switch (rotation) {
    case 0:
      return InputImageRotation.rotation0deg;
    case 90:
      return InputImageRotation.rotation90deg;
    case 180:
      return InputImageRotation.rotation180deg;
    case 270:
      return InputImageRotation.rotation270deg;
    default:
      return InputImageRotation.rotation0deg;
  }
}

/// Gets the correct image rotation for the current camera
/// Handles both iOS and Android differences
InputImageRotation getImageRotation(CameraController cameraController) {
  if (Platform.isIOS) {
    // iOS specific rotation handling
    final sensorOrientation = cameraController.description.sensorOrientation;
    
    // For front camera
    if (cameraController.description.lensDirection == CameraLensDirection.front) {
      return rotationIntToImageRotation((360 - sensorOrientation) % 360);
    }
    // For back camera
    else {
      return rotationIntToImageRotation(sensorOrientation);
    }
  } else {
    // Android
    final sensorOrientation = cameraController.description.sensorOrientation;
    return rotationIntToImageRotation(sensorOrientation);
  }
}
