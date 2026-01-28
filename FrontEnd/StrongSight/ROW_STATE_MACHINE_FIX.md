# Barbell Row State Machine Fix

## Date: January 22, 2026

## Problem

Row gets stuck in "pulling" state and never completes the rep cycle. Not reaching bottom, ascending, or standing states.

---

## Root Cause Analysis

The issue was likely:
1. **Standing threshold too high** (160° hard to reach on extension)
2. **Bottom threshold too low** (70° hard to hit on pull)
3. **Buffers too tight** - not enough tolerance for natural movement

**Row movement reality:**
- Arms rarely fully extend to 160°+ at bottom of row
- Pulling to torso creates ~75-80° elbow angle
- Need MUCH wider tolerance than other exercises

---

## Fixes Applied

### **1. Much Lower Standing Threshold**
```dart
// BEFORE:
standingThreshold: 160.0

// AFTER:
standingThreshold: 150.0  // -10° easier extension
```

**Effect:** Now accepts 135°+ as "extended" (within 15° buffer)

### **2. Higher Bottom Threshold**
```dart
// BEFORE:
bottomThreshold: 70.0

// AFTER:
bottomThreshold: 75.0  // +5° easier pull detection
```

**Effect:** Detects pull at 95° (within 20° buffer)

### **3. Increased All Buffers**
```dart
// Standing → Descent
-15° → -20° buffer

// Descent → Bottom  
+15° buffer, velocity < 12° → +20° buffer, velocity < 15°

// Bottom → Ascending
+10° → +15° buffer

// Ascending → Standing
-10° → -15° buffer
```

### **4. Added Debug Logging**
```dart
if (_isRow() && currentState != ExerciseState.standing) {
  print('Row Debug - State: $currentState, Angle: X°, Velocity: Y°');
}
```

This will help diagnose where it's getting stuck!

---

## Complete Row State Machine

### **BEFORE (Broken):**
```
Standing (160°)
    ↓ Pull to 145°
Pulling (145° → 85°)
    ↓ Try to reach 85° with velocity < 12°
❌ STUCK - Never detected bottom!
```

### **AFTER (Fixed):**
```
Extended (150°+)
    ↓ Pull to 130° (20° buffer)
    
Pulling (130° → 95°)
    ↓ Reach 95° (75° + 20° buffer) with velocity < 15°
    
Bar to Torso (75°)
    ↓ Extend past 90° (75° + 15° buffer)
    
Extending (90° → 135°)
    ↓ Reach 135° (150° - 15° buffer)
    
Extended → REP COUNTED! ✅
```

---

## Buffer Summary for Rows

| Transition | Threshold | Buffer | Accepts |
|------------|-----------|--------|---------|
| **Extended → Pulling** | 150° | -20° | < 130° |
| **Pulling → Bottom** | 75° | +20° | ≤ 95° |
| **Bottom → Extending** | 75° | +15° | > 90° |
| **Extending → Extended** | 150° | -15° | ≥ 135° |

**Velocity limit:** < 15°/frame (very lenient)

---

## What to Check in Console

When you run rows, you should see:

```
RepCounter initialized: Barbell Row, angle: 145.2°
Barbell Row - Transition: standing → descent
Row Debug - State: descent, Angle: 132.4°, Velocity: 3.2°, Frames: 0
Row Debug - State: descent, Angle: 128.1°, Velocity: 4.3°, Frames: 0
Row Debug - State: descent, Angle: 98.7°, Velocity: 2.1°, Frames: 1
Row Debug - State: descent, Angle: 94.2°, Velocity: 1.8°, Frames: 2
Barbell Row - Transition: descent → bottom
Row Debug - State: bottom, Angle: 91.3°, Velocity: 0.9°, Frames: 0
Row Debug - State: bottom, Angle: 92.8°, Velocity: 1.5°, Frames: 1
Row Debug - State: bottom, Angle: 95.4°, Velocity: 2.6°, Frames: 2
Barbell Row - Transition: bottom → ascending
Row Debug - State: ascending, Angle: 108.2°, Velocity: 3.8°, Frames: 0
Row Debug - State: ascending, Angle: 125.7°, Velocity: 4.5°, Frames: 0
Row Debug - State: ascending, Angle: 137.1°, Velocity: 3.2°, Frames: 1
Row Debug - State: ascending, Angle: 141.6°, Velocity: 2.1°, Frames: 2
Barbell Row - Transition: ascending → standing
```

**If it's getting stuck, the logs will show WHERE and WHY!**

---

## If Still Stuck

### **Check the console logs to see:**

1. **What angle is it getting stuck at?**
   - If stuck in "pulling" at 100°, need higher bottom threshold
   - If stuck in "extending" at 140°, need lower standing threshold

2. **What's the velocity?**
   - If velocity > 15° when trying to detect bottom, increase velocity limit
   - If fluctuating too much, need more smoothing

3. **Is it reaching the angles?**
   - If never reaching 95° for bottom, bottom threshold too low
   - If never reaching 135° for lockout, standing threshold too high

---

## Emergency Further Adjustments

### **Make It Even More Lenient:**

```dart
'row': ExerciseConfig(
  standingThreshold: 140.0,  // Even lower
  bottomThreshold: 80.0,     // Even higher
)
```

### **Increase Buffers Even More:**

In `rep_counter.dart`:
```dart
// Standing → Descent
if (_smoothedAngle < config.standingThreshold - 25)  // Was 20

// Descent → Bottom
if (_smoothedAngle <= config.bottomThreshold + 25 && velocity < 20.0)  // Was 20, 15

// Ascending → Standing
if (_smoothedAngle >= config.standingThreshold - 20)  // Was 15
```

---

## Comparison: All Exercises

| Exercise | Standing | Bottom | Standing Buffer | Bottom Buffer |
|----------|----------|--------|-----------------|---------------|
| Squat | 170° | 95° | -20° | +20° |
| Bench | 165° | 70° | -20° | +20° |
| **Row** | **150°** | **75°** | **-20°** | **+20°** |
| Overhead | 140° | 100° | -20° | +20° |

**Row has the LOWEST standing threshold** - easiest extension detection!

---

## Summary

✅ **Standing threshold:** 160° → **150°** (10° easier)
✅ **Bottom threshold:** 70° → **75°** (5° higher)
✅ **All buffers increased** - Much more forgiving
✅ **Debug logging added** - Can diagnose issues
✅ **Velocity limit:** Up to 15°/frame

**What changed:**
- Accepts 135°+ as extended (vs 145°+)
- Detects pull at 95° (vs 85°)
- Much wider tolerances throughout

**Test it and check the console logs!** They'll tell you exactly where it's getting stuck if it still has issues. 📊
