import 'package:latlong2/latlong.dart';

class RouteStep {
  final String instruction;
  final double distance;
  final double duration;
  final LatLng point;
  final String maneuverType;
  final String? maneuverModifier;
  final String? streetName;

  RouteStep({
    required this.instruction,
    required this.distance,
    required this.duration,
    required this.point,
    required this.maneuverType,
    this.maneuverModifier,
    this.streetName,
  });

  String get simplifiedInstruction {
    if (maneuverType == 'depart') return 'Départ';
    if (maneuverType == 'arrive') return 'Arrivée';
    if (maneuverType == 'end of road') return 'Tournez';
    if (streetName != null && streetName!.isNotEmpty) {
      if (maneuverModifier != null) {
        final dir = _modifierToFr(maneuverModifier!);
        return '$dir sur $streetName';
      }
      return 'Continuer sur $streetName';
    }
    return instruction;
  }

  String _modifierToFr(String mod) {
    switch (mod) {
      case 'left': return 'Tournez à gauche';
      case 'right': return 'Tournez à droite';
      case 'straight': return 'Continuez tout droit';
      case 'sharp left': return 'Tournez brusquement à gauche';
      case 'sharp right': return 'Tournez brusquement à droite';
      case 'slight left': return 'Virez légèrement à gauche';
      case 'slight right': return 'Virez légèrement à droite';
      case 'uturn': return 'Faites demi-tour';
      default: return instruction;
    }
  }
}

class RouteInfo {
  final List<LatLng> points;
  final double distance;
  final double duration;
  final List<RouteStep> steps;
  final String transportMode;

  RouteInfo({
    required this.points,
    required this.distance,
    required this.duration,
    required this.steps,
    required this.transportMode,
  });

  String get distanceFormatted {
    if (distance >= 1) {
      return '${distance.toStringAsFixed(1)} km';
    }
    return '${(distance * 1000).toStringAsFixed(0)} m';
  }

  String get durationFormatted {
    if (duration >= 60) {
      final h = duration ~/ 60;
      final m = duration % 60;
      return '${h}h${m > 0 ? m.toString() : ''}';
    }
    return '${duration.toStringAsFixed(0)} min';
  }

  String get modeEmoji {
    switch (transportMode) {
      case 'walking': return '🚶';
      case 'taxi': return '🚕';
      case 'transit': return '🚌';
      default: return '📍';
    }
  }

  String get modeLabel {
    switch (transportMode) {
      case 'walking': return 'Piéton';
      case 'taxi': return 'Taxi';
      case 'transit': return 'Transport public';
      default: return transportMode;
    }
  }
}
