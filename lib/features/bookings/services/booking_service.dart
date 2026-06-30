import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trtravel/core/services/local_storage.dart';
import 'package:trtravel/core/services/logger.dart';
import 'package:trtravel/features/bookings/models/booking_models.dart';

class BookingService extends ChangeNotifier {
  List<Booking> _bookings = [];
  List<BookingReminder> _reminders = [];
  bool _isLoading = false;
  bool _isSynced = false;

  List<Booking> get bookings => List.unmodifiable(_bookings);
  List<BookingReminder> get reminders => List.unmodifiable(_reminders);
  bool get isLoading => _isLoading;
  bool get isSynced => _isSynced;

  BookingService() {
    _load();
  }

  void _load() {
    _isLoading = true;
    notifyListeners();

    final jsonList = LocalStorage.getJsonList('bookings');
    if (jsonList != null) {
      _bookings = jsonList.map((j) => Booking.fromJson(j)).toList();
    }

    final reminderList = LocalStorage.getJsonList('booking_reminders');
    if (reminderList != null) {
      _reminders = reminderList.map((j) => BookingReminder.fromJson(j)).toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _save() {
    LocalStorage.setJsonList('bookings', _bookings.map((b) => b.toJson()).toList());
    LocalStorage.setJsonList('booking_reminders', _reminders.map((r) => r.toJson()).toList());
  }

  void addBooking(Booking booking) {
    _bookings.insert(0, booking);
    _save();
    _syncToFirestore(booking);
    notifyListeners();
  }

  void updateBooking(Booking booking) {
    final index = _bookings.indexWhere((b) => b.id == booking.id);
    if (index != -1) {
      _bookings[index] = booking;
      _save();
      _syncToFirestore(booking);
      notifyListeners();
    }
  }

  void deleteBooking(String id) {
    _bookings.removeWhere((b) => b.id == id);
    _reminders.removeWhere((r) => r.bookingId == id);
    _save();
    _deleteFromFirestore(id);
    notifyListeners();
  }

  Booking? getBooking(String id) {
    try {
      return _bookings.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Booking> getBookingsByType(BookingType type) {
    return _bookings.where((b) => b.type == type).toList();
  }

  List<Booking> getBookingsByDay(String itineraryDayId) {
    return _bookings.where((b) => b.itineraryDayId == itineraryDayId).toList();
  }

  List<Booking> getUpcomingBookings({int days = 7}) {
    final now = DateTime.now();
    final end = now.add(Duration(days: days));
    return _bookings.where((b) =>
      b.date.isAfter(now.subtract(const Duration(hours: 1))) &&
      b.date.isBefore(end)
    ).toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  double getTotalSpent() {
    return _bookings.fold(0.0, (s, b) => s + b.price);
  }

  double getTotalSpentByType(BookingType type) {
    return _bookings
        .where((b) => b.type == type)
        .fold(0.0, (s, b) => s + b.price);
  }

  void addReminder(BookingReminder reminder) {
    _reminders.add(reminder);
    _save();
    notifyListeners();
  }

  void markReminderTriggered(String id) {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index] = BookingReminder(
        id: _reminders[index].id,
        bookingId: _reminders[index].bookingId,
        remindAt: _reminders[index].remindAt,
        title: _reminders[index].title,
        isTriggered: true,
      );
      _save();
      notifyListeners();
    }
  }

  void createDefaultReminders(Booking booking) {
    final remindAt = booking.date.subtract(const Duration(hours: 2));
    if (remindAt.isAfter(DateTime.now())) {
      addReminder(BookingReminder(
        id: 'rem_${booking.id}',
        bookingId: booking.id,
        remindAt: remindAt,
        title: '${booking.type.emoji} ${booking.title}',
      ));
    }
  }

  void clearAll() {
    _bookings.clear();
    _reminders.clear();
    _save();
    notifyListeners();
  }

  Future<void> _syncToFirestore(Booking booking) async {
    try {
      final user = LocalStorage.getString('auth_user_id');
      if (user == null) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user)
          .collection('bookings')
          .doc(booking.id)
          .set(booking.toJson());
      _isSynced = true;
    } catch (e) {
      LogService.warning('BookingService', 'Firestore sync failed: $e');
    }
  }

  Future<void> _deleteFromFirestore(String id) async {
    try {
      final user = LocalStorage.getString('auth_user_id');
      if (user == null) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user)
          .collection('bookings')
          .doc(id)
          .delete();
    } catch (e) {
      LogService.warning('BookingService', 'Firestore delete failed: $e');
    }
  }

  Future<void> syncFromFirestore() async {
    try {
      final user = LocalStorage.getString('auth_user_id');
      if (user == null) return;
      _isLoading = true;
      notifyListeners();

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user)
          .collection('bookings')
          .get();

      final remote = snapshot.docs.map((doc) => Booking.fromJson(doc.data())).toList();

      for (final r in remote) {
        final localIndex = _bookings.indexWhere((b) => b.id == r.id);
        if (localIndex == -1) {
          _bookings.add(r);
        } else if (r.updatedAt.isAfter(_bookings[localIndex].updatedAt)) {
          _bookings[localIndex] = r;
        }
      }

      _save();
      _isLoading = false;
      _isSynced = true;
      notifyListeners();
    } catch (e) {
      LogService.warning('BookingService', 'Firestore sync from failed: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
}
