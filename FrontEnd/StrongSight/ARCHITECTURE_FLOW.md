# StrongSight Camera Workout - Architecture Flow

## Component Connection Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    CameraWorkoutPage                         │
│  (User Interface - Displays camera, overlays, feedback)     │
└────────────┬────────────────────────────────────────────────┘
             │
             │ Uses
             ▼
┌─────────────────────────────────────────────────────────────┐
│              PoseDetectorService                             │
│  - detectPoses(image, rotation) → List<Pose>               │
│  - analyzeSquatForm(pose) → Map<analysis>                  │
│  - setExercise(exerciseName)                                │
└────────┬──────────────────┬──────────────────┬──────────────┘
         │                  │                  │
         │ Uses             │ Uses             │ Uses
         ▼                  ▼                  ▼
┌────────────────┐  ┌──────────────┐  ┌───────────────────┐
│  RepCounter    │  │ExerciseConfig│  │ Google ML Kit     │
│                │  │              │  │ PoseDetector      │
│ - update()     │  │ - configs    │  │                   │
│ - count        │  │ - thresholds │  │ - processImage()  │
│ - state        │  │ - joints     │  │                   │
│ - feedback     │  │              │  │                   │
└────────────────┘  └──────────────┘  └───────────────────┘
```

## Data Flow Sequence

### 1. Initialization
```
App Start
   ↓
CameraWorkoutPage.initState()
   ↓
Initialize Camera (back camera preferred)
   ↓
PoseDetectorService.initialize()
   ↓
PoseDetectorService.setExercise('squat')
   ↓
RepCounter created with ExerciseConfig
   ↓
Start Camera Image Stream
```

### 2. Frame Processing Loop (Every 3rd frame)
```
Camera captures frame
   ↓
_processCameraImage(CameraImage)
   ↓
getImageRotation() → InputImageRotation
   ↓
PoseDetectorService.detectPoses(image, rotation)
   ↓
ML Kit processes image → List<Pose>
   ↓
If pose detected:
   ↓
PoseDetectorService.analyzeSquatForm(pose)
   ↓
Calculate angle at knee joint (hip-knee-ankle)
   ↓
RepCounter.update(angle)
   ↓
State machine checks angle against thresholds:
   - Standing: angle > 170°
   - Descent: angle decreasing
   - Bottom: angle < 95°
   - Ascending: angle increasing back to 170°
   ↓
Check form errors (knee cave)
   ↓
Return analysis map {count, feedback, phase, errors}
   ↓
Update UI with new data
```

## State Machine Flow

```
┌─────────────┐
│  STANDING   │ ◄─────────────────┐
│  (angle >   │                   │
│   170°)     │                   │
└──────┬──────┘                   │
       │                          │
       │ Angle < 165°             │ Angle >= 170°
       │                          │ → Rep Complete!
       ▼                          │
┌─────────────┐                   │
│   DESCENT   │                   │
│  (lowering) │                   │
└──────┬──────┘                   │
       │                          │
       │ Angle <= 95°             │
       │ + Low velocity           │
       │                          │
       ▼                          │
┌─────────────┐                   │
│   BOTTOM    │                   │
│  (parallel  │                   │
│   or below) │                   │
└──────┬──────┘                   │
       │                          │
       │ Angle > 100°             │
       │ (starting up)            │
       │                          │
       ▼                          │
┌─────────────┐                   │
│  ASCENDING  │ ──────────────────┘
│  (pushing   │
│   up)       │
└─────────────┘
```

## Key Angle Calculations

### Squat Knee Angle
```
Points:
  A = Left Hip (pointA)
  V = Left Knee (vertexJoint) 
  B = Left Ankle (pointB)

Calculation:
  angle = arctan2(B.y - V.y, B.x - V.x) - 
          arctan2(A.y - V.y, A.x - V.x)
  
  Convert to degrees: angle * (180 / π)
  
  Normalize: if |angle| > 180°, use 360° - |angle|
