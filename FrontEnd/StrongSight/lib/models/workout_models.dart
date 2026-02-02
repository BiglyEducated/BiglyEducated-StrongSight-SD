class Workout {
  final String id;
  final String workoutName;
  final DateTime date;
  final List<WorkoutExercise> exercises;

  const Workout({
    required this.id,
    required this.workoutName,
    required this.date,
    required this.exercises,
  });
  Workout copyWith({
    String? id,
    String? workoutName,
    DateTime? date,
    List<WorkoutExercise>? exercises,
  }) {
    return Workout(
      id: id ?? this.id,
      workoutName: workoutName ?? this.workoutName,
      date: date ?? this.date,
      exercises: exercises ?? this.exercises,
    );
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      workoutName: json['workoutName'],
      date: DateTime.parse(json['date']),
      exercises: (json['exercises'] as List)
          .map((e) => WorkoutExercise.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workoutName': workoutName,
      'date': date.toIso8601String(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}

class WorkoutExercise {
  final String id;
  final String name;
  final Equipment equipment;
  final List<WorkoutSet> sets;

  const WorkoutExercise({
    required this.id,
    required this.name,
    required this.equipment,
    required this.sets,
  });

  WorkoutExercise copyWith({
    String? id,
    String? name,
    Equipment? equipment,
    List<WorkoutSet>? sets,
  }) {
    return WorkoutExercise(
      id: id ?? this.id,
      name: name ?? this.name,
      equipment: equipment ?? this.equipment,
      sets: sets ?? this.sets,
    );
  }

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      id: json['id'],
      name: json['name'],
      equipment: Equipment.fromJson(json['equipment']),
      sets: (json['sets'] as List)
          .map((s) => WorkoutSet.fromJson(s))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'equipment': equipment.toJson(),
      'sets': sets.map((s) => s.toJson()).toList(),
    };
  }
}

class Equipment {
  final String id;
  final String name; 

  const Equipment({
    required this.id,
    required this.name,
  });

  Equipment copyWith({
    String? id,
    String? name,
  }) {
    return Equipment(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}


class WorkoutSet {
  final int reps;
  final int weight;

  WorkoutSet({
    required this.reps,
    required this.weight,
  });

  WorkoutSet copyWith({
    int? reps,
    int? weight,
  }) {
    return WorkoutSet(
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
    );
  }

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      reps: json['reps'],
      weight: json['weight'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'weight': weight,
    };
  }
}




