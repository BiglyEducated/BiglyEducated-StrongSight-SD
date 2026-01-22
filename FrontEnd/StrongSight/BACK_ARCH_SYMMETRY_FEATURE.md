# Back Arch & Symmetry Checker - Feature Summary

## Date: January 19, 2026

## New Features Added

### 1. **Back Arch/Rounding Detection** 🆕

Detects excessive back arch (hyperextension) or rounded back (flexion) during squats.

**How it works:**
- Calculates angle formed by Shoulder → Hip → Knee
- Checks if back angle is within safe range (160° - 190°)
- Flags errors that persist for 3+ frames

**Error Types:**

#### Rounded Back (Butt Wink)
- **Angle:** < 160°
- **Message:** "⚠️ ROUNDED BACK - Keep chest up!"
- **Severity:** DANGER (could cause lower back injury)
- **Common cause:** Going too deep, lack of mobility

#### Excessive Arch
- **Angle:** > 190°
- **Message:** "⚠️ EXCESSIVE ARCH - Neutral spine!"
- **Severity:** DANGER (could cause lower back strain)
- **Common cause:** Over-correcting posture, improper bracing

---

### 2. **Improved Symmetry Detection** 🆕

Detects uneven movement between left and right legs during squats.

**How it works:**
- Calculates knee angle for BOTH left and right sides
- Compares angles between sides
- Flags if difference exceeds 15°

**Error Detection:**
- **Threshold:** 15° difference between left/right knee angles
- **Message:** "⚠️ UNEVEN - Balance both sides!"
- **Severity:** WARNING (could lead to muscle imbalances)
- **Common causes:** 
  - Previous injury favoring one side
  - Weak glute on one side
  - Ankle mobility difference

**Old vs New:**
```
OLD: Only checked horizontal distance between knees
NEW: Compares actual knee angles on both sides (much more accurate!)
```

---

### 3. **Smart Form Check Priority System** 🆕

The app now checks ALL form errors and shows the most important one first.

**Priority Order:**
1. **DANGER errors** (Back issues) - shown first, most critical
2. **WARNING errors** (Knee cave, Asymmetry) - shown next
3. **INFO messages** (Low confidence) - shown last

**Example:**
If you have BOTH knee cave AND rounded back, the app will show rounded back first because it's more dangerous!

---

## Updated Code Structure

### `form_checker.dart` Changes:

**New Methods:**
```dart
checkBackArch(pose, state)     // NEW - detects back arch/rounding
checkSymmetry(pose, state)     // IMPROVED - now uses angles
checkAllSquatForm(pose, state) // NEW - checks everything at once
```

**New State Tracking:**
```dart
_backArchFrameCount      // Tracks back arch consistency
_asymmetryFrameCount     // Tracks symmetry issues
```

**New Constants:**
```dart
_backArchAngleMin = 160.0       // Min safe back angle
_backArchAngleMax = 190.0       // Max safe back angle  
_asymmetryAngleDiff = 15.0      // Max angle difference between sides
```

**New Error Types:**
```dart
FormErrorType.backArch      // Excessive arch
FormErrorType.backRounding  // Rounded back
```

---

## Configuration Values

### Back Arch Thresholds
```dart
Minimum angle: 160° (below = rounded back)
Maximum angle: 190° (above = excessive arch)
Frame threshold: 3 frames (must persist ~0.3 seconds)
```

### Symmetry Thresholds
```dart
Max angle difference: 15° (between left/right knees)
Frame threshold: 3 frames
```

### Knee Cave (Existing)
```dart
Ratio threshold: 0.75 (knee distance / ankle distance)
Frame threshold: 3 frames
```

---

## How Form Checks Work During Squat

### State-Based Detection
All form checks only run during **relevant phases**:
- ✅ **Descent** - All checks active
- ✅ **Bottom** - All checks active
- ❌ **Standing** - Checks reset/disabled
- ❌ **Ascending** - Checks reset/disabled

This prevents false positives during transitions!

---

