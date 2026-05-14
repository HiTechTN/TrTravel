class ItineraryItem {
  final String date;
  final String dayName;
  final List<Activity> activities;
  final String location;

  ItineraryItem({
    required this.date,
    required this.dayName,
    required this.activities,
    required this.location,
  });

  factory ItineraryItem.fromJson(Map<String, dynamic> json) {
    return ItineraryItem(
      date: json['date'] as String,
      dayName: json['dayName'] as String,
      location: json['location'] as String,
      activities: (json['activities'] as List)
          .map((activity) => Activity.fromJson(activity))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'dayName': dayName,
        'location': location,
        'activities': activities.map((activity) => activity.toJson()).toList(),
      };
}

class Activity {
  final String time;
  final String description;
  final String? details;
  final String? location;

  Activity({
    required this.time,
    required this.description,
    this.details,
    this.location,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      time: json['time'] as String,
      description: json['description'] as String,
      details: json['details'] as String?,
      location: json['location'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'time': time,
        'description': description,
        'details': details,
        'location': location,
      };
}