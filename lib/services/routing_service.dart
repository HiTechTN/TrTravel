import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/route_info.dart';

class RoutingService {
  static const String _osrmBase = 'https://router.project-osrm.org/route/v1';

  static const Map<String, String> _profiles = {
    'walking': 'foot',
    'taxi': 'driving',
    'transit': 'driving',
  };

  Future<RouteInfo?> getRoute(
      {required LatLng origin,
      required LatLng destination,
      String mode = 'walking'}) async {
    final profile = _profiles[mode] ?? 'foot';

    try {
      final url =
          '$_osrmBase/$profile/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}'
          '?steps=true&geometries=geojson&overview=full&language=fr&annotations=true';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      if (data['code'] != 'Ok' || data['routes'] == null || data['routes'].isEmpty) {
        return null;
      }

      final route = data['routes'][0];
      final geometry = route['geometry'];
      final coordinates = geometry['coordinates'] as List;
      final points = coordinates
          .map((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
          .toList();

      final legs = route['legs']?[0];
      final distance = (legs?['distance'] ?? 0) / 1000.0;
      final duration = (legs?['duration'] ?? 0) / 60.0;

      final steps = <RouteStep>[];
      final rawSteps = legs?['steps'] as List? ?? [];

      for (final s in rawSteps) {
        final maneuver = s['maneuver'] ?? {};
        final loc = maneuver['location'] ?? [0, 0];
        steps.add(RouteStep(
          instruction: s['instruction'] ?? s['name'] ?? '',
          distance: (s['distance'] ?? 0).toDouble(),
          duration: (s['duration'] ?? 0).toDouble(),
          point: LatLng(loc[1].toDouble(), loc[0].toDouble()),
          maneuverType: maneuver['type'] ?? 'unknown',
          maneuverModifier: maneuver['modifier'],
          streetName: s['name'],
        ));
      }

      if (mode == 'transit' && steps.isNotEmpty) {
        return _decorateTransitRoute(
          RouteInfo(
            points: points,
            distance: distance,
            duration: duration,
            steps: steps,
            transportMode: mode,
          ),
        );
      }

      return RouteInfo(
        points: points,
        distance: distance,
        duration: duration,
        steps: steps,
        transportMode: mode,
      );
    } catch (e) {
      return null;
    }
  }

  RouteInfo _decorateTransitRoute(RouteInfo osrmRoute) {
    final transitSteps = <RouteStep>[];
    double walkDistance = 0;
    double rideDistance = 0;
    double rideDuration = 0;
    double walkDuration = 0;

    transitSteps.add(RouteStep(
      instruction: '🚶 Rendez-vous à l\'arrêt de transport en commun le plus proche',
      distance: 300,
      duration: 240,
      point: osrmRoute.points.isNotEmpty ? osrmRoute.points.first : const LatLng(0, 0),
      maneuverType: 'depart',
      streetName: 'Marche',
    ));

    double segmentDistance = 0;
    double segmentDuration = 0;
    final ridePoints = <LatLng>[];
    bool inTransit = false;

    for (int i = 0; i < osrmRoute.steps.length; i++) {
      final step = osrmRoute.steps[i];
      segmentDistance += step.distance;
      segmentDuration += step.duration;
      ridePoints.add(step.point);

      if (step.distance > 200 && !inTransit) {
        inTransit = true;
        final distKm = segmentDistance / 1000;
        final durMin = segmentDuration / 60;
        transitSteps.add(RouteStep(
          instruction: '🚌 Montez dans le transport public (ligne recommandée)',
          distance: segmentDistance,
          duration: segmentDuration,
          point: step.point,
          maneuverType: 'transit',
          streetName: 'Bus/Métro',
        ));
        rideDistance += segmentDistance;
        rideDuration += segmentDuration;
        segmentDistance = 0;
        segmentDuration = 0;
      }
    }

    if (segmentDistance > 0) {
      rideDistance += segmentDistance;
      rideDuration += segmentDuration;
      transitSteps.add(RouteStep(
        instruction: '🚌 Continuez en transport public',
        distance: segmentDistance,
        duration: segmentDuration,
        point: osrmRoute.steps.last.point,
        maneuverType: 'transit',
        streetName: 'Bus/Métro',
      ));
    }

    transitSteps.add(RouteStep(
      instruction: '🚶 Marchez jusqu\'à votre destination',
      distance: 200,
      duration: 180,
      point: osrmRoute.steps.last.point,
      maneuverType: 'transit',
      streetName: 'Marche',
    ));
    walkDistance += 200;
    walkDuration += 180;

    transitSteps.add(RouteStep(
      instruction: '✅ Vous êtes arrivé à destination',
      distance: 0,
      duration: 0,
      point: osrmRoute.points.isNotEmpty ? osrmRoute.points.last : const LatLng(0, 0),
      maneuverType: 'arrive',
    ));

    return RouteInfo(
      points: osrmRoute.points,
      distance: (rideDistance + walkDistance) / 1000,
      duration: (rideDuration + walkDuration) / 60,
      steps: transitSteps,
      transportMode: 'transit',
    );
  }

  Future<RouteInfo?> getRouteWithFallback({
    required LatLng origin,
    required LatLng destination,
    String mode = 'walking',
  }) async {
    final route = await getRoute(origin: origin, destination: destination, mode: mode);
    if (route != null) return route;

    final fallback = _generateFallbackRoute(origin, destination, mode);
    return fallback;
  }

  RouteInfo _generateFallbackRoute(LatLng origin, LatLng destination, String mode) {
    final steps = <RouteStep>[];
    final points = <LatLng>[origin];

    final dLat = destination.latitude - origin.latitude;
    final dLon = destination.longitude - origin.longitude;
    const segments = 20;

    for (int i = 1; i <= segments; i++) {
      final t = i / segments;
      points.add(LatLng(
        origin.latitude + dLat * t,
        origin.longitude + dLon * t,
      ));
    }

    final latAvg = (origin.latitude + destination.latitude) / 2;
    final lonAvg = (origin.longitude + destination.longitude) / 2;
    points.insert(points.length ~/ 2, LatLng(latAvg + 0.005, lonAvg + 0.005));

    final distance = _haversineDistance(origin, destination);
    final speed = mode == 'walking'
        ? 5.0
        : mode == 'transit'
            ? 30.0
            : 40.0;
    final duration = (distance / speed) * 60;

    final midIdx = points.length ~/ 2;
    steps.add(RouteStep(
      instruction: mode == 'walking' ? '🚶 Départ vers votre destination' : 'Départ',
      distance: distance * 1000 * 0.5,
      duration: duration * 0.5,
      point: points[0],
      maneuverType: 'depart',
      streetName: mode == 'walking' ? 'Chemin piéton' : 'Route',
    ));
    steps.add(RouteStep(
      instruction: mode == 'walking'
          ? '🚶 Continuez tout droit'
          : mode == 'taxi'
              ? '🚕 Continuez en taxi'
              : '🚌 Continuez en transport en commun',
      distance: distance * 1000 * 0.5,
      duration: duration * 0.5,
      point: points[midIdx],
      maneuverType: 'continue',
    ));
    steps.add(RouteStep(
      instruction: '✅ Arrivée à destination',
      distance: 0,
      duration: 0,
      point: points.last,
      maneuverType: 'arrive',
    ));

    return RouteInfo(
      points: points,
      distance: distance,
      duration: duration,
      steps: steps,
      transportMode: mode,
    );
  }

  double _haversineDistance(LatLng p1, LatLng p2) {
    const R = 6371.0;
    final dLat = _toRad(p2.latitude - p1.latitude);
    final dLon = _toRad(p2.longitude - p1.longitude);
    final a = (1 - _cos(dLat)) / 2 +
        _cos(p1.latitude) * _cos(p2.latitude) * (1 - _cos(dLon)) / 2;
    return 2 * R * _asin(_sqrt(a));
  }

  double _toRad(double deg) => deg * 3.14159265359 / 180;
  double _cos(double x) => x.isNaN ? 0 : _cosApprox(x);
  double _asin(double x) => x.isNaN ? 0 : _asinApprox(x);
  double _sqrt(double x) => x.isNaN ? 0 : _sqrtApprox(x);

  double _cosApprox(double x) {
    x = x % (2 * 3.14159265359);
    double result = 1.0;
    double term = 1.0;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }

  double _asinApprox(double x) {
    if (x >= 1) return 3.14159265359 / 2;
    if (x <= -1) return -3.14159265359 / 2;
    return x + (x * x * x) / 6;
  }

  double _sqrtApprox(double x) {
    if (x <= 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }
}
