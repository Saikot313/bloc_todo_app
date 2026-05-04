
import 'package:equatable/equatable.dart';
import '../../models/todo_model.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();
  @override
  List<Object?> get props => [];
}

class TodosLoaded extends TodoEvent {
  final String userId;
  const TodosLoaded(this.userId);
  @override
  List<Object?> get props => [userId];
}

class TodoAdded extends TodoEvent {
  final String userId;
  final TodoModel todo;
  const TodoAdded({required this.userId, required this.todo});
  @override
  List<Object?> get props => [userId, todo];
}

class TodoUpdated extends TodoEvent {
  final String userId;
  final TodoModel todo;
  const TodoUpdated({required this.userId, required this.todo});
  @override
  List<Object?> get props => [userId, todo];
}

class TodoDeleted extends TodoEvent {
  final String userId;
  final String todoId;
  const TodoDeleted({required this.userId, required this.todoId});
  @override
  List<Object?> get props => [userId, todoId];
}

class TodoToggled extends TodoEvent {
  final String userId;
  final String todoId;
  const TodoToggled({required this.userId, required this.todoId});
  @override
  List<Object?> get props => [userId, todoId];
}

class TodoFilterChanged extends TodoEvent {
  final TodoFilter filter;
  const TodoFilterChanged(this.filter);
  @override
  List<Object?> get props => [filter];
}

class CompletedTodosDeleted extends TodoEvent {
  final String userId;
  const CompletedTodosDeleted(this.userId);
  @override
  List<Object?> get props => [userId];
}

enum TodoFilter { all, active, completed }
