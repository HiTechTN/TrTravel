class ScheduleEntry {
  String id;
  String time;
  String activity;

  ScheduleEntry({
    required this.id,
    required this.time,
    required this.activity,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'time': time,
    'activity': activity,
  };

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) {
    return ScheduleEntry(
      id: json['id'] as String,
      time: json['time'] as String,
      activity: json['activity'] as String,
    );
  }
}

class DayTrip {
  String id;
  int dayNumber;
  String title;
  String date;
  String location;
  List<ScheduleEntry> entries;

  DayTrip({
    required this.id,
    required this.dayNumber,
    required this.title,
    required this.date,
    this.location = '',
    this.entries = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'dayNumber': dayNumber,
    'title': title,
    'date': date,
    'location': location,
    'entries': entries.map((e) => e.toJson()).toList(),
  };

  factory DayTrip.fromJson(Map<String, dynamic> json) {
    return DayTrip(
      id: json['id'] as String,
      dayNumber: json['dayNumber'] as int,
      title: json['title'] as String,
      date: json['date'] as String,
      location: json['location'] as String? ?? '',
      entries: (json['entries'] as List?)
              ?.map((e) => ScheduleEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
