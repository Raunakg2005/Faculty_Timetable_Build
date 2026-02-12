import 'user.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final String type; // 'Personal' or 'Group'
  final DateTime? dueDate;
  final bool isCompleted;
  final List<TaskAssignment> assignedTo;
  final User? creatorId;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.dueDate,
    required this.isCompleted,
    required this.assignedTo,
    this.creatorId,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'],
      title: json['title'],
      description: json['description'] ?? '',
      type: json['type'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      isCompleted: json['isCompleted'] ?? false,
      assignedTo: (json['assignedTo'] as List<dynamic>?)
              ?.map((e) => TaskAssignment.fromJson(e))
              .toList() ??
          [],
      creatorId: json['creatorId'] != null && json['creatorId'] is Map<String, dynamic>
          ? User.fromJson(json['creatorId'])
          : null,
    );
  }
}

class TaskAssignment {
  final User? user;
  final String status; // 'Pending', 'Accepted', 'Rejected'
  final bool isCompleted;

  TaskAssignment({this.user, required this.status, required this.isCompleted});

  factory TaskAssignment.fromJson(Map<String, dynamic> json) {
    return TaskAssignment(
      user: json['userId'] != null && json['userId'] is Map<String, dynamic>
          ? User.fromJson(json['userId'])
          : null,
      status: json['status'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
