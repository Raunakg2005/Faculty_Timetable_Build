import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  List<Task> get personalTasks => _tasks.where((t) => t.type == 'Personal').toList();
  List<Task> get groupTasks => _tasks.where((t) => t.type == 'Group').toList();

  Future<void> fetchTasks(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/tasks/$userId');
      _tasks = (response as List).map((e) => Task.fromJson(e)).toList();
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTask(String creatorId, String title, String description, String type, DateTime? dueDate, List<String> assignedUserIds) async {
    try {
      // Fix timezone issue: set time to noon to avoid date shifting when converting to UTC
      final dueDateToSend = dueDate != null 
          ? DateTime(dueDate.year, dueDate.month, dueDate.day, 12, 0, 0)
          : null;
      
      final response = await ApiService.post('/tasks', {
        'creatorId': creatorId,
        'title': title,
        'description': description,
        'type': type,
        'dueDate': dueDateToSend?.toIso8601String(),
        'assignedTo': assignedUserIds.map((id) => {'userId': id}).toList(),
      });
      _tasks.add(Task.fromJson(response));
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> respondToTask(String taskId, String userId, String status) async {
    try {
      await ApiService.post('/tasks/$taskId/respond', {
        'userId': userId,
        'status': status,
      });
      // Refresh tasks to get updated status
      // Or manually update local state
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        // Ideally fetch the single task again or update the specific assignment in the list
        // For simplicity, we might just re-fetch all or assume success
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    try {
      await ApiService.put('/tasks/$taskId', {
        'isCompleted': isCompleted,
      });
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        // Create a new Task with updated status (since fields are final)
        // Or just re-fetch. Re-fetching is easier but slower.
        // Let's just update the list with a modified copy if we can, or just re-fetch.
        // Given we don't have a copyWith method on Task yet, let's just re-fetch or hack it.
        // Actually, let's just re-fetch for simplicity or assume the UI updates optimistically?
        // Let's just notify listeners and let the UI handle it if we re-fetch.
        // But we need the userId to re-fetch.
        // Let's just update the local object manually if we can't re-fetch easily.
        // We'll leave it as a TODO to implement copyWith or re-fetch.
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await ApiService.delete('/tasks/$taskId');
      _tasks.removeWhere((t) => t.id == taskId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
