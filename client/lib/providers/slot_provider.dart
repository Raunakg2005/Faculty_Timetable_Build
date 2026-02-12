import 'package:flutter/material.dart';
import '../models/time_slot.dart';
import '../services/api_service.dart';

class SlotProvider with ChangeNotifier {
  List<TimeSlot> _slots = [];
  bool _isLoading = false;

  List<TimeSlot> get slots => _slots;
  bool get isLoading => _isLoading;

  Future<void> fetchSlots(String userId) async {
    print('=== FETCHING SLOTS ===');
    print('User ID: $userId');
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiService.get('/slots/$userId');
      print('Slots data received: $data');
      _slots = (data as List).map((s) => TimeSlot.fromJson(s)).toList();
      print('Slots loaded: ${_slots.length}');
    } catch (e) {
      print('Error fetching slots: $e');
      _slots = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createSlot(TimeSlot slot, String userId) async {
    print('=== CREATING SLOT ===');
    try {
      final data = await ApiService.post('/slots', {
        'userId': userId,
        'day': slot.day,
        'startTime': slot.startTime,
        'endTime': slot.endTime,
        'subjectId': slot.subject!.id,
      });
      print('Slot created: $data');
      final newSlot = TimeSlot.fromJson(data);
      _slots.add(newSlot);
      notifyListeners();
    } catch (e) {
      print('Error creating slot: $e');
      rethrow;
    }
  }

  Future<void> deleteSlot(String slotId) async {
    print('=== DELETING SLOT ===');
    print('Slot ID: $slotId');
    try {
      await ApiService.delete('/slots/$slotId');
      print('Slot deleted');
      _slots.removeWhere((s) => s.id == slotId);
      notifyListeners();
    } catch (e) {
      print('Error deleting slot: $e');
      rethrow;
    }
  }
}
