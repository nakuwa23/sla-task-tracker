class ActivityLogEntry {
  final String id;
  final String actorName;
  final String message;
  final DateTime timestamp;

  const ActivityLogEntry({
    required this.id,
    required this.actorName,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'actorName': actorName,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ActivityLogEntry.fromJson(Map<String, dynamic> json) =>
      ActivityLogEntry(
        id: json['id'] as String,
        actorName: json['actorName'] as String,
        message: json['message'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
