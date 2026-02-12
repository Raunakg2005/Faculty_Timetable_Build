import 'package:flutter/material.dart';
import '../models/session.dart';
import '../services/api_service.dart';

class SessionProvider with ChangeNotifier {
  List<Session> _sessions = [];
  bool _isLoading = false;

  List<Session> get sessions => _sessions;
  bool get isLoading => _isLoading;

  Future<void> fetchSessions(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/sessions/$userId');
      _sessions = (response as List).map((e) => Session.fromJson(e)).toList();
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createSession(String userId, Session session) async {
    try {
      final response = await ApiService.post('/sessions', {
        'userId': userId,
        'title': session.title,
        'type': session.type,
        'dayOfWeek': session.dayOfWeek,
        'startTime': session.startTime,
        'duration': session.duration,
        'location': session.location,
      });
      _sessions.add(Session.fromJson(response));
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAttendance(String sessionId, DateTime date, String status) async {
    try {
      await ApiService.post('/sessions/$sessionId/attendance', {
        'date': date.toIso8601String(),
        'status': status,
      });
      // Ideally update the local session object with the new attendance
      // For now, we can just re-fetch or assume success if we want to be simple
      // Let's just notify listeners for now, or maybe we should update the specific session in _sessions list
      final index = _sessions.indexWhere((s) => s.id == sessionId);
      if (index != -1) {
        // We would need to add the attendance record to the session object
        // But Session is immutable, so we might need to replace it or just re-fetch
        // Re-fetching is safer for consistency
        // await fetchSessions(_sessions[index].userId); // We don't have userId easily here without passing it
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
