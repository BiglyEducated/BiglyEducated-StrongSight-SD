# Pre-Run Checklist for StrongSight Camera Workout

## Before Running the App

### 1. Install Dependencies
```bash
cd /Users/jaydenskarbek/Desktop/strong/BiglyEducated-StrongSight-SD/FrontEnd/StrongSight
flutter pub get
```

### 2. Verify Flutter Setup
```bash
flutter doctor -v
```
Make sure:
- ✅ Flutter is installed
- ✅ Android toolchain (if testing on Android)
- ✅ Xcode (if testing on iOS)
- ✅ Connected device or emulator

### 3. Check File Structure
Verify these files exist:
- ✅ `lib/services/pose_detector_service.dart` (UPDATED)
- ✅ `lib/pages/camera_workout_page.dart` (UPDATED)
- ✅ `lib/logic/rep_counter.dart`
- ✅ `lib/models/exercise_config.dart`
- ✅ `lib/services/camera_utils.dart`
- ✅ `assets/models/pose_landmarker_lite.tflite`

### 4. Verify Permissions

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.CAMERA"/>
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to analyze your workout form...</string>
```

## Running the App

### Option 1: Android
```bash
flutter run -d <device-id>
```

### Option 2: iOS
```bash
flutter run -d <device-id>
```

### Option 3: List available devices
```bash
flutter devices
```

## Testing the Camera Workout Page

### 1. Navigate to Camera Workout
- Open app
- Go to workout/exercise selection
- Select "Squat" (or another exercise)
- Should open CameraWorkoutPage

### 2. Check Camera Initialization
- ✅ Camera should initialize within 2-3 seconds
- ✅ "Initializing camera..." message should appear
- ✅ Camera preview should fill the screen
- ✅ No error messages

### 3. Test Pose Detection
- ✅ Stand in front of camera (2-3 meters away)
- ✅ Green skeleton should appear on your body
- ✅ Skeleton should track your movement smoothly
- ✅ Feedback should say "Position yourself in frame" initially

### 4. Test Rep Counting
- ✅ Stand upright (should see "Ready? Begin your descent")
- ✅ Perform a squat (descend slowly)
- ✅ Should show "Lowering... keep it controlled"
- ✅ At bottom position: "Good depth! Now push up"
- ✅ Return to standing: Rep count should increment
- ✅ Feedback: "Rep Complete! Next one."

### 5. Test Form Detection
For knee cave detection:
- ✅ Intentionally let knees collapse inward
- ✅ Should show "⚠️ KNEE CAVE - Push knees out!" in RED
- ✅ Feedback color should change from green to red

### 6. Test Camera Switch (if multiple cameras)
- ✅ Tap camera flip icon in top-right
- ✅ Camera should switch between front/back
- ✅ Pose detection should still work
- ✅ Coordinates should be mirrored correctly for front camera

### 7. Test Finish Button
- ✅ Tap "Finish Workout" button
- ✅ Should return to previous screen
- ✅ Should pass back the rep count

## Common Issues & Solutions

### Issue: "Camera initialization failed"
**Solution:** 
- Check device permissions in Settings
- Restart the app
- Try a different device/emulator

### Issue: "No poses detected" even when in frame
**Solution:**
- Move further from camera (2-3 meters)
- Ensure good lighting
- Check if entire body is visible
- Try different camera angle

### Issue: Skeleton doesn't appear
**Solution:**
- Check that `google_mlkit_pose_detection` is installed
- Verify ML Kit model file exists in assets
- Check console for error messages

### Issue: Rep count not incrementing
**Solution:**
- Ensure full range of motion (standing → deep squat → standing)
- Check ExerciseConfig thresholds are appropriate
- Move slower (velocity check may be preventing transition)
- Check console logs for state transitions

### Issue: App crashes on camera open
**Solution:**
- Check camera permissions are granted
- Verify device has a working camera
- Check logcat/console for specific error
- Try clearing app data and reinstalling

### Issue: Coordinates are flipped/mirrored
**Solution:**
- This is handled automatically for front/back camera
- If still wrong, check `_translatePoint()` method
- Verify `isBackCamera` boolean is correct

### Issue: High CPU/battery usage
**Solution:**
- Frame skip rate is set to 3 (processes every 3rd frame)
- Can increase to 4 or 5 if needed
- Use ResolutionPreset.medium instead of .high

## Build Commands Reference

### Clean build
```bash
flutter clean
flutter pub get
flutter run
```

### Check for errors
```bash
flutter analyze
```

### Run in debug mode
```bash
flutter run --debug
```

### Run in release mode (faster, for testing performance)
```bash
flutter run --release
```

## Success Criteria

The camera workout page is working correctly if:

1. ✅ Camera initializes without errors
2. ✅ Pose skeleton appears and tracks movement
3. ✅ Feedback messages change based on movement
4. ✅ Rep count increments on full rep completion
5. ✅ Form errors are detected and displayed
6. ✅ Phase indicator shows current state
7. ✅ No crashes during workout
8. ✅ Finish button returns to previous screen with rep count

## Debugging Tips

### Enable verbose logging
Add to the top of `_processCameraImage`:
```dart
print('Processing frame - Phase: $_currentPhase, Count: $_repCount');
```

### Check state transitions
In `rep_counter.dart`, add:
```dart
print('State: $currentState, Angle: $_smoothedAngle, Frames: $_consecutiveFrames');
```

### Monitor performance
```bash
flutter run --profile
```
Then use Flutter DevTools to monitor frame rate and memory.

---

**Good luck with your testing! 🚀**