## Visual Feedback in App

The app now shows different colored feedback based on severity:

### Colors:
- **Red** - Danger errors (back arch/rounding)
- **Red** - Warning errors (knee cave, asymmetry)
- **Green** - Normal feedback
- **White** - Phase indicator

### Display Priority:
1. If back issue → Show back error (DANGER)
2. Else if knee cave → Show knee cave (WARNING)
3. Else if asymmetry → Show asymmetry (WARNING)
4. Else → Show rep counter feedback

---

## Testing the New Features

### Test Back Arch Detection:

**Test Rounded Back:**
1. Do a squat
2. Intentionally round your lower back at the bottom
3. Should see: "⚠️ ROUNDED BACK - Keep chest up!"

**Test Excessive Arch:**
1. Do a squat
2. Push chest forward excessively (hyperextend)
3. Should see: "⚠️ EXCESSIVE ARCH - Neutral spine!"

### Test Symmetry Detection:

**Test Uneven Squat:**
1. Do a squat
2. Favor one leg (go deeper on one side)
3. Should see: "⚠️ UNEVEN - Balance both sides!"

### Test Priority System:

**Test Multiple Errors:**
1. Do a squat with rounded back AND knee cave
2. Should see back error first (higher priority)
3. Fix back, should then see knee cave error

---

## Biomechanical Background

### Why Back Angle Matters:
- **Neutral spine** maintains natural lumbar curve
- **Rounded back** (flexion) = posterior pelvic tilt = disc compression
- **Excessive arch** (hyperextension) = anterior pelvic tilt = facet joint stress

### Why Symmetry Matters:
- **Uneven loading** can lead to:
  - Muscle imbalances
  - Joint stress
  - Compensation patterns
  - Increased injury risk

### Measurement Points:
```
Back Angle: Shoulder → Hip → Knee
  - Measures torso alignment relative to thighs
  - Accounts for squat depth automatically
  
Symmetry: Left knee angle vs Right knee angle
  - Hip-Knee-Ankle on both sides
  - Compares actual joint angles, not just position
```

---

## Adjusting Sensitivity

To make checks more/less sensitive, edit `lib/logic/form_checker.dart`:

### Make Back Check More Lenient:
```dart
static const double _backArchAngleMin = 155.0; // Was 160.0
static const double _backArchAngleMax = 195.0; // Was 190.0
```

### Make Back Check Stricter:
```dart
static const double _backArchAngleMin = 165.0; // Was 160.0
static const double _backArchAngleMax = 185.0; // Was 190.0
```

### Make Symmetry More Lenient:
```dart
static const double _asymmetryAngleDiff = 20.0; // Was 15.0
```

### Make Symmetry Stricter:
```dart
static const double _asymmetryAngleDiff = 10.0; // Was 15.0
```

### Change Frame Requirements:
```dart
static const int _backArchThresholdFrames = 5; // Was 3 (more strict)
static const int _asymmetryThresholdFrames = 5; // Was 3 (more strict)
```

---

## Benefits

### For Users:
✅ More comprehensive form feedback
✅ Prevents dangerous back injuries
✅ Catches subtle imbalances early
✅ Learns proper movement patterns

### For You (Development):
✅ Modular, easy to adjust
✅ Priority system is automatic
✅ Easy to add more checks later
✅ Well-documented thresholds

---

## Future Enhancements

Possible additions:
1. **Depth checker** - Flag shallow squats
2. **Bar path tracker** - Ensure vertical bar movement
3. **Tempo checker** - Flag too-fast descent
4. **Weight distribution** - Check if shifting forward/back
5. **Head position** - Ensure neutral neck

All would follow the same pattern as current checks!

---

## Summary

**3 form checks now active:**
1. ✅ Knee Cave (existing, improved)
2. 🆕 Back Arch/Rounding (NEW)
3. 🆕 Symmetry (NEW)

**Smart priority system ensures most dangerous errors show first!**

Test it out and adjust thresholds based on real-world feedback! 🚀
