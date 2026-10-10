import '../models/sla_status.dart';
import '../models/task.dart';
import '../models/task_priority.dart';

class SlaCalculator {
  SlaCalculator._();

  static SlaStatus statusFor(Task task, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();

    if (task.isCompleted) return SlaStatus.completed;

    if (currentTime.isAfter(task.dueDate)) return SlaStatus.overdue;

    final remaining = task.dueDate.difference(currentTime);
    if (remaining <= task.priority.responseWindow) return SlaStatus.atRisk;

    return SlaStatus.onTrack;
  }

  static Duration timeRemaining(Task task, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    return task.dueDate.difference(currentTime);
  }
}
