class Subject {
  final String id;
  final String name;
  final String year; // Changed from code to year
  final String? instructor;
  final String? room;
  final String color; // Hex color string

  Subject({
    required this.id,
    required this.name,
    required this.year,
    this.instructor,
    this.room,
    this.color = '#2196F3', // Default blue
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      year: json['year'] ?? '',
      instructor: json['instructor'],
      room: json['room'],
      color: json['color'] ?? '#2196F3',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'year': year,
      'instructor': instructor,
      'room': room,
      'color': color,
    };
  }
}
