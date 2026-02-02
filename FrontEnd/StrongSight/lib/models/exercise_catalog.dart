// ------------ Equipment Definition ----------------
enum EquipmentType {
  barbell,
  dumbbell,
  machine,
  cable,
  bodyweight,
  kettlebell,
  bench,
  pullupBar,
  mat,
}

// ------------ Exercise Definition ----------------

class ExerciseDefinition {
  final String id;
  final String name;
  final String image;
  final List<String> muscles;
  final List<EquipmentType> equipment;
  final List<String> formCues;

  const ExerciseDefinition({
    required this.id,
    required this.name,
    required this.image,
    required this.muscles,
    required this.equipment,
    required this.formCues,
  });
}


// ------------ Exercise Catalog ----------------

const List<ExerciseDefinition> exerciseCatalog = [

  ExerciseDefinition(
    id: 'squat',
    name: 'Squat',
    image: 'assets/images/Squat.png',
    muscles: ['Quadriceps', 'Glutes', 'Hamstrings', 'Core'],
    equipment: [EquipmentType.barbell, EquipmentType.bodyweight, EquipmentType.dumbbell, EquipmentType.kettlebell, EquipmentType.machine],
    formCues: [
      'Stand with feet shoulder-width apart and toes slightly pointed out.',
      'Keep chest up and core tight.',
      'Lower hips down and back until thighs are parallel to the floor.',
      'Push through heels to return to the starting position.',
    ],
  ),

  ExerciseDefinition(
    id: 'bench_press',
    name: 'Bench Press',
    image: 'assets/images/BenchPress.png',
    muscles: ['Chest', 'Shoulders', 'Triceps'],
    equipment: [EquipmentType.barbell],
    formCues: [
      'Lie flat on a bench with your feet planted on the floor.',
      'Grip the bar slightly wider than shoulder width.',
      'Lower the bar slowly to mid-chest level.',
      'Push the bar back up until your arms are fully extended.',
    ],
  ),

  ExerciseDefinition(
    id: 'deadlift',
    name: 'Deadlift',
    image: 'assets/images/Deadlift.png',
    muscles: ['Hamstrings', 'Glutes', 'Back', 'Core', 'Forearms'],
    equipment: [EquipmentType.barbell],
    formCues: [
      'Stand with feet hip-width apart and barbell over mid-foot.',
      'Bend at the hips and knees, keeping your back straight.',
      'Grip the bar just outside your knees.',
      'Drive through your heels, extending hips and knees to lift the bar.',
      'Lower under control by hinging at the hips.',
    ],
  ),

  ExerciseDefinition(
    id: 'bicep_curl',
    name: 'Bicep Curl',
    image: 'assets/images/BicepCurl.png',
    muscles: ['Biceps', 'Forearms'],
    equipment: [EquipmentType.dumbbell],
    formCues: [
      'Stand tall with arms fully extended and elbows close to torso.',
      'Curl the weight upward while contracting your biceps.',
      'Pause at the top, then slowly lower the weight back down.',
      'Avoid swinging your body during the motion.',
    ],
  ),

  ExerciseDefinition(
    id: 'lat_pulldown',
    name: 'Lat Pulldown',
    image: 'assets/images/LatPulldown.png',
    muscles: ['Lats', 'Biceps', 'Rear Delts'],
    equipment: [EquipmentType.cable],
    formCues: [
      'Sit down at a lat pulldown station and grab the bar with a wide overhand grip.',
      'Keep your chest tall and engage your core.',
      'Pull the bar down to your upper chest, squeezing your shoulder blades together.',
      'Pause briefly, then slowly return to the starting position with control.',
    ],
  ),

  ExerciseDefinition(
    id: 'pull_up',
    name: 'Pull-up',
    image: 'assets/images/PullUp.png',
    muscles: ['Lats', 'Biceps', 'Forearms', 'Core'],
    equipment: [EquipmentType.pullupBar],
    formCues: [
      'Grab the pull-up bar with an overhand grip slightly wider than shoulder width.',
      'Hang fully extended, then pull yourself upward until your chin clears the bar.',
      'Pause briefly at the top, then lower yourself down with control.',
      'Avoid swinging or using momentum.',
    ],
  ),

  ExerciseDefinition(
    id: 'push_up',
    name: 'Push-up',
    image: 'assets/images/PushUp.png',
    muscles: ['Chest', 'Shoulders', 'Triceps', 'Core'],
    equipment: [EquipmentType.bodyweight],
    formCues: [
      'Place your hands slightly wider than shoulder-width.',
      'Keep your body straight from head to heels.',
      'Lower your chest toward the floor until elbows reach 90°.',
      'Push back up through your palms.',
    ],
  ),

  ExerciseDefinition(
    id: 'sit_up',
    name: 'Sit-up',
    image: 'assets/images/SitUp.png',
    muscles: ['Abdominals', 'Hip Flexors'],
    equipment: [EquipmentType.mat],
    formCues: [
      'Lie flat with knees bent and feet anchored.',
      'Engage your core to lift your upper body.',
      'Lower yourself back down slowly.',
    ],
  ),

  ExerciseDefinition(
    id: 'shoulder_press_db',
    name: 'Dumbbell Shoulder Press',
    image: 'assets/images/ShoulderPress.png',
    muscles: ['Deltoids', 'Triceps', 'Upper Chest'],
    equipment: [EquipmentType.dumbbell],
    formCues: [
      'Hold dumbbells at shoulder height.',
      'Press the weights overhead until arms are fully extended.',
      'Lower back to shoulder height with control.',
    ],
  ),

  ExerciseDefinition(
    id: 'plank',
    name: 'Plank',
    image: 'assets/images/Plank.png',
    muscles: ['Core', 'Shoulders', 'Back', 'Glutes'],
    equipment: [EquipmentType.mat],
    formCues: [
      'Rest on forearms in a straight line.',
      'Engage abs and glutes.',
      'Do not let hips sag.',
    ],
  ),

  ExerciseDefinition(
    id: 'lunges',
    name: 'Lunges',
    image: 'assets/images/Lunges.png',
    muscles: ['Glutes', 'Quads', 'Hamstrings'],
    equipment: [EquipmentType.bodyweight],
    formCues: [
      'Step forward and lower until both knees are at 90°.',
      'Push through front heel to return to standing.',
      'Alternate legs.',
    ],
  ),

  ExerciseDefinition(
    id: 'tricep_dips',
    name: 'Tricep Dips',
    image: 'assets/images/TricepDip.png',
    muscles: ['Triceps', 'Chest', 'Shoulders'],
    equipment: [EquipmentType.bench],
    formCues: [
      'Lower body by bending elbows.',
      'Press back up keeping chest lifted.',
    ],
  ),

  ExerciseDefinition(
    id: 'seated_cable_row',
    name: 'Seated Cable Row',
    image: 'assets/images/SeatedRow.png',
    muscles: ['Lats', 'Rhomboids', 'Biceps'],
    equipment: [EquipmentType.cable],
    formCues: [
      'Pull handle toward torso.',
      'Squeeze shoulder blades together.',
      'Extend arms forward slowly.',
    ],
  ),

  ExerciseDefinition(
    id: 'leg_press',
    name: 'Leg Press',
    image: 'assets/images/LegPress.png',
    muscles: ['Quads', 'Glutes', 'Hamstrings'],
    equipment: [EquipmentType.machine],
    formCues: [
      'Lower platform until knees reach 90°.',
      'Push through heels.',
    ],
  ),

  ExerciseDefinition(
    id: 'calf_raises',
    name: 'Calf Raises',
    image: 'assets/images/CalfRaise.png',
    muscles: ['Calves'],
    equipment: [EquipmentType.bodyweight],
    formCues: [
      'Raise heels as high as possible.',
      'Lower heels for full stretch.',
    ],
  ),

  ExerciseDefinition(
    id: 'russian_twists',
    name: 'Russian Twists',
    image: 'assets/images/RussianTwist.png',
    muscles: ['Obliques', 'Core'],
    equipment: [EquipmentType.bodyweight],
    formCues: [
      'Twist torso side to side.',
      'Engage obliques.',
    ],
  ),

  ExerciseDefinition(
    id: 'burpees',
    name: 'Burpees',
    image: 'assets/images/Burpees.png',
    muscles: ['Chest', 'Legs', 'Core', 'Shoulders'],
    equipment: [EquipmentType.bodyweight],
    formCues: [
      'Squat down and place hands on floor.',
      'Jump to plank, do push-up.',
      'Jump feet forward and explode upward.',
    ],
  ),

  ExerciseDefinition(
    id: 'kettlebell_swings',
    name: 'Kettlebell Swings',
    image: 'assets/images/KettlebellSwing.png',
    muscles: ['Glutes', 'Hamstrings', 'Core', 'Shoulders'],
    equipment: [EquipmentType.kettlebell],
    formCues: [
      'Hinge at hips.',
      'Drive hips forward to swing bell.',
      'Control descent.',
    ],
  ),

  ExerciseDefinition(
    id: 'mountain_climbers',
    name: 'Mountain Climbers',
    image: 'assets/images/MountainClimber.png',
    muscles: ['Core', 'Shoulders', 'Hip Flexors'],
    equipment: [EquipmentType.bodyweight],
    formCues: [
      'Drive knees toward chest alternately.',
      'Keep back straight.',
    ],
  ),
];
