enum BookingType { hotel, activity, restaurant, transport }

extension BookingTypeExtension on BookingType {
  String get label {
    switch (this) {
      case BookingType.hotel:
        return 'Hôtel';
      case BookingType.activity:
        return 'Activité';
      case BookingType.restaurant:
        return 'Restaurant';
      case BookingType.transport:
        return 'Transport';
    }
  }

  String get emoji {
    switch (this) {
      case BookingType.hotel:
        return '🏨';
      case BookingType.activity:
        return '🎟️';
      case BookingType.restaurant:
        return '🍽️';
      case BookingType.transport:
        return '🚕';
    }
  }

  static BookingType fromString(String value) {
    switch (value) {
      case 'hotel':
        return BookingType.hotel;
      case 'activity':
        return BookingType.activity;
      case 'restaurant':
        return BookingType.restaurant;
      case 'transport':
        return BookingType.transport;
      default:
        return BookingType.activity;
    }
  }
}

class Booking {
  final String id;
  final BookingType type;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final double price;
  final String currency;
  final String confirmationCode;
  final String notes;
  final String? itineraryDayId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.type,
    required this.title,
    this.description = '',
    required this.date,
    this.location = '',
    this.price = 0,
    this.currency = 'TRY',
    this.confirmationCode = '',
    this.notes = '',
    this.itineraryDayId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Booking copyWith({
    String? id,
    BookingType? type,
    String? title,
    String? description,
    DateTime? date,
    String? location,
    double? price,
    String? currency,
    String? confirmationCode,
    String? notes,
    String? itineraryDayId,
  }) {
    return Booking(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      confirmationCode: confirmationCode ?? this.confirmationCode,
      notes: notes ?? this.notes,
      itineraryDayId: itineraryDayId ?? this.itineraryDayId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'description': description,
    'date': date.toIso8601String(),
    'location': location,
    'price': price,
    'currency': currency,
    'confirmationCode': confirmationCode,
    'notes': notes,
    'itineraryDayId': itineraryDayId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json['id'] as String,
    type: BookingTypeExtension.fromString(json['type'] as String? ?? 'activity'),
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
    date: DateTime.parse(json['date'] as String),
    location: json['location'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0,
    currency: json['currency'] as String? ?? 'TRY',
    confirmationCode: json['confirmationCode'] as String? ?? '',
    notes: json['notes'] as String? ?? '',
    itineraryDayId: json['itineraryDayId'] as String?,
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
  );
}

class BookingReminder {
  final String id;
  final String bookingId;
  final DateTime remindAt;
  final String title;
  final bool isTriggered;

  BookingReminder({
    required this.id,
    required this.bookingId,
    required this.remindAt,
    required this.title,
    this.isTriggered = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'bookingId': bookingId,
    'remindAt': remindAt.toIso8601String(),
    'title': title,
    'isTriggered': isTriggered,
  };

  factory BookingReminder.fromJson(Map<String, dynamic> json) => BookingReminder(
    id: json['id'] as String,
    bookingId: json['bookingId'] as String,
    remindAt: DateTime.parse(json['remindAt'] as String),
    title: json['title'] as String,
    isTriggered: json['isTriggered'] as bool? ?? false,
  );
}
