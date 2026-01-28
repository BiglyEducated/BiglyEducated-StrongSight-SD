# Deadlift Support Added

## Date: January 22, 2026

## What Was Added

Deadlift is now fully supported with rep counting and exercise-specific feedback!

---

## Deadlift Configuration

```dart
'deadlift': ExerciseConfig(
  name: "Deadlift",
  vertexJoint: PoseLandmarkType.leftHip,         // Track hip angle
  pointA: PoseLandmarkType.leftShoulder,         // Shoulder-Hip-Knee angle
  pointB: PoseLandmarkType.leftKnee,
  standingThreshold: 165.0,  // Standing upright (reduced from 175)
  bottomThreshold: 120.0,    // Bar at floor (increased from 115)
  optimalAngle: "Side (90°)",
  cameraHeight: "Hip Height",
)
```

---

## How Deadlift Works

### **Joint Tracking:**
- Tracks **hip angle** (Shoulder → Hip → Knee)
- This detects hip hinge movement
- Different from all other exercises (which track elbow or knee)

### **State Machine:**
```
STANDING UPRIGHT (165°+)
    ↓ Hinge to 145° (20° buffer)
    
LOWERING BAR (145° → 140°)
    ↓ Reach 140° (120° + 20° buffer) with low velocity
    
BAR AT FLOOR (~120°)
    ↓ Hip extends past 135° (120° + 15° buffer)
    
LIFTING (135° → 150°)
    ↓ Reach 150° (165° - 15° buffer)
    
STANDING UPRIGHT → REP COUNTED! ✅
```

### **Thresholds:**
- Standing: 165° (hips fully extended)
- Bottom: 120° (hinged at hips, bar at floor)
- Buffers: -20° descent, -15° lockout

---

## Deadlift Phase Names

**Phases:**
- **Standing** → "standing upright"
- **Descent** → "lowering bar"
- **Bottom** → "bar at floor"
- **Ascending** → "lifting"

**Feedback Messages:**
- Descent: "Lowering... hinge at hips!"
- Bottom: "Touch the floor! Now drive up!"
- Ascending: "Drive! Push the floor!"
- Complete: "Lockout complete! Next rep."

---

## Camera Setup for Deadlift

**Recommended:**
- **View:** Side (90° angle)
- **Height:** Hip level
- **Distance:** 2-3 meters
- **Visibility:** See full body, hip hinge clearly

**Why side view?**
- Can see hip hinge angle
- Can detect lockout position
- Better view of full ROM

**Setup:**
```
        YOU (deadlifting)
         |
         |
    Camera ← 90° to your side
    (2-3 meters away, hip height)
```

---

## What Deadlift Doesn't Check (Yet)

Currently deadlift has:
- ✅ Rep counting
- ✅ Phase detection
- ✅ Exercise-specific feedback
- ❌ No form checks (could add later)

**Potential form checks to add later:**
- Back rounding detection
- Hip shooting up too fast
- Bar path deviation
- Shoulder position

---

## UI Example for Deadlift

```
┌─────────────────────────────┐
│  Reps: 5                    │
│  Drive! Push the floor!     │  ← Deadlift-specific feedback
│  Phase: lifting             │  ← Deadlift-specific phase
└─────────────────────────────┘
```

---

## Complete Deadlift Cycle

### **1. Start Position**
- Standing upright (~165°)
- Hips extended

### **2. Lower to Bar**
- Hinge at hips
- Angle decreases to ~145°
- Detects "lowering bar"

### **3. Touch Floor**
- Reach ~140° (120° + buffer)
- Detects "bar at floor"

### **4. Pull**
- Hip extends past 135°
- Detects "lifting"

### **5. Lockout**
- Reach ~150° (within 15° of 165°)
- **Rep counted!**

---

## Comparison: Hip Tracking vs Other Exercises

| Exercise | Joint Tracked | Measurement |
|----------|---------------|-------------|
| **Squat** | Knee | Hip-Knee-Ankle |
| **Bench** | Elbow | Shoulder-Elbow-Wrist |
| **Row** | Elbow | Shoulder-Elbow-Wrist |
| **Overhead** | Elbow | Shoulder-Elbow-Wrist |
| **Deadlift** | **Hip** | **Shoulder-Hip-Knee** |

**Deadlift is unique** - only exercise tracking hip hinge!

---

## Threshold Summary

| Exercise | Standing | Bottom | Camera View |
|----------|----------|--------|-------------|
| Squat | 170° | 95° | Front |
| Bench | 165° | 70° | Side (45°) |
| Row | 150° | 75° | Side (90°) |
| Overhead | 140° | 100° | Front |
| **Deadlift** | **165°** | **120°** | **Side (90°)** |

---

## Testing Checklist

### **Test Rep Counting:**
- ✅ Stand upright → "standing upright"
- ✅ Hinge at hips → "lowering bar"
- ✅ Touch floor → "bar at floor"
- ✅ Pull bar up → "lifting"
- ✅ Lock out → Counts rep

### **Expected Angles:**
- Start: ~165-170° (standing)
- Bottom: ~120-130° (hinged)
- Should cycle smoothly through all phases

---

## If Angles Are Off

### **Too Strict (Not Counting Reps):**
```dart
'deadlift': ExerciseConfig(
  standingThreshold: 160.0,  // Lower threshold
  bottomThreshold: 125.0,    // Higher threshold
)
```

### **Too Lenient (Counting Too Early):**
```dart
'deadlift': ExerciseConfig(
  standingThreshold: 170.0,  // Higher threshold
  bottomThreshold: 115.0,    // Lower threshold
)
```

---

## Complete Exercise Support

| Exercise | Status | Form Checks | Phase Names | Messages |
|----------|--------|-------------|-------------|----------|
| **Squat** | ✅ Full | ✅ (3) | ✅ | ✅ |
| **Bench Press** | ✅ Full | ✅ (2) | ✅ | ✅ |
| **Barbell Row** | ✅ Full | ✅ (1) | ✅ | ✅ |
| **Overhead Press** | ✅ Full | ✅ (1) | ✅ | ✅ |
| **Deadlift** | ✅ Basic | ❌ (0) | ✅ | ✅ |
| **Bicep Curls** | ⏳ Config | ❌ (0) | ❌ | ❌ |

**5 out of 6 exercises working!** 💪

---

## Summary

✅ **Deadlift** fully integrated
✅ Rep counting works (hip angle tracking)
✅ Deadlift-specific phase names
✅ Deadlift-specific feedback messages
✅ Uses same responsive 2-frame threshold
✅ Forgiving thresholds (165° standing, 120° bottom)

**To use:** Select "Deadlift" from the workout page dropdown!

**Camera setup:** Side view at 90°, hip height, 2-3 meters away.

---

## Next Steps (Optional)

Could add form checks for deadlift:
- Back rounding (check spine angle)
- Hip shoot (hip rising faster than shoulders)
- Bar path (should stay close to body)

But basic rep counting should work great for now! 🏋️
