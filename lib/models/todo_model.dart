
import 'package:equatable/equatable.dart';

enum TodoPriority { low, medium, high }

enum TodoCategory { personal, work, shopping, health, other }

class TodoModel extends Equatable {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final TodoPriority priority;
  final TodoCategory category;
  final DateTime createdAt;
  final DateTime? dueDate;

  const TodoModel({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.priority = TodoPriority.medium,
    this.category = TodoCategory.personal,
    required this.createdAt,
    this.dueDate,
  });

  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    TodoPriority? priority,
    TodoCategory? category,
    DateTime? createdAt,
    DateTime? dueDate,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'priority': priority.index,
      'category': category.index,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['isCompleted'] ?? false,
      priority: TodoPriority.values[json['priority'] ?? 1],
      category: TodoCategory.values[json['category'] ?? 0],
      createdAt: DateTime.parse(json['createdAt']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    );
  }

  @override
  List<Object?> get props => [id, title, description, isCompleted, priority, category, createdAt, dueDate];
}
