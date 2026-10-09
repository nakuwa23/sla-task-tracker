enum TaskPriority { low, medium, high, critical }

extension TaskPriorityX on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.critical:
        return 'Critical';
    }
  }

  /// How close to the deadline a task may get before it becomes "At Risk".
  Duration get responseWindow {
    switch (this) {
      case TaskPriority.low:
        return const Duration(hours: 72);
      case TaskPriority.medium:
        return const Duration(hours: 24);
      case TaskPriority.high:
        return const Duration(hours: 8);
      case TaskPriority.critical:
        return const Duration(hours: 2);
    }
  }

  String get responseLabel {
    switch (this) {
      case TaskPriority.low:
        return '72 hour response';
      case TaskPriority.medium:
        return '24 hour response';
      case TaskPriority.high:
        return '8 hour response';
      case TaskPriority.critical:
        return '2 hour response';
    }
  }

  /// Stable key used for persistence (JSON).
  String get storageKey => name;

  static TaskPriority fromStorageKey(String? key) {
    return TaskPriority.values.firstWhere(
      (p) => p.storageKey == key,
      orElse: () => TaskPriority.medium,
    );
  }
}
