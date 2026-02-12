import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../services/api_service.dart';

class SubjectProvider with ChangeNotifier {
  List<Subject> _subjects = [];
  bool _isLoading = false;

  List<Subject> get subjects => _subjects;
  bool get isLoading => _isLoading;

  Future<void> fetchSubjects(String userId) async {
    print('=== FETCHING SUBJECTS ===');
    print('User ID: $userId');
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiService.get('/subjects/$userId');
      print('Subjects data received: $data');
      _subjects = (data as List).map((s) => Subject.fromJson(s)).toList();
      print('Subjects loaded: ${_subjects.length}');
    } catch (e) {
      print('Error fetching subjects: $e');
      _subjects = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createSubject(Subject subject, String userId) async {
    print('=== CREATING SUBJECT ===');
    print('Subject: ${subject.name}');
    try {
      final data = await ApiService.post('/subjects', {
        'userId': userId,
        'name': subject.name,
        'year': subject.year,
        'instructor': subject.instructor,
        'room': subject.room,
        'color': subject.color,
      });
      print('Subject created: $data');
      final newSubject = Subject.fromJson(data);
      _subjects.add(newSubject);
      notifyListeners();
    } catch (e) {
      print('Error creating subject: $e');
      rethrow;
    }
  }

  Future<void> updateSubject(Subject subject) async {
    print('=== UPDATING SUBJECT ===');
    print('Subject ID: ${subject.id}');
    try {
      final data = await ApiService.put('/subjects/${subject.id}', {
        'name': subject.name,
        'year': subject.year,
        'instructor': subject.instructor,
        'room': subject.room,
        'color': subject.color,
      });
      print('Subject updated: $data');
      final index = _subjects.indexWhere((s) => s.id == subject.id);
      if (index != -1) {
        _subjects[index] = Subject.fromJson(data);
        notifyListeners();
      }
    } catch (e) {
      print('Error updating subject: $e');
      rethrow;
    }
  }

  Future<void> deleteSubject(String subjectId) async {
    print('=== DELETING SUBJECT ===');
    print('Subject ID: $subjectId');
    try {
      await ApiService.delete('/subjects/$subjectId');
      print('Subject deleted');
      _subjects.removeWhere((s) => s.id == subjectId);
      notifyListeners();
    } catch (e) {
      print('Error deleting subject: $e');
      rethrow;
    }
  }
}
