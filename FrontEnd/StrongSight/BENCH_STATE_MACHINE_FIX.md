# Bench Press State Machine Fixes

## Date: January 22, 2026

## Problem
Bench press wasn't properly tracking the full rep cycle - specifically having trouble with:
1. Initial lockout detection
2. Transition from standing → descent
3. Transition from ascending → standing (completing rep)

## Root Causes

### 1. **Initialization Issue**
```dart
// OLD: Started with default 180°
double _smoothedAngle = 180.0;

// PROBLEM: Bench starts at ~165° (locked out)
// So it never detected the initial standing state properly
```

### 2. **Strict Lockout Detection**
```dart
// OLD: Required exactly >= 175° to complete rep
if (_smoothedAngle >= config.standingThreshold)

// PROBLEM: Hard to achieve perfect 175° lockout
// Natural variation means you might only reach 170°
```

### 3. **Narrow Transition Windows**
```dart
// OLD: -5° buffer for descent
if (_smoothedAngle < config.standingThreshold - 5)

// PROBLEM: Too small buffer for bench press range
// Bench has ~100° range vs squat's ~75° range
```

---

## Solutions Implemented

### Fix 1: Initialize with First Real Angle

**Added:**
```dart
bool _isInitialized = false;

void update(double rawAngle) {
  if (!_isInitialized) {
    _smoothedAngle = rawAngle;  // Start with actual position
    _previousAngle = rawAngle;
    _isInitialized = true;
  }
  // ... rest of logic
}
```

**Effect:** State machine starts from actual arm position, not arbitrary 180°

---

### Fix 2: More Lenient Lockout Detection

**Changed:**
```dart
// OLD:
case ExerciseState.ascending:
  if (_smoothedAngle >= config.standingThreshold)

// NEW:
case ExerciseState.ascending:
  if (_smoothedAngle >= config.standingThreshold - 5)  // Within 5° is enough
    _consecutiveFrames++;
    if (_consecutiveFrames >= _frameThreshold)
```

**Effect:** Counts rep when arms are "close enough" to locked (within 5°)

---

### Fix 3: Wider Transition Buffers

**Changed:**
```dart
// Standing → Descent
// OLD: -5° buffer
if (_smoothedAngle < config.standingThreshold - 5)

// NEW: -10° buffer
if (_smoothedAngle < config.standingThreshold - 10)
```

**Effect:** More reliable detection of descent start

---

### Fix 4: Adjusted Bench Press Thresholds

**In `exercise_config.dart`:**

```dart
// OLD thresholds:
standingThreshold: 175.0  // Too strict
bottomThreshold: 65.0     // Too deep

// NEW thresholds:
standingThreshold: 165.0  // More realistic lockout
bottomThreshold: 70.0     // Realistic bar-to-chest
```

**Reasoning:**
- Real lockout is rarely perfect 180°
- Side view angle measurement isn't exact 
- 165° is "close enough" to locked
- 70° better represents bar touching chest

---

## Complete State Machine Flow (Bench Press)

### Starting Position: Arms Locked (~165°)

```
1. STANDING (165°+)
   ↓ Elbow bends to 155° (10° buffer)
   
2. DESCENT (155° → 80°)
   ↓ Reaches 80° AND velocity < 10°/frame for 2 frames
   
3. BOTTOM (~70-80°)
   ↓ Angle increases to 75°+ for 2 frames
   
4. ASCENDING (75° → 160°)
   ↓ Reaches 160°+ (within 5° of 165°) for 2 frames
   
5. STANDING → Rep Complete! ✅
```

---

## Key Improvements

### 1. **Frame Requirements Stay Low**
- Still only 2 frames needed for transitions
- Fast and responsive

### 2. **Buffers Prevent Missed Transitions**
```
Standing detection: >= 160° (5° buffer)
Descent trigger:    < 155° (10° buffer)  
Bottom detection:   <= 80° (10° buffer)
Ascent trigger:     > 75° (5° buffer)
```

### 3. **Handles Real-World Variation**
- Arms don't lock perfectly straight
- Camera angle affects measurement
- Natural movement has variance

---

## Testing Guide

### **Test Full Cycle:**

1. **Start with arms locked**
   - Should show: "STANDING"
   - Angle: ~160-170°

2. **Lower bar to chest**
   - Should show: "DESCENT" → "BOTTOM"
   - Should hit bottom at ~70-80°

3. **Press bar up**
   - Should show: "ASCENDING"
   - Angle increases from 75° → 160°

4. **Lock out arms**
   - Should show: "STANDING"
   - **Rep count should increment! ✅**
   - Message: "Rep Complete! Next one."

### **Common Issues to Watch For:**

❌ **If stuck in ASCENDING:**
- Not reaching 160° lockout
- Try: Fully extend arms

❌ **If not detecting DESCENT:**
- Starting position too low
- Lock arms fully before starting

❌ **If not counting rep:**
- Not fully locking out at top
- Check angle reaches 160°+

---

## Comparison: Squat vs Bench

| Feature | Squat | Bench Press |
|---------|-------|-------------|
| **Standing angle** | 170° | 165° |
| **Bottom angle** | 95° | 70° |
| **Range of motion** | 75° | 95° |
| **Standing buffer** | -5° | -10° (wider) |
| **Lockout buffer** | 0° (exact) | -5° (lenient) |
| **Frame threshold** | 2 frames | 2 frames |

**Why bench needs wider buffers:**
- Larger ROM (95° vs 75°)
- More variability in arm position
- Harder to achieve perfect 180° lockout
- Camera angle affects measurement more

---

## Configuration Values

### **Can adjust in `exercise_config.dart`:**

```dart
'bench press': ExerciseConfig(
  standingThreshold: 165.0,  // Increase if too easy, decrease if too hard
  bottomThreshold: 70.0,     // Decrease for deeper, increase for shallower
)
```

### **Can adjust in `rep_counter.dart`:**

```dart
// Make lockout easier/harder:
if (_smoothedAngle >= config.standingThreshold - 5)  // Change 5 to adjust

// Make descent trigger easier/harder:
if (_smoothedAngle < config.standingThreshold - 10)  // Change 10 to adjust
```

---

## Summary of Changes

✅ **Fixed initialization** - starts from actual position
✅ **Made lockout more forgiving** - within 5° counts
✅ **Widened descent buffer** - 10° instead of 5°
✅ **Adjusted thresholds** - 165° standing, 70° bottom
✅ **Added frame requirements** - 2 frames for all transitions
✅ **Improved reset logic** - returns to standing if improper form

**Result:** Bench press now reliably tracks full ROM and counts reps! 💪
