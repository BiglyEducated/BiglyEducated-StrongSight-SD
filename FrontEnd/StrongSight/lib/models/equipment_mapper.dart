import 'workout_models.dart';
import 'exercise_catalog.dart';

Equipment mapEquipmentTypeToEquipment(EquipmentType type) {
  switch (type) {
    case EquipmentType.barbell:
      return const Equipment(id: 'barbell', name: 'Barbell');
    case EquipmentType.dumbbell:
      return const Equipment(id: 'dumbbell', name: 'Dumbbell');
    case EquipmentType.machine:
      return const Equipment(id: 'machine', name: 'Machine');
    case EquipmentType.bodyweight:
      return const Equipment(id: 'bodyweight', name: 'Bodyweight');
    case EquipmentType.cable:
      return const Equipment(id: 'cable', name: 'Cable');
    case EquipmentType.kettlebell:
      return const Equipment(id: 'kettlebell', name: 'Kettlebell');
    case EquipmentType.bench:
      return const Equipment(id: 'bench', name: 'Bench');
    case EquipmentType.pullupBar:
      return const Equipment(id: 'pullup_bar', name: 'Pull-up Bar');
    case EquipmentType.mat:
      return const Equipment(id: 'mat', name: 'Mat');
  }
}


String equipmentLabel(EquipmentType type) {
  switch (type) {
    case EquipmentType.barbell:
      return 'Barbell';
    case EquipmentType.dumbbell:
      return 'Dumbbell';
    case EquipmentType.machine:
      return 'Machine';
    case EquipmentType.cable:
      return 'Cable';
    case EquipmentType.bodyweight:
      return 'Bodyweight';
    case EquipmentType.kettlebell:
      return 'Kettlebell';
    case EquipmentType.bench:
      return 'Bench';
    case EquipmentType.pullupBar:
      return 'Pull-up Bar';
    case EquipmentType.mat:
      return 'Mat';
  }
}
