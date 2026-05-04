
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/todo_repository.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository _todoRepository;

  TodoBloc({required TodoRepository todoRepository})
      : _todoRepository = todoRepository,
        super(TodoInitial()) {
    on<TodosLoaded>(_onTodosLoaded);
    on<TodoAdded>(_onTodoAdded);
    on<TodoUpdated>(_onTodoUpdated);
    on<TodoDeleted>(_onTodoDeleted);
    on<TodoToggled>(_onTodoToggled);
    on<TodoFilterChanged>(_onFilterChanged);
    on<CompletedTodosDeleted>(_onCompletedTodosDeleted);
  }

  Future<void> _onTodosLoaded(TodosLoaded event, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    try {
      final todos = await _todoRepository.getTodos(event.userId);
      emit(TodoLoaded(todos: todos));
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> _onTodoAdded(TodoAdded event, Emitter<TodoState> emit) async {
    if (state is TodoLoaded) {
      final currentState = state as TodoLoaded;
      try {
        await _todoRepository.addTodo(event.userId, event.todo);
        final updatedTodos = [...currentState.todos, event.todo];
        emit(currentState.copyWith(todos: updatedTodos));
      } catch (e) {
        emit(TodoError(e.toString()));
      }
    }
  }

  Future<void> _onTodoUpdated(TodoUpdated event, Emitter<TodoState> emit) async {
    if (state is TodoLoaded) {
      final currentState = state as TodoLoaded;
      try {
        await _todoRepository.updateTodo(event.userId, event.todo);
        final updatedTodos = currentState.todos.map((t) {
          return t.id == event.todo.id ? event.todo : t;
        }).toList();
        emit(currentState.copyWith(todos: updatedTodos));
      } catch (e) {
        emit(TodoError(e.toString()));
      }
    }
  }

  Future<void> _onTodoDeleted(TodoDeleted event, Emitter<TodoState> emit) async {
    if (state is TodoLoaded) {
      final currentState = state as TodoLoaded;
      try {
        await _todoRepository.deleteTodo(event.userId, event.todoId);
        final updatedTodos = currentState.todos.where((t) => t.id != event.todoId).toList();
        emit(currentState.copyWith(todos: updatedTodos));
      } catch (e) {
        emit(TodoError(e.toString()));
      }
    }
  }

  Future<void> _onTodoToggled(TodoToggled event, Emitter<TodoState> emit) async {
    if (state is TodoLoaded) {
      final currentState = state as TodoLoaded;
      try {
        await _todoRepository.toggleTodo(event.userId, event.todoId);
        final updatedTodos = currentState.todos.map((t) {
          return t.id == event.todoId ? t.copyWith(isCompleted: !t.isCompleted) : t;
        }).toList();
        emit(currentState.copyWith(todos: updatedTodos));
      } catch (e) {
        emit(TodoError(e.toString()));
      }
    }
  }

  void _onFilterChanged(TodoFilterChanged event, Emitter<TodoState> emit) {
    if (state is TodoLoaded) {
      final currentState = state as TodoLoaded;
      emit(currentState.copyWith(filter: event.filter));
    }
  }

  Future<void> _onCompletedTodosDeleted(
    CompletedTodosDeleted event,
    Emitter<TodoState> emit,
  ) async {
    if (state is TodoLoaded) {
      final currentState = state as TodoLoaded;
      try {
        await _todoRepository.deleteCompleted(event.userId);
        final updatedTodos = currentState.todos.where((t) => !t.isCompleted).toList();
        emit(currentState.copyWith(todos: updatedTodos));
      } catch (e) {
        emit(TodoError(e.toString()));
      }
    }
  }
}
