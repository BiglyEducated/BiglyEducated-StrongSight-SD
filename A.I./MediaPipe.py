import cv2
import time
import math
import os
from mediapipe import Image, ImageFormat, tasks
import subprocess

# Webcam
cap = cv2.VideoCapture(2)
if not cap.isOpened():
    print("Error: Could not open webcam.")
    exit()

# Pose Landmarker setup
BaseOptions = tasks.BaseOptions
PoseLandmarker = tasks.vision.PoseLandmarker
PoseLandmarkerOptions = tasks.vision.PoseLandmarkerOptions
VisionRunningMode = tasks.vision.RunningMode

# Global variable to hold last result
last_result = None

def print_result(result, output_image, timestamp_ms):
    global last_result
    last_result = result

# Define skeleton connections
POSE_CONNECTIONS = [
    (11, 13), (13, 15),   # left arm
    (12, 14), (14, 16),   # right arm
    (11, 12),             # shoulders
    (23, 24),             # hips
    (11, 23), (12, 24),   # torso
    (23, 25), (25, 27),   # left leg
    (24, 26), (26, 28),   # right leg
    (27, 29), (29, 31),   # left lower leg/foot
    (28, 30), (30, 32),   # right lower leg/foot
]

# Function to calculate angle between 3 points
def calculate_angle(a, b, c):
    ang = math.degrees(
        math.atan2(c.y - b.y, c.x - b.x) -
        math.atan2(a.y - b.y, a.x - b.x)
    )
    ang = abs(ang)
    if ang > 180:
        ang = 360 - ang
    return ang

# # Sound function
# def ding():
#     if os.path.exists("bingchilling.mp3"):
#         subprocess.Popen(["afplay", "bingchilling.mp3"])
#     else:
#         subprocess.Popen(["afplay", "/System/Library/Sounds/Glass.aiff"])

# Squat state
squat_down = False
squat_count = 0

# Valid frame tracking
valid_frames = 0
required_frames = 4  # less strict: must see good pose for 2 frames
visibility_threshold = 0.4  # less strict

options = PoseLandmarkerOptions(
    base_options=BaseOptions(
        model_asset_path="/Users/jaydenskarbek/StrongSight/pose_landmarker_lite.task"
    ),
    running_mode=VisionRunningMode.LIVE_STREAM,
    result_callback=print_result
)

with PoseLandmarker.create_from_options(options) as landmarker:
    while True:
        ret, frame = cap.read()
        if not ret:
            print("Error: Could not read frame.")
            break

        frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        frame_timestamp_ms = int(time.time() * 1000)

        # Convert OpenCV frame to MediaPipe Image
        mp_image = Image(image_format=ImageFormat.SRGB, data=frame_rgb)

        # Run async landmark detection
        landmarker.detect_async(mp_image, frame_timestamp_ms)

        # Draw joints & skeleton
        if last_result and last_result.pose_landmarks:
            landmarks = last_result.pose_landmarks[0]  # first person
            h, w, _ = frame.shape

            # ---- Visibility + Multi-frame filter ----
            key_ids = [11, 12, 23, 24, 25, 26, 27, 28]  # shoulders, hips, knees, ankles
            visible_joints = sum(landmarks[i].visibility > visibility_threshold for i in key_ids)
            if visible_joints >= 6:  # allow 2 joints to be partially occluded
                valid_frames += 1
            else:
                valid_frames = max(valid_frames - 1, 0)  # smooth decay

            if valid_frames < required_frames:
                cv2.putText(frame, "Stabilizing...", (30, 150),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 0, 255), 2)
                cv2.imshow("Webcam Feed", frame)
                if cv2.waitKey(1) & 0xFF == ord("q"):
                    break
                continue
            # -------------------------------------------------------

            # Draw joints
            for lm in landmarks:
                cx, cy = int(lm.x * w), int(lm.y * h)
                cv2.circle(frame, (cx, cy), 4, (0, 255, 0), -1)

            # Draw skeleton connections
            for start, end in POSE_CONNECTIONS:
                if start < len(landmarks) and end < len(landmarks):
                    x1, y1 = int(landmarks[start].x * w), int(landmarks[start].y * h)
                    x2, y2 = int(landmarks[end].x * w), int(landmarks[end].y * h)
                    cv2.line(frame, (x1, y1), (x2, y2), (0, 255, 255), 2)

            # -------- Improved Squat detection --------
            # Left leg
            l_hip, l_knee, l_ankle = landmarks[23], landmarks[25], landmarks[27]
            l_angle = calculate_angle(l_hip, l_knee, l_ankle)

            # Right leg
            r_hip, r_knee, r_ankle = landmarks[24], landmarks[26], landmarks[28]
            r_angle = calculate_angle(r_hip, r_knee, r_ankle)

            # Shoulders and hips for relative position
            l_shoulder, r_shoulder = landmarks[11], landmarks[12]
            avg_shoulder_y = (l_shoulder.y + r_shoulder.y) / 2
            avg_hip_y = (l_hip.y + r_hip.y) / 2

            # Display angles
            cv2.putText(frame, f"L: {int(l_angle)} R: {int(r_angle)}", (30, 50),
                        cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 0, 0), 2)

            # Condition: both knees bent + hips lowered
            if l_angle < 80 and r_angle < 80 and avg_hip_y > avg_shoulder_y + 0.1:
                squat_down = True

            # When standing back up
            if squat_down and l_angle > 160 and r_angle > 160:
                squat_down = False
                squat_count += 1
                print("Squat detected!", squat_count)
                #ding()

            # Show squat count
            cv2.putText(frame, f"Squats: {squat_count}", (30, 100),
                        cv2.FONT_HERSHEY_SIMPLEX, 1.2, (0, 0, 255), 3)

        # Show frame
        cv2.imshow("Webcam Feed", frame)
        if cv2.waitKey(1) & 0xFF == ord("q"):
            break

cap.release()
cv2.destroyAllWindows()







