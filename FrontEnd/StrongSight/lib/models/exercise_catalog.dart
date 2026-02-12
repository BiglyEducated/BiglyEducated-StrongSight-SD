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
  medicineBall,
  plate,
}

// ------------ Muscle types ----------------
enum Muscle {
  chest,
  lats,
  rhomboids,
  quadriceps,
  hamstrings,
  glutes,
  calves,
  biceps,
  triceps,
  deltoids,
  core,
  obliques,
  hipFlexors,
  forearms,
}


// ------------ Exercise Definition ----------------

class ExerciseDefinition {
  final String id;
  final String name;
  final String image;
  final List<Muscle> muscles;
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
    id: 'squats',
    name: 'Squat',
    image: 'assets/images/Squat.png',
    muscles: [Muscle.quadriceps, Muscle.glutes, Muscle.hamstrings, Muscle.core],
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
    muscles: [Muscle.chest, Muscle.triceps, Muscle.deltoids],
    equipment: [EquipmentType.barbell, EquipmentType.dumbbell, EquipmentType.machine],
    formCues: [
      'Lie flat on a bench with your feet planted on the floor.',
      'Grip the bar slightly wider than shoulder width.',
      'Lower the bar slowly to mid-chest level.',
      'Push the bar back up until your arms are fully extended.',
    ],
  ),

  ExerciseDefinition(
    id: 'deadlifts',
    name: 'Deadlift',
    image: 'assets/images/Deadlift.png',
    muscles: [Muscle.hamstrings, Muscle.glutes, Muscle.lats, Muscle.core, Muscle.quadriceps],
    equipment: [EquipmentType.barbell, EquipmentType.dumbbell],
    formCues: [
      'Stand with feet hip-width apart and barbell over mid-foot.',
      'Bend at the hips and knees, keeping your back straight.',
      'Grip the bar just outside your knees.',
      'Drive through your heels, extending hips and knees to lift the bar.',
      'Keep the bar close to your body throughout the lift without rounding your lower back.',
      'Lower under control by hinging at the hips.',
    ],
  ),

  ExerciseDefinition(
    id: 'bicep_curls',
    name: 'Bicep Curl',
    image: 'assets/images/BicepCurl.png',
    muscles: [Muscle.biceps, Muscle.forearms],
    equipment: [EquipmentType.dumbbell, EquipmentType.barbell, EquipmentType.cable, EquipmentType.machine],
    formCues: [
      'Stand tall with arms fully extended and elbows close to torso.',
      'Curl the weight upward while contracting your biceps.',
      'Pause at the top, then slowly lower the weight back down.',
      'Avoid swinging your body during the motion.',
    ],
  ),

  ExerciseDefinition(
    id: 'lat_pulldowns',
    name: 'Lat Pulldown',
    image: 'assets/images/LatPulldown.png',
    muscles: [Muscle.lats, Muscle.biceps, Muscle.rhomboids],
    equipment: [EquipmentType.cable, EquipmentType.machine],
    formCues: [
      'Sit down at a lat pulldown station and grab the bar with a wide overhand grip.',
      'Keep your chest tall and engage your core.',
      'Pull the bar down to your upper chest, squeezing your shoulder blades together.',
      'Pause briefly, then slowly return to the starting position with control.',
    ],
  ),

  ExerciseDefinition(
    id: 'pull_ups',
    name: 'Pull-up',
    image: 'assets/images/PullUp.png',
    muscles: [Muscle.lats, Muscle.biceps, Muscle.forearms, Muscle.core],
    equipment: [EquipmentType.pullupBar],
    formCues: [
      'Grab the pull-up bar with an overhand grip slightly wider than shoulder width.',
      'Hang fully extended, then pull yourself upward until your chin clears the bar.',
      'Pause briefly at the top, then lower yourself down with control.',
      'Avoid swinging or using momentum.',
    ],
  ),

  ExerciseDefinition(
    id: 'push_ups',
    name: 'Push-up',
    image: 'assets/images/PushUp.png',
    muscles: [Muscle.chest, Muscle.triceps, Muscle.deltoids, Muscle.core],
    equipment: [EquipmentType.bodyweight],
    formCues: [
      'Place your hands slightly wider than shoulder-width.',
      'Keep your body straight from head to heels.',
      'Lower your chest toward the floor until elbows reach 90°.',
      'Push back up through your palms.',
    ],
  ),

  ExerciseDefinition(
    id: 'sit_ups',
    name: 'Sit-up',
    image: 'assets/images/SitUp.png',
    muscles: [Muscle.core, Muscle.hipFlexors],
    equipment: [EquipmentType.bodyweight],
    formCues: [
      'Lie flat with knees bent and feet anchored.',
      'Engage your core to lift your upper body.',
      'Lower yourself back down slowly.',
    ],
  ),

  ExerciseDefinition(
    id: 'shoulder_press',
    name: 'Dumbbell Shoulder Press',
    image: 'assets/images/ShoulderPress.png',
    muscles: [Muscle.deltoids, Muscle.triceps, Muscle.chest],
    equipment: [EquipmentType.dumbbell, EquipmentType.barbell, EquipmentType.machine],
    formCues: [
      'Hold dumbbells at shoulder height.',
      'Press the weights overhead until arms are fully extended.',
      'Lower back to shoulder height with control.',
    ],
  ),

  ExerciseDefinition(
    id: 'planks',
    name: 'Plank',
    image: 'assets/images/Plank.png',
    muscles: [Muscle.core, Muscle.deltoids, Muscle.glutes],
    equipment: [EquipmentType.bodyweight],
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
    muscles: [Muscle.quadriceps, Muscle.glutes, Muscle.hamstrings, Muscle.core],
    equipment: [EquipmentType.bodyweight, EquipmentType.dumbbell, EquipmentType.barbell, EquipmentType.kettlebell],
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
    muscles: [Muscle.triceps, Muscle.chest, Muscle.deltoids],
    equipment: [EquipmentType.bench, EquipmentType.machine],
    formCues: [
      'Lower body by bending elbows.',
      'Press back up keeping chest lifted.',
    ],
  ),

  ExerciseDefinition(
    id: 'seated_cable_rows',
    name: 'Seated Cable Row',
    image: 'assets/images/SeatedRow.png',
    muscles: [Muscle.lats, Muscle.rhomboids, Muscle.biceps],
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
    muscles: [Muscle.quadriceps, Muscle.glutes, Muscle.hamstrings],
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
    muscles: [Muscle.calves],
    equipment: [EquipmentType.bodyweight, EquipmentType.machine, EquipmentType.dumbbell],
    formCues: [
      'Raise heels as high as possible.',
      'Lower heels for full stretch.',
    ],
  ),

  ExerciseDefinition(
    id: 'russian_twists',
    name: 'Russian Twists',
    image: 'assets/images/RussianTwist.png',
    muscles: [Muscle.obliques, Muscle.core],
    equipment: [EquipmentType.bodyweight, EquipmentType.medicineBall, EquipmentType.kettlebell, EquipmentType.plate],
    formCues: [
      'Twist torso side to side.',
      'Engage obliques.',
    ],
  ),

  ExerciseDefinition(
    id: 'burpees',
    name: 'Burpees',
    image: 'assets/images/Burpees.png',
    muscles: [Muscle.quadriceps, Muscle.glutes, Muscle.hamstrings, Muscle.chest, Muscle.deltoids, Muscle.core, Muscle.triceps, Muscle.biceps],
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
    muscles: [Muscle.hamstrings, Muscle.glutes, Muscle.core, Muscle.lats],
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
    muscles: [Muscle.core, Muscle.deltoids, Muscle.quadriceps, Muscle.glutes],
    equipment: [EquipmentType.bodyweight],
    formCues: [
      'Drive knees toward chest alternately.',
      'Keep back straight.',
    ],
  ),

  ExerciseDefinition(
    id: 'barbell_row',
    name: 'Barbell Row',
    image: 'assets/images/BarbellRow.png',
    muscles: [
      Muscle.lats,
      Muscle.rhomboids,
      Muscle.biceps,
      Muscle.forearms,
      Muscle.core,
    ],
    equipment: [EquipmentType.barbell],
    formCues: [
      'Hinge at the hips with a slight bend in the knees.',
      'Keep your back flat and chest slightly lifted.',
      'Pull the bar toward your lower ribcage.',
      'Squeeze shoulder blades together at the top.',
      'Lower the bar under control without rounding your back.',
    ],
  ),

  ExerciseDefinition(
    id: 'overhead_press',
    name: 'Overhead Press',
    image: 'assets/images/OverheadPress.png',
    muscles: [
      Muscle.deltoids,
      Muscle.triceps,
      Muscle.core,
      Muscle.chest,
    ],
    equipment: [EquipmentType.barbell],
    formCues: [
      'Stand with feet shoulder-width apart and core engaged.',
      'Grip the bar slightly wider than shoulder width.',
      'Press the bar straight overhead until arms are fully extended.',
      'Keep ribs down and avoid excessive lower back arching.',
      'Lower the bar back to shoulder level with control.',
    ],
  ),


];