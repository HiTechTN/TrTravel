import 'package:flutter/foundation.dart';
import 'package:trtravel/core/services/local_storage.dart';
import 'package:trtravel/features/itinerary/models/trip.dart';
import 'package:trtravel/features/itinerary/models/day_trip.dart';

class ItineraryService extends ChangeNotifier {
  List<Trip> _trips = [];
  bool _isLoading = false;
  bool _seeded = false;

  List<Trip> get trips => List.unmodifiable(_trips);
  bool get isLoading => _isLoading;

  ItineraryService() {
    _load();
  }

  void _load() {
    _isLoading = true;
    notifyListeners();

    final jsonList = LocalStorage.getJsonList('itinerary_trips');
    if (jsonList != null && jsonList.isNotEmpty) {
      _trips = jsonList.map((j) => Trip.fromJson(j)).toList();
      _seeded = true;
    } else {
      seedTurkeyTrip();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _save() {
    final jsonList = _trips.map((t) => t.toJson()).toList();
    LocalStorage.setJsonList('itinerary_trips', jsonList);
  }

  void addTrip(Trip trip) {
    _trips.insert(0, trip);
    _save();
    notifyListeners();
  }

  void updateTrip(Trip trip) {
    final index = _trips.indexWhere((t) => t.id == trip.id);
    if (index != -1) {
      _trips[index] = trip;
      _save();
      notifyListeners();
    }
  }

  void deleteTrip(String id) {
    _trips.removeWhere((t) => t.id == id);
    _save();
    notifyListeners();
  }

  Trip? getTrip(String id) {
    try {
      return _trips.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  void updateDayTrip(String tripId, DayTrip updatedDay) {
    final trip = getTrip(tripId);
    if (trip == null) return;
    final index = trip.days.indexWhere((d) => d.id == updatedDay.id);
    if (index != -1) {
      trip.days[index] = updatedDay;
      updateTrip(trip);
    }
  }

  void seedTurkeyTrip() {
    if (_seeded) return;

    final trip = Trip(
      id: 'turkey_trip_2026',
      title: 'ESCAPADE TURQUE 2026',
      description: 'Istanbul – Antalya\n04 - 14 Juillet 2026',
      startDate: DateTime(2026, 7, 4),
      endDate: DateTime(2026, 7, 14),
      location: 'Turquie',
      days: [
        DayTrip(
          id: 'day_01',
          dayNumber: 1,
          title: 'Départ Tunis & Nuit en bus',
          date: 'Samedi 04 Juillet 2026',
          location: 'Tunis → Istanbul → Antalya',
          entries: [
            ScheduleEntry(id: 'd1e1', time: '03H00', activity: 'Arrivée à l\'aéroport de Tunis Carthage'),
            ScheduleEntry(id: 'd1e2', time: '05H30', activity: 'Départ vol Nouvelair BJ640 vers Istanbul'),
            ScheduleEntry(id: 'd1e3', time: '10H20', activity: 'Arrivée à l\'aéroport d\'Istanbul'),
            ScheduleEntry(id: 'd1e4', time: '12H00', activity: 'Sortie de l\'aéroport - Change et recharge Istanbulkart'),
            ScheduleEntry(id: 'd1e5', time: '12H40', activity: 'Navette en bus vers la gare d\'Esenler (quai n°5 – bus HVL-3)'),
            ScheduleEntry(id: 'd1e6', time: '14H00', activity: 'Arrivée gare d\'Esenler - Consigne bagages'),
            ScheduleEntry(id: 'd1e7', time: '14H30', activity: 'Déjeuner et shopping au Mall Forum Istanbul'),
            ScheduleEntry(id: 'd1e8', time: '19H15', activity: 'Retour à pied vers la gare Esenler'),
            ScheduleEntry(id: 'd1e9', time: '20H30', activity: 'Départ en bus destination Antalya (ligne KK0701)'),
          ],
        ),
        DayTrip(
          id: 'day_02',
          dayNumber: 2,
          title: 'Antalya & Vieille Ville Kaleiçi',
          date: 'Dimanche 05 Juillet 2026',
          location: 'Antalya',
          entries: [
            ScheduleEntry(id: 'd2e1', time: '10H45', activity: 'Arrivée à la gare routière d\'Antalya'),
            ScheduleEntry(id: 'd2e2', time: '11H00', activity: 'Achat et recharge Antalyakart'),
            ScheduleEntry(id: 'd2e3', time: '11H32', activity: 'Départ en bus vers l\'hôtel (bus TC16A)'),
            ScheduleEntry(id: 'd2e4', time: '11H45', activity: 'Arrivée à l\'hôtel Blue Marina Antalya'),
            ScheduleEntry(id: 'd2e5', time: '12H00', activity: 'Check-in et repos'),
            ScheduleEntry(id: 'd2e6', time: '15H00', activity: 'Départ à pied vers la vieille ville'),
            ScheduleEntry(id: 'd2e7', time: '15H30', activity: 'Déjeuner'),
            ScheduleEntry(id: 'd2e8', time: '16H00-18H30', activity: 'Visite du centre ville de Kaleiçi : Porte d\'Hadrien, Tour d\'Hidirlik'),
            ScheduleEntry(id: 'd2e9', time: '18H30', activity: 'Retour à l\'hôtel - Repos'),
            ScheduleEntry(id: 'd2e10', time: '20H30', activity: 'Départ vers Kaleiçi pour dîner et soirée dansante'),
            ScheduleEntry(id: 'd2e11', time: '22H30', activity: 'Retour à l\'hôtel'),
          ],
        ),
        DayTrip(
          id: 'day_03',
          dayNumber: 3,
          title: 'Plage de Konyaaltı & Shopping',
          date: 'Lundi 06 Juillet 2026',
          location: 'Antalya',
          entries: [
            ScheduleEntry(id: 'd3e1', time: '09H00', activity: 'Petit déjeuner à l\'hôtel'),
            ScheduleEntry(id: 'd3e2', time: '10H30', activity: 'Départ en bus vers la plage de Konyaaltı'),
            ScheduleEntry(id: 'd3e3', time: '11H00', activity: 'Arrivée plage : détente, baignade, déjeuner'),
            ScheduleEntry(id: 'd3e4', time: '17H00', activity: 'Départ vers le Mall MarkAntalya pour shopping'),
            ScheduleEntry(id: 'd3e5', time: '17H30-20H00', activity: 'Shopping à MarkAntalya'),
            ScheduleEntry(id: 'd3e6', time: '20H00', activity: 'Retour à l\'hôtel - Repos'),
            ScheduleEntry(id: 'd3e7', time: '21H30', activity: 'Départ vers la Marina pour dîner et soirée dansante'),
            ScheduleEntry(id: 'd3e8', time: '01H00', activity: 'Retour à l\'hôtel - Repos'),
          ],
        ),
        DayTrip(
          id: 'day_04',
          dayNumber: 4,
          title: 'Balade en mer & Beach Party',
          date: 'Mardi 07 Juillet 2026',
          location: 'Antalya',
          entries: [
            ScheduleEntry(id: 'd4e1', time: '08H00', activity: 'Petit déjeuner à l\'hôtel'),
            ScheduleEntry(id: 'd4e2', time: '08H30', activity: 'Ramassage en bus vers la balade en mer'),
            ScheduleEntry(id: 'd4e3', time: '09H00', activity: 'Arrivée au port de plaisance'),
            ScheduleEntry(id: 'd4e4', time: '09H00-17H30', activity: 'Départ en bateau vers l\'île de Suluada : baignade, déjeuner, grotte'),
            ScheduleEntry(id: 'd4e5', time: '17H30', activity: 'Retour en bus à l\'hôtel'),
            ScheduleEntry(id: 'd4e6', time: '18H00', activity: 'Arrivée à l\'hôtel - Repos'),
            ScheduleEntry(id: 'd4e7', time: '20H30', activity: 'Départ pour Beach Party'),
            ScheduleEntry(id: 'd4e8', time: '00H00', activity: 'Retour à l\'hôtel'),
          ],
        ),
        DayTrip(
          id: 'day_05',
          dayNumber: 5,
          title: 'Chutes de Düden & Land of Legends',
          date: 'Mercredi 08 Juillet 2026',
          location: 'Antalya',
          entries: [
            ScheduleEntry(id: 'd5e1', time: '09H00', activity: 'Petit déjeuner à l\'hôtel'),
            ScheduleEntry(id: 'd5e2', time: '09H30', activity: 'Départ vers les chutes de Düden'),
            ScheduleEntry(id: 'd5e3', time: '10H00-11H30', activity: 'Visite des cascades (inférieures et supérieures)'),
            ScheduleEntry(id: 'd5e4', time: '11H30', activity: 'Départ en bus pour shopping au Mall of Antalya'),
            ScheduleEntry(id: 'd5e5', time: '12H00-16H00', activity: 'Shopping Mall of Antalya (déjeuner sur place)'),
            ScheduleEntry(id: 'd5e6', time: '16H00', activity: 'Retour à l\'hôtel - Repos'),
            ScheduleEntry(id: 'd5e7', time: '18H30', activity: 'Départ en bus vers The Land of Legends'),
            ScheduleEntry(id: 'd5e8', time: '20H00-22H00', activity: 'Spectacle de nuit au parc d\'attractions'),
            ScheduleEntry(id: 'd5e9', time: '22H00', activity: 'Balade au centre commercial'),
            ScheduleEntry(id: 'd5e10', time: '23H00', activity: 'Retour en bus vers l\'hôtel'),
            ScheduleEntry(id: 'd5e11', time: '00H30', activity: 'Arrivée à l\'hôtel'),
          ],
        ),
        DayTrip(
          id: 'day_06',
          dayNumber: 6,
          title: 'Rafting au Köprülü Canyon',
          date: 'Jeudi 09 Juillet 2026',
          location: 'Antalya',
          entries: [
            ScheduleEntry(id: 'd6e1', time: '07H00', activity: 'Petit déjeuner à l\'hôtel'),
            ScheduleEntry(id: 'd6e2', time: '07H30', activity: 'Ramassage en bus vers le parc national de Köprülü Canyon'),
            ScheduleEntry(id: 'd6e3', time: '09H30', activity: 'Arrivée au parc'),
            ScheduleEntry(id: 'd6e4', time: '09H30-16H30', activity: 'Rafting et canyoning'),
            ScheduleEntry(id: 'd6e5', time: '12H30', activity: 'Baignade et déjeuner au bord de la rivière'),
            ScheduleEntry(id: 'd6e6', time: '16H30', activity: 'Retour en bus à l\'hôtel'),
            ScheduleEntry(id: 'd6e7', time: '18H30', activity: 'Arrivée à l\'hôtel - Repos'),
            ScheduleEntry(id: 'd6e8', time: '21H30', activity: 'Départ vers la Marina pour dîner romantique'),
            ScheduleEntry(id: 'd6e9', time: '01H00', activity: 'Retour à l\'hôtel - Repos'),
          ],
        ),
        DayTrip(
          id: 'day_07',
          dayNumber: 7,
          title: 'Shopping & Lara Beach',
          date: 'Vendredi 10 Juillet 2026',
          location: 'Antalya',
          entries: [
            ScheduleEntry(id: 'd7e1', time: '09H00', activity: 'Petit déjeuner à l\'hôtel'),
            ScheduleEntry(id: 'd7e2', time: '09H30', activity: 'Départ en bus vers MarkAntalya'),
            ScheduleEntry(id: 'd7e3', time: '10H00-13H30', activity: 'Shopping au Mall MarkAntalya'),
            ScheduleEntry(id: 'd7e4', time: '13H30', activity: 'Déjeuner au mall'),
            ScheduleEntry(id: 'd7e5', time: '14H00', activity: 'Retour à l\'hôtel'),
            ScheduleEntry(id: 'd7e6', time: '15H00', activity: 'Départ vers Lara Beach'),
            ScheduleEntry(id: 'd7e7', time: '16H00-20H00', activity: 'Après-midi détente à Lara Beach'),
            ScheduleEntry(id: 'd7e8', time: '20H00', activity: 'Retour en bus à l\'hôtel'),
            ScheduleEntry(id: 'd7e9', time: '20H30', activity: 'Arrivée à l\'hôtel - Repos'),
            ScheduleEntry(id: 'd7e10', time: '22H00', activity: 'Départ pour soirée à Kaleiçi'),
            ScheduleEntry(id: 'd7e11', time: '01H00', activity: 'Retour à l\'hôtel'),
          ],
        ),
        DayTrip(
          id: 'day_08',
          dayNumber: 8,
          title: 'Çıralı Beach & Retour Istanbul',
          date: 'Samedi 11 Juillet 2026',
          location: 'Antalya → Istanbul',
          entries: [
            ScheduleEntry(id: 'd8e1', time: '09H00', activity: 'Petit déjeuner à l\'hôtel'),
            ScheduleEntry(id: 'd8e2', time: '09H30', activity: 'Départ vers Çıralı Beach'),
            ScheduleEntry(id: 'd8e3', time: '10H00', activity: 'Arrivée plage : détente, baignade, déjeuner'),
            ScheduleEntry(id: 'd8e4', time: '18H00', activity: 'Retour à l\'hôtel pour récupérer les bagages'),
            ScheduleEntry(id: 'd8e5', time: '19H00', activity: 'Départ en bus vers la gare routière d\'Antalya'),
            ScheduleEntry(id: 'd8e6', time: '19H30', activity: 'Arrivée à la gare routière'),
            ScheduleEntry(id: 'd8e7', time: '20H30', activity: 'Départ en bus vers Istanbul (ligne KK0701)'),
          ],
        ),
        DayTrip(
          id: 'day_09',
          dayNumber: 9,
          title: 'Istanbul : Taksim & Galata',
          date: 'Dimanche 12 Juillet 2026',
          location: 'Istanbul',
          entries: [
            ScheduleEntry(id: 'd9e1', time: '10H00', activity: 'Arrivée à la gare d\'Esenler'),
            ScheduleEntry(id: 'd9e2', time: '10H30', activity: 'Départ en taxi vers l\'hôtel Gonen Taksim'),
            ScheduleEntry(id: 'd9e3', time: '11H00', activity: 'Arrivée à l\'hôtel - Check-in et repos'),
            ScheduleEntry(id: 'd9e4', time: '14H00', activity: 'Déjeuner à Taksim'),
            ScheduleEntry(id: 'd9e5', time: '15H00-18H00', activity: 'Balade à Taksim'),
            ScheduleEntry(id: 'd9e6', time: '18H00', activity: 'Retour à l\'hôtel - Repos'),
            ScheduleEntry(id: 'd9e7', time: '21H00', activity: 'Départ vers Galata & Galata Port'),
            ScheduleEntry(id: 'd9e8', time: '23H00', activity: 'Gâteau et café chez Hafız Mustafa'),
            ScheduleEntry(id: 'd9e9', time: '00H00', activity: 'Retour à l\'hôtel - Repos'),
          ],
        ),
        DayTrip(
          id: 'day_10',
          dayNumber: 10,
          title: 'Shopping & Soirée Stambouliote',
          date: 'Lundi 13 Juillet 2026',
          location: 'Istanbul',
          entries: [
            ScheduleEntry(id: 'd10e1', time: '09H00', activity: 'Petit déjeuner à l\'hôtel'),
            ScheduleEntry(id: 'd10e2', time: '09H30', activity: 'Départ en bus vers Cevahir Mall'),
            ScheduleEntry(id: 'd10e3', time: '10H00-13H00', activity: 'Shopping à Cevahir Mall'),
            ScheduleEntry(id: 'd10e4', time: '13H00', activity: 'Déjeuner sur place'),
            ScheduleEntry(id: 'd10e5', time: '14H00', activity: 'Retour à l\'hôtel - Repos'),
            ScheduleEntry(id: 'd10e6', time: '18H00', activity: 'Départ pour balade stambouliote : Ortaköy, Karaköy, Üsküdar'),
            ScheduleEntry(id: 'd10e7', time: '22H30', activity: 'Dîner et soirée au Lotiz Lounge Istanbul'),
            ScheduleEntry(id: 'd10e8', time: '01H00', activity: 'Retour à l\'hôtel'),
          ],
        ),
        DayTrip(
          id: 'day_11',
          dayNumber: 11,
          title: 'Retour Tunis',
          date: 'Mardi 14 Juillet 2026',
          location: 'Istanbul → Tunis',
          entries: [
            ScheduleEntry(id: 'd11e1', time: '08H30', activity: 'Petit déjeuner à l\'hôtel'),
            ScheduleEntry(id: 'd11e2', time: '09H30', activity: 'Départ en navette privée vers l\'aéroport d\'Istanbul'),
            ScheduleEntry(id: 'd11e3', time: '10H15', activity: 'Arrivée à l\'aéroport'),
            ScheduleEntry(id: 'd11e4', time: '13H05', activity: 'Départ vol Nouvelair BJ641 destination Tunis'),
            ScheduleEntry(id: 'd11e5', time: '14H05', activity: 'Arrivée à Tunis'),
          ],
        ),
      ],
    );

    _trips.add(trip);
    _seeded = true;
    _save();
    notifyListeners();
  }
}
