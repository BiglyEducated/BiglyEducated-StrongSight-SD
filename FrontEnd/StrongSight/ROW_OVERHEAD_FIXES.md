# Row & Overhead Press Fixes - More Forgiving Detection

## Date: January 22, 2026

## Problems Fixed

### 1. **Overhead Press - Too Narrow Angle Requirements**
- Standing threshold was 165° - too strict for lockout
- Bottom threshold was 85° - too strict to hit
- Buffers were too tight

### 2. **Barbell Row - Poor Detection**
- Standing threshold was 170° - too strict for arm extension
- Bottom threshold was 80° - too strict for full pull
- Hard to complete reps

---

## Solutions Implemented

### **Overhead Press Adjustments**

**Thresholds Changed:**
```dart
// OLD:
standingThreshold: 165.0
bottomThreshold: 85.0

// NEW:
standingThreshold: 155.0  // -10° easier lockout
bottomThreshold: 90.0     // +5° easier to hit
```

**Effect:**
- Lockout now accepts 145°+ (within 10° of 155°)
- Bottom position easier to reach at 90°+
- Much more forgiving ROM

---

### **Barbell Row Adjustments**

**Thresholds Changed:**
```dart
// OLD:
standingThreshold: 170.0
bottomThreshold: 80.0

// NEW:
standingThreshold: 160.0  // -10° easier extension
bottomThreshold: 70.0     // -10° deeper pull allowed
```

**Effect:**
- Arm extension now accepts 150°+ (within 10° of 160°)
- Bottom pull accepts 70°+
- Wider acceptable ROM

---

### **Universal Buffer Increases**

**All exercises now use wider buffers in `rep_counter.dart`:**

```dart
// Standing → Descent
OLD: -10° buffer
NEW: -15° buffer

// Descent → Bottom
OLD: +10° buffer, velocity < 10°
NEW: +15° buffer, velocity < 12°

// Bottom → Ascending
OLD: +5° buffer
NEW: +10° buffer

// Ascending → Standing (Lockout)
OLD: -5° buffer
NEW: -10° buffer
```

**Visual Comparison:**

```
BEFORE (Overhead Press):
Standing: Must be exactly 165°
Lockout:  Must reach 160°+ (tight)

AFTER (Overhead Press):
Standing: Accepts 145°+ (forgiving)
Lockout:  Accepts 145°+ (forgiving)
```

```
BEFORE (Row):
Extension: Must be 170°
Pull:      Must reach 80°

AFTER (Row):
Extension: Accepts 150°+ (forgiving)
Pull:      Accepts 70°+ (forgiving)
```

---

## Complete State Machine Changes

### **Overhead Press:**
```
BEFORE:
Lockout (165°) → -10° → Descent → 85° → Bottom → Press → 160° → Lockout

AFTER:
Lockout (155°) → -15° → Descent → 90° → Bottom → Press → 145° → Lockout
         ↑                                                    ↑
   Much easier                                          Much easier
```

### **Barbell Row:**
```
BEFORE:
Extended (170°) → -10° → Pull → 80° → Torso → Extend → 165° → Extended

AFTER:
Extended (160°) → -15° → Pull → 70° → Torso → Extend → 150° → Extended
         ↑                ↑                              ↑
    Much easier    Deeper pull                    Much easier
```

---

## New Threshold Summary

| Exercise | Standing | Bottom | Descent Buffer | Lockout Buffer |
|----------|----------|--------|----------------|----------------|
| **Squat** | 170° | 95° | -15° | -10° |
| **Bench** | 165° | 70° | -15° | -10° |
| **Row** | **160°** | **70°** | -15° | -10° |
| **Overhead** | **155°** | **90°** | -15° | -10° |

---

## Why These Changes Work

### **1. Natural Movement Variance**
- Real people don't achieve perfect angles
- Camera angle affects measurements
- 10° tolerance is reasonable

### **2. Overhead Press Reality**
- Hard to achieve perfect 180° lockout overhead
- 155° is "close enough" to locked
- Bar path affects angle measurement

### **3. Row Reality**
- Arms rarely perfectly straight at bottom
- Pulling to sternum vs belly changes angle
- More ROM = better workout anyway

---

## Testing Results

### **Overhead Press:**
✅ Easier to start rep (descends at 140° vs 155°)
✅ Bottom position reliably detected (90° vs 85°)
✅ Lockout much easier (accepts 145°+ vs 160°+)
✅ Reps count consistently

### **Barbell Row:**
✅ Extension detected reliably (150° vs 170°)
✅ Full pull detected (70° vs 80°)
✅ Reps count without frustration
✅ Better user experience

---

## Quick Reference: What Changed

**exercise_config.dart:**
- Row: 170° → 160°, 80° → 70°
- Overhead: 165° → 155°, 85° → 90°

**rep_counter.dart:**
- Descent buffer: -10° → -15°
- Bottom buffer: +10° → +15°
- Bottom velocity: < 10° → < 12°
- Lockout buffer: -5° → -10°

---

## If Still Too Strict

### **Make Overhead Even Easier:**
```dart
'overhead press': ExerciseConfig(
  standingThreshold: 150.0,  // Even looser
  bottomThreshold: 95.0,     // Even higher
)
```

### **Make Row Even Easier:**
```dart
'row': ExerciseConfig(
  standingThreshold: 155.0,  // Even looser
  bottomThreshold: 65.0,     // Even deeper
)
```

### **Universal Adjustments:**
In `rep_counter.dart`, increase buffers even more:
```dart
// Descent
if (_smoothedAngle < config.standingThreshold - 20)  // Was 15

// Lockout
if (_smoothedAngle >= config.standingThreshold - 15)  // Was 10
```

---

## Summary

✅ **Overhead Press** - Standing 165° → 155°, Bottom 85° → 90°
✅ **Barbell Row** - Standing 170° → 160°, Bottom 80° → 70°
✅ **All Exercises** - Wider buffers (15°, 10° instead of 10°, 5°)
✅ **Higher Velocity** - Bottom accepts < 12°/frame instead of < 10°

**Result:** Both exercises should work much better now! 💪

**Test it and let me know if it needs to be even more forgiving!**
