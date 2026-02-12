import 'subject.dart';

class TimeSlot {
  final String id;
  final String day; // Monday, Tuesday, etc.
  final String startTime; // e.g., "09:00"
  final String endTime; // e.g., "10:00"
  final Subject? subject; // Can be null if no class scheduled
  
  TimeSlot({
    required this.id,
    required this.day,
    required this.startTime,
    required this.endTime,
    this.subject,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['_id'] ?? json['id'] ?? '',
      day: json['day'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      subject: (json['subject'] ?? json['subjectId']) != null ? Subject.fromJson(json['subject'] ?? json['subjectId']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
      'subject': subject?.toJson(),
    };
  }

  // Helper to check if this slot is for today
  bool isToday() {
    final now = DateTime.now();
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final todayName = days[now.weekday - 1];
    return day == todayName;
  }
}