```

### Form Check: Knee Cave Detection
```
Knee Distance = |Left Knee X - Right Knee X|
Ankle Distance = |Left Ankle X - Right Ankle X|

Ratio = Knee Distance / Ankle Distance

If Ratio < 0.8 → KNEE CAVE ERROR
```

## Filtering & Smoothing

### Exponential Moving Average (EMA)
```
smoothedAngle = (α × rawAngle) + ((1 - α) × previousSmoothed)

Where α = 0.3 (smoothing factor)
```

### Multi-Frame Confirmation
```
Before state transition:
  - Angle must meet threshold for 3 consecutive frames
  - Prevents false transitions from camera shake
  - Ensures deliberate movement
```

### Velocity Check
```
velocity = |smoothedAngle - previousAngle|

Transition to BOTTOM only if:
  - Angle <= bottomThreshold (95°)
  - velocity < velocityLimit (5° per frame)
  
This ensures user has stabilized at bottom position
```

## Coordinate Transformation

### Camera to Screen Coordinates
```
1. Calculate aspect ratios:
   imageAspect = imageWidth / imageHeight
   screenAspect = screenWidth / screenHeight

2. Determine letterboxing:
   If imageAspect > screenAspect:
     → Letterbox top/bottom
     scale = screenWidth / imageWidth
   Else:
     → Letterbox left/right
     scale = screenHeight / imageHeight

3. Apply transformation:
   screenX = (landmarkX × scale) + offsetX
   screenY = (landmarkY × scale) + offsetY

4. Mirror for front camera:
   if front camera:
     screenX = screenWidth - screenX
```

## Error Handling Strategy

### Camera Level
```
Try:
  Initialize camera
  Set up controller
  Start image stream
Catch:
  Display error message
  Allow retry
  Suggest troubleshooting steps
```

### Pose Detection Level
```
If no poses detected:
  → Display "Position yourself in frame"
  → Clear skeleton overlay
  → Keep processing

If low confidence (<0.7):
  → Display "Low tracking confidence"
  → Skip frame
  → Don't update state

If processing error:
  → Log error
  → Continue processing next frame
  → Don't crash app
```

## Performance Optimizations

1. **Frame Skipping**: Process every 3rd frame (reduces CPU by 66%)
2. **Resolution**: Use `high` preset (balance quality/performance)
3. **Image Format**: Platform-specific (BGRA8888 iOS, NV21 Android)
4. **Processing Lock**: Prevent concurrent processing
5. **EMA Smoothing**: Reduces jitter without lag
6. **Async Processing**: Non-blocking UI updates

## File Dependencies

```
camera_workout_page.dart
├── imports
│   ├── package:camera/camera.dart
│   ├── google_mlkit_pose_detection
│   ├── pose_detector_service.dart
│   └── camera_utils.dart
│
pose_detector_service.dart
├── imports
│   ├── google_mlkit_pose_detection
│   ├── rep_counter.dart
│   └── exercise_config.dart
│
rep_counter.dart
├── imports
│   └── exercise_config.dart
│
exercise_config.dart
└── imports
    └── google_mlkit_pose_detection (for PoseLandmarkType)
```

## Configuration Values

### Squat Config
- **Standing Threshold**: 170° (nearly straight leg)
- **Bottom Threshold**: 95° (parallel or below)
- **Velocity Limit**: 5° per frame
- **Confidence Threshold**: 0.7 (70%)
- **Frame Confirmation**: 3 frames
- **EMA Alpha**: 0.3 (smoothing factor)
- **Knee Cave Ratio**: 0.8

### Camera Settings
- **Resolution**: ResolutionPreset.high
- **Frame Skip Rate**: 3 (process every 3rd frame)
- **Audio**: Disabled
- **Preferred Camera**: Back camera
- **Image Format**: 
  - iOS: bgra8888
  - Android: nv21
