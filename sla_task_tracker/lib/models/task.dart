import 'task_priority.dart';

class Task {
  final String id; 
  final String title;
  final String description;
  final String category; 
  final DateTime startDate;
  final DateTime dueDate;
  final TaskPriority priority;
  final String assigneeId;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.startDate,
    required this.dueDate,
    required this.priority,
    required this.assigneeId,
    required this.createdAt,
    this.isCompleted = false,
    this.completedAt,
  });


  double get timeProgress {
    if (isCompleted) return 1.0;
    final totalMinutes = dueDate.difference(startDate).inMinutes;
    if (totalMinutes <= 0) return 1.0;
    final elapsedMinutes = DateTime.now().difference(startDate).inMinutes;
    final ratio = elapsedMinutes / totalMinutes;
    if (ratio < 0) return 0.0;
    if (ratio > 1) return 1.0;
    return ratio;
  }


  Task copyWith({
    String? title,
    String? description,
    String? category,
    DateTime? startDate,
    DateTime? dueDate,
    TaskPriority? priority,
    String? assigneeId,
    bool? isCompleted,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      assigneeId: assigneeId ?? this.assigneeId,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'startDate': startDate.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        'priority': priority.storageKey,
        'assigneeId': assigneeId,
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        category: json['category'] as String? ?? 'General',
        startDate: DateTime.parse(json['startDate'] as String),
        dueDate: DateTime.parse(json['dueDate'] as String),
        priority: TaskPriorityX.fromStorageKey(json['priority'] as String?),
        assigneeId: json['assigneeId'] as String,
        isCompleted: json['isCompleted'] as bool? ?? false,
        completedAt: json['completedAt'] == null
            ? null
            : DateTime.parse(json['completedAt'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
