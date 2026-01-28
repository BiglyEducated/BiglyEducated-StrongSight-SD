# Barbell Row Support Added

## Date: January 22, 2026

## What Was Added

Barbell rows are now fully supported with rep counting and form checking!

---

## Row Configuration

```dart
'row': ExerciseConfig(
  name: "Barbell Row",
  vertexJoint: PoseLandmarkType.leftElbow,      // Track elbow
  pointA: PoseLandmarkType.leftShoulder,         // Shoulder-Elbow-Wrist angle
  pointB: PoseLandmarkType.leftWrist,
  standingThreshold: 170.0,  // Arms fully extended
  bottomThreshold: 80.0,     // Bar pulled to torso
  optimalAngle: "Side (90°)",
  cameraHeight: "Waist Height",
)
```

**Added alias:** `'barbell row'` for matching "Barbell Row" from UI

---

## How Rows Work

### **Joint Tracking:**
- Tracks **elbow angle** (same as bench press)
- Shoulder → Elbow → Wrist

### **State Machine:**
```
ARMS EXTENDED (170°+)
    ↓ Elbows bend to 160°
PULLING (160° → 90°)
    ↓ Reaches 90° AND low velocity
BAR TO TORSO (~80°)
    ↓ Elbows extend to 85°+
EXTENDING (85° → 165°)
    ↓ Reaches 165°+
ARMS EXTENDED → Rep Complete! ✅
```

### **Thresholds:**
- Standing: 170° (arms extended)
- Bottom: 80° (bar at torso)
- Buffers: -10° descent, -5° lockout

---

## Row-Specific Phase Names

**Phases:**
- **Standing** → "arms extended"
- **Descent** → "pulling"
- **Bottom** → "bar to torso"
- **Ascending** → "extending"

**Feedback Messages:**
- Descent: "Pulling... squeeze your back!"
- Bottom: "Bar to torso! Squeeze and hold."
- Ascending: "Extending arms... controlled!"
- Complete: "Full extension! Next rep."

---

## Row Form Checking

### **What's Checked:**
- **Symmetry** - Left vs right arm balance
  - Threshold: 15° difference
  - Message: "⚠️ UNEVEN ARMS - Balance the bar!"

### **What's NOT Checked:**
- Elbow flare (not relevant for pulling movements)
- Only symmetry matters for rows

---

## UI Example

```
┌─────────────────────────┐
│  Reps: 8                │
│  Pulling... squeeze!    │  ← Row-specific feedback
│  Phase: pulling         │  ← Row-specific phase
└─────────────────────────┘
```

---

## Camera Setup for Rows

**Recommended:**
- **View:** Side (90° angle)
- **Height:** Waist level
- **Distance:** 2-3 meters
- **Visibility:** See full arm extension

**Why side view?**
- Can see elbow angle clearly
- Can detect full ROM
- Better form visibility

---

## Comparison: Bench vs Row

| Feature | Bench Press | Barbell Row |
|---------|-------------|-------------|
| **Joint** | Elbow | Elbow |
| **Standing angle** | 165° | 170° |
| **Bottom angle** | 70° | 80° |
| **Movement** | Pressing | Pulling |
| **Form checks** | Elbow flare + Symmetry | Symmetry only |
| **Phase names** | Locked out / Bar at chest | Arms extended / Bar to torso |

---

## Code Changes

### **1. exercise_config.dart**
- Adjusted row thresholds: 175° → 170°, 85° → 80°
- Added `'barbell row'` alias

### **2. pose_detector_service.dart**
- Added row detection: `if (_currentExercise == 'row' || _currentExercise == 'barbell row')`
- Routes to symmetry check only

### **3. pose_analysis_result.dart**
- Added row detection: `final isRow = exerciseName?.toLowerCase().contains('row')`
- Added row phase names

### **4. rep_counter.dart**
- Added `_isRow()` helper method
- Added row-specific feedback messages

---

## Testing Checklist

### **Test Rep Counting:**
- ✅ Arms extended → Detects "arms extended"
- ✅ Pull bar → Detects "pulling"
- ✅ Bar to torso → Detects "bar to torso"
- ✅ Extend arms → Detects "extending"
- ✅ Full extension → Counts rep

### **Test Form Check:**
- ✅ Uneven pull → Shows "UNEVEN ARMS"
- ✅ Balanced pull → No warnings

---

## Supported Exercises

| Exercise | Status | Form Checks |
|----------|--------|-------------|
| **Squat** | ✅ Working | Knee cave, Forward lean, Symmetry |
| **Bench Press** | ✅ Working | Elbow flare, Symmetry |
| **Barbell Row** | ✅ Working | Symmetry |
| **Deadlift** | ⏳ Config exists | Need to add form checks |
| **Overhead Press** | ⏳ Config exists | Need to add form checks |
| **Bicep Curls** | ⏳ Config exists | Need to add form checks |

---

## Adding More Exercises

To add new exercises, follow this pattern:

### **Step 1: Adjust config** (if needed)
```dart
'exercise_name': ExerciseConfig(...)
```

### **Step 2: Add form checks** (if needed)
```dart
else if (_currentExercise == 'exercise_name') {
  formCheck = _formChecker.checkWhatever(pose, state);
}
```

### **Step 3: Add phase names**
```dart
final isExercise = exerciseName?.toLowerCase().contains('exercise');
if (isExercise) return 'exercise-specific-phase';
```

### **Step 4: Add feedback messages**
```dart
bool _isExercise() => config.name.toLowerCase().contains('exercise');
if (_isExercise()) return "Exercise-specific message";
```

---

## Summary

✅ Barbell row fully integrated
✅ Rep counting works (elbow tracking)
✅ Symmetry form check active
✅ Row-specific phase names
✅ Row-specific feedback messages
✅ Uses same responsive 2-frame threshold

**To use:** Select "Barbell Row" from workout page and it works! 💪

---

## Next Steps

Can add the remaining exercises using the same pattern:
- Deadlift (already configured, needs form checks)
- Overhead Press (already configured, needs form checks)
- Bicep Curls (already configured, needs form checks)
