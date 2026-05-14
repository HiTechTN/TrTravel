class TripActivity {
  final String id;
  final String name;
  final String category;
  final String suggestedTime;
  final int duration;
  final double cost;
  final String description;
  final String tips;

  TripActivity({
    required this.id,
    required this.name,
    required this.category,
    required this.suggestedTime,
    required this.duration,
    required this.cost,
    required this.description,
    required this.tips,
  });

  double? get estimatedCost => cost;

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'category': category,
    'suggestedTime': suggestedTime, 'duration': duration,
    'cost': cost, 'description': description, 'tips': tips,
  };

  factory TripActivity.fromJson(Map<String, dynamic> json) => TripActivity(
    id: json['id'], name: json['name'], category: json['category'],
    suggestedTime: json['suggestedTime'], duration: json['duration'],
    cost: (json['cost'] ?? 0.0).toDouble(),
    description: json['description'] ?? '', tips: json['tips'] ?? '',
  );
}
