# Overhead Press Support

## What Was Added
Overhead press with rep counting and form checking.

## Configuration
- Tracks elbow angle (Shoulder-Elbow-Wrist)
- Standing: 165° (arms locked overhead)
- Bottom: 90° (bar at shoulders) - **FIXED from 10°!**

## Major Bug Fix
Original config had `bottomThreshold: 10.0` which is completely wrong!
- 10° = elbows nearly straight, bar above head
- 90° = elbows at right angle, bar at shoulders ✅

## Phase Names
- "locked overhead" → "lowering" → "bar at shoulders" → "pressing overhead"

## Feedback Messages
- "Lowering... stay tight!"
- "Bar at shoulders! Drive up!"
- "Press overhead! Lock it out!"
- "Locked overhead! Next rep."

## Form Checking
- Symmetry check only (same as row)

## State Machine
```
Locked Overhead (165°) → Lowering → Bar at Shoulders (90°) → Pressing → Locked! ✅
```

## Summary
✅ 4 exercises complete: Squat, Bench, Row, Overhead
✅ All use 2-frame responsive detection
✅ Exercise-specific phases and messages
