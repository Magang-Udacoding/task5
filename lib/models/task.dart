class Task {
  final String id;
  final String title;
  final DateTime createdAt;
  final bool isCompleted;

  const Task({
    required this.id,
    required this.title,
    required this.createdAt,
    this.isCompleted = false,
  });

  Task copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(
        json['createdAt'] as String,
      ),
      isCompleted: json['isCompleted'] as bool,
    );
  }
}
