# Exercise-Specific Phase Names

## Date: January 22, 2026

## What Changed

Phase names and feedback messages are now customized for each exercise type instead of using generic terms.

---

## Phase Names by Exercise

### **SQUAT:**
- **Standing** → "standing"
- **Descent** → "descending"
- **Bottom** → "parallel"
- **Ascending** → "ascending"

### **BENCH PRESS:** 🆕
- **Standing** → "locked out"
- **Descent** → "lowering bar"
- **Bottom** → "bar at chest"
- **Ascending** → "pressing up"

### **Other Exercises (default):**
- **Standing** → "ready"
- **Descent** → "lowering"
- **Bottom** → "bottom"
- **Ascending** → "rising"

---

## Feedback Messages by Exercise

### **SQUAT:**
```
Descent:   "Lowering... keep it controlled."
Bottom:    "Good depth! Now push up."
Ascending: "Push through!"
Complete:  "Rep Complete! Next one."
```

### **BENCH PRESS:** 🆕
```
Descent:   "Lowering... control the bar."
Bottom:    "Bar to chest! Now press up."
Ascending: "Press! Drive through!"
Complete:  "Locked out! Next rep."
```

### **Other Exercises:**
```
Descent:   "Lowering... stay controlled."
Bottom:    "Bottom position! Now rise."
Ascending: "Rising! Keep going."
Complete:  "Rep Complete! Next one."
```

---

## How It Works

### **1. Phase Detection:**

In `pose_analysis_result.dart`:
```dart
static String _getPhaseString(ExerciseState state, String? exerciseName) {
  final isBench = exerciseName?.toLowerCase().contains('bench') ?? false;
  final isSquat = exerciseName?.toLowerCase().contains('squat') ?? false;

  switch (state) {
    case ExerciseState.standing:
      if (isBench) return 'locked out';
      if (isSquat) return 'standing';
      return 'ready';
    // ... etc
  }
}
```

### **2. Feedback Messages:**

In `rep_counter.dart`:
```dart
String _getDescentMessage() {
  if (_isBenchPress()) {
    return "Lowering... control the bar.";
  } else if (_isSquat()) {
    return "Lowering... keep it controlled.";
  } else {
    return "Lowering... stay controlled.";
  }
}
```

---

## UI Display

### **Squat UI Example:**
```
┌─────────────────────┐
│  Reps: 3            │
│  Push through!      │  ← Feedback
│  Phase: ascending   │  ← Phase name
└─────────────────────┘
```

### **Bench Press UI Example:** 🆕
```
┌─────────────────────┐
│  Reps: 5            │
│  Press! Drive!      │  ← Feedback
│  Phase: pressing up │  ← Phase name
└─────────────────────┘
```

---

## Adding New Exercises

To add custom names for new exercises:

### **Step 1: Update Phase Names**

In `pose_analysis_result.dart`:
```dart
static String _getPhaseString(ExerciseState state, String? exerciseName) {
  final isBench = exerciseName?.toLowerCase().contains('bench') ?? false;
  final isSquat = exerciseName?.toLowerCase().contains('squat') ?? false;
  final isDeadlift = exerciseName?.toLowerCase().contains('deadlift') ?? false; // NEW
  
  switch (state) {
    case ExerciseState.standing:
      if (isBench) return 'locked out';
      if (isSquat) return 'standing';
      if (isDeadlift) return 'upright'; // NEW
      return 'ready';
    // ... continue for other states
  }
}
```

### **Step 2: Update Feedback Messages**

In `rep_counter.dart`:
```dart
String _getDescentMessage() {
  if (_isBenchPress()) return "Lowering... control the bar.";
  if (_isSquat()) return "Lowering... keep it controlled.";
  if (_isDeadlift()) return "Lowering... hinge at hips."; // NEW
  return "Lowering... stay controlled.";
}

bool _isDeadlift() {
  return config.name.toLowerCase().contains('deadlift');
}
```

---

## Benefits

### **1. Better User Experience**
- "Locked out" makes more sense than "standing" for bench
- "Bar at chest" is clearer than "parallel" for bench
- Exercise-specific terminology helps users understand

### **2. Professional Coaching Feel**
- Uses proper gym terminology
- Matches what trainers would say
- More engaging feedback

### **3. Easy to Extend**
- Simple pattern to add new exercises
- Just add detection helper and custom strings
- No complex logic needed

---

## Code Files Modified

1. **`pose_analysis_result.dart`**
   - Added `exerciseName` parameter
   - Added `_getPhaseString()` with exercise detection
   - Returns exercise-specific phase names

2. **`rep_counter.dart`**
   - Added helper methods: `_isBenchPress()`, `_isSquat()`
   - Added message getters: `_getDescentMessage()`, etc.
   - Returns exercise-specific feedback

3. **`pose_detector_service.dart`**
   - Passes `config.name` to `PoseAnalysisResult.fromAnalysis()`
   - Enables exercise name detection downstream

---

## Testing

### **Test Squat:**
1. Select "Squat"
2. Perform squat
3. Check phases show: "standing" → "descending" → "parallel" → "ascending"
4. Check messages match squat terminology

### **Test Bench Press:**
1. Select "Bench Press"
2. Perform bench press
3. Check phases show: "locked out" → "lowering bar" → "bar at chest" → "pressing up"
4. Check messages match bench terminology

---

## Summary

✅ Phase names now exercise-specific
✅ Feedback messages now exercise-specific
✅ Squat uses: standing/descending/parallel/ascending
✅ Bench uses: locked out/lowering bar/bar at chest/pressing up
✅ Easy to add more exercises with custom terminology

**Result:** More professional, clearer, and more engaging user experience! 💪
