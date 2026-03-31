import 'package:camera/camera.dart';
import 'dart:io' show Platform;

/// Manages camera initialization and configuration
class CameraService {
  CameraController? _controller;
  List<CameraDescription> _availableCameras = [];
  int _currentCameraIndex = 0;

  CameraController? get controller => _controller;
  bool get isInitialized => _controller?.value.isInitialized ?? false;
  List<CameraDescription> get cameras => _availableCameras;  // Renamed from availableCameras
  int get currentCameraIndex => _currentCameraIndex;

  /// Initialize camera with preferred settings
  Future<void> initialize() async {
    try {
      print('CameraService: Getting available cameras...');
      _availableCameras = await availableCameras();  // This calls the camera package function

      if (_availableCameras.isEmpty) {
        throw Exception('No cameras available on this device');
      }

      print('CameraService: Found ${_availableCameras.length} cameras');

      // Prefer back camera
      _currentCameraIndex = _availableCameras.indexWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );

      // Fallback to first camera if no back camera
      if (_currentCameraIndex == -1) {
        print('CameraService: No back camera found, using first camera');
        _currentCameraIndex = 0;
      }

      print('CameraService: Setting up camera at index $_currentCameraIndex');
      await _setupCamera(_availableCameras[_currentCameraIndex]);
      print('CameraService: Camera initialized successfully');
    } catch (e) {
      print('CameraService ERROR: $e');
      rethrow;
    }
  }

  /// Setup camera controller with optimal settings
  Future<void> _setupCamera(CameraDescription camera) async {
    try {
      await _controller?.dispose();

      print('CameraService: Creating camera controller...');
      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isIOS 
            ? ImageFormatGroup.bgra8888
            : ImageFormatGroup.nv21,
      );

      print('CameraService: Initializing camera controller...');
      await _controller!.initialize();
      print('CameraService: Camera controller initialized');
    } catch (e) {
      print('CameraService _setupCamera ERROR: $e');
      rethrow;
    }
  }

  /// Switch to next available camera
  Future<void> switchCamera() async {
    if (_availableCameras.length < 2) {
      throw Exception('Only one camera available');
    }

    try {
      await _controller?.stopImageStream();
    } catch (e) {
      print('CameraService: Error stopping image stream: $e');
    }

    _currentCameraIndex = (_currentCameraIndex + 1) % _availableCameras.length;
    await _setupCamera(_availableCameras[_currentCameraIndex]);
  }

  /// Start streaming images with callback
  void startImageStream(Function(CameraImage) onImage) {
    if (_controller == null) {
      throw Exception('Camera controller is null');
    }
    
    if (!isInitialized) {
      throw Exception('Camera not initialized');
    }

    print('CameraService: Starting image stream...');
    _controller!.startImageStream(onImage);
    print('CameraService: Image stream started');
  }

  /// Stop image stream
  Future<void> stopImageStream() async {
    try {
      if (_controller != null) {
        await _controller!.stopImageStream();
      }
    } catch (e) {
      print('CameraService: Error stopping stream: $e');
    }
  }

  /// Clean up resources
  Future<void> dispose() async {
    try {
      await _controller?.dispose();
      _controller = null;
    } catch (e) {
      print('CameraService: Error disposing: $e');
    }
  }

  /// Get current camera description
  CameraDescription get currentCamera => _availableCameras[_currentCameraIndex];

  /// Check if current camera is back camera
  bool get isBackCamera =>
      currentCamera.lensDirection == CameraLensDirection.back;
}
