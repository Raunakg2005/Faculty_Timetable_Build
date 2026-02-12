class Session {
  final String id;
  final String title;
  final String type; // 'Lecture' or 'Lab'
  final String dayOfWeek;
  final String startTime;
  final int duration;
  final String location;
  final List<Attendance> attendance;

  Session({
    required this.id,
    required this.title,
    required this.type,
    required this.dayOfWeek,
    required this.startTime,
    required this.duration,
    required this.location,
    required this.attendance,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['_id'],
      title: json['title'],
      type: json['type'],
      dayOfWeek: json['dayOfWeek'],
      startTime: json['startTime'],
      duration: json['duration'],
      location: json['location'] ?? '',
      attendance: (json['attendance'] as List<dynamic>?)
              ?.map((e) => Attendance.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Attendance {
  final DateTime date;
  final String status;

  Attendance({required this.date, required this.status});

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      date: DateTime.parse(json['date']),
      status: json['status'],
    );
  }
}
