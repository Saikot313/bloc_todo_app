
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo_model.dart';

class TodoRepository {
  static const String _todosKey = 'todos_';

  String _getKey(String userId) => '$_todosKey$userId';

  Future<List<TodoModel>> getTodos(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = prefs.getString(_getKey(userId));
    if (todosJson == null) return [];
    final todosList = jsonDecode(todosJson) as List;
    return todosList.map((t) => TodoModel.fromJson(t as Map<String, dynamic>)).toList();
  }

  Future<void> saveTodos(String userId, List<TodoModel> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = jsonEncode(todos.map((t) => t.toJson()).toList());
    await prefs.setString(_getKey(userId), todosJson);
  }

  Future<TodoModel> addTodo(String userId, TodoModel todo) async {
    final todos = await getTodos(userId);
    todos.add(todo);
    await saveTodos(userId, todos);
    return todo;
  }

  Future<TodoModel> updateTodo(String userId, TodoModel updatedTodo) async {
    final todos = await getTodos(userId);
    final index = todos.indexWhere((t) => t.id == updatedTodo.id);
    if (index != -1) {
      todos[index] = updatedTodo;
      await saveTodos(userId, todos);
    }
    return updatedTodo;
  }

  Future<void> deleteTodo(String userId, String todoId) async {
    final todos = await getTodos(userId);
    todos.removeWhere((t) => t.id == todoId);
    await saveTodos(userId, todos);
  }

  Future<void> toggleTodo(String userId, String todoId) async {
    final todos = await getTodos(userId);
    final index = todos.indexWhere((t) => t.id == todoId);
    if (index != -1) {
      todos[index] = todos[index].copyWith(isCompleted: !todos[index].isCompleted);
      await saveTodos(userId, todos);
    }
  }

  Future<void> deleteCompleted(String userId) async {
    final todos = await getTodos(userId);
    todos.removeWhere((t) => t.isCompleted);
    await saveTodos(userId, todos);
  }
}
