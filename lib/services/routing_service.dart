import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
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

  Future<RouteInfo?> getRoute({
    required LatLng origin,
    required LatLng destination,
    String mode = 'walking',
  }) async {
    final profile = _profiles[mode] ?? 'foot';

    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        final url =
            '$_osrmBase/$profile/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}'
            '?steps=true&geometries=geojson&overview=full&language=fr';

        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Accept': 'application/json',
            'User-Agent': 'TrTravel/1.0 (travel app for Turkey)',
          },
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode != 200) continue;

        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['code'] != 'Ok') continue;

        final routes = data['routes'] as List?;
        if (routes == null || routes.isEmpty) continue;

        final route = routes[0] as Map<String, dynamic>;
        final geometry = route['geometry'] as Map<String, dynamic>?;
        if (geometry == null) continue;

        final coordinates = geometry['coordinates'] as List?;
        if (coordinates == null || coordinates.length < 2) continue;

        final points = coordinates
            .map((c) => LatLng(
                  (c[1] as num).toDouble(),
                  (c[0] as num).toDouble(),
                ))
            .toList();

        final legs = route['legs'] as List?;
        final leg = (legs != null && legs.isNotEmpty) ? legs[0] as Map<String, dynamic> : null;
        final distance = ((leg?['distance'] ?? route['distance']) as num?)?.toDouble() ?? 0;
        final duration = ((leg?['duration'] ?? route['duration']) as num?)?.toDouble() ?? 0;

        final steps = <RouteStep>[];
        final rawSteps = leg?['steps'] as List? ?? [];

        for (final s in rawSteps) {
          final step = s as Map<String, dynamic>;
          final maneuver = step['maneuver'] as Map<String, dynamic>? ?? {};
          final loc = maneuver['location'] as List? ?? [0, 0];

          String instruction = step['instruction'] as String? ?? '';
          final name = step['name'] as String? ?? '';
          if (instruction.isEmpty && name.isNotEmpty) {
            final mod = maneuver['modifier'] as String?;
            instruction = mod != null ? '$mod sur $name' : 'Continuer sur $name';
          }

          steps.add(RouteStep(
            instruction: instruction,
            distance: (step['distance'] as num?)?.toDouble() ?? 0,
            duration: (step['duration'] as num?)?.toDouble() ?? 0,
            point: LatLng(
              (loc[1] as num).toDouble(),
              (loc[0] as num).toDouble(),
            ),
            maneuverType: maneuver['type'] as String? ?? 'unknown',
            maneuverModifier: maneuver['modifier'] as String?,
            streetName: name,
          ));
        }

        if (mode == 'transit' && steps.isNotEmpty) {
          return _decorateTransitRoute(
            RouteInfo(
              points: points,
              distance: distance / 1000,
              duration: duration / 60,
              steps: steps,
              transportMode: mode,
            ),
          );
        }

        return RouteInfo(
          points: points,
          distance: distance / 1000,
          duration: duration / 60,
          steps: steps,
          transportMode: mode,
        );
      } catch (e) {
        debugPrint('OSRM attempt $attempt failed: $e');
      }
    }
    return null;
  }

  RouteInfo _decorateTransitRoute(RouteInfo osrmRoute) {
    final steps = <RouteStep>[
      RouteStep(
        instruction: '🚶 Marchez jusqu\'à l\'arrêt de bus/métro le plus proche',
        distance: 300,
        duration: 240,
        point: osrmRoute.points.isNotEmpty ? osrmRoute.points.first : const LatLng(0, 0),
        maneuverType: 'depart',
        streetName: 'Marche',
      ),
      RouteStep(
        instruction: '🚌 Montez dans le transport en commun',
        distance: osrmRoute.distance * 500,
        duration: osrmRoute.duration * 30,
        point: osrmRoute.points.length > 3
            ? osrmRoute.points[osrmRoute.points.length ~/ 2]
            : osrmRoute.points.last,
        maneuverType: 'transit',
        streetName: 'Bus/Métro',
      ),
      RouteStep(
        instruction: '🚶 Marchez jusqu\'à votre destination',
        distance: 200,
        duration: 180,
        point: osrmRoute.points.isNotEmpty ? osrmRoute.points.last : const LatLng(0, 0),
        maneuverType: 'transit',
        streetName: 'Marche',
      ),
      RouteStep(
        instruction: '✅ Vous êtes arrivé à destination',
        distance: 0,
        duration: 0,
        point: osrmRoute.points.isNotEmpty ? osrmRoute.points.last : const LatLng(0, 0),
        maneuverType: 'arrive',
      ),
    ];

    return RouteInfo(
      points: osrmRoute.points,
      distance: osrmRoute.distance,
      duration: osrmRoute.duration * 1.5,
      steps: steps,
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
    return _generateCurvedFallback(origin, destination, mode);
  }

  RouteInfo _generateCurvedFallback(LatLng origin, LatLng destination, String mode) {
    final points = <LatLng>[];
    final rand = Random(origin.latitude.toInt() + destination.longitude.toInt());
    const numPoints = 40;
    final midLat = (origin.latitude + destination.latitude) / 2;
    final midLon = (origin.longitude + destination.longitude) / 2;
    final dLat = destination.latitude - origin.latitude;
    final dLon = destination.longitude - origin.longitude;
    final dist = dLat.abs() + dLon.abs();
    final offset = dist * 0.02;

    for (int i = 0; i <= numPoints; i++) {
      final t = i / numPoints;
      final lat = origin.latitude + dLat * t;
      final lon = origin.longitude + dLon * t;
      final perpendicular = sin(t * pi) * offset * (rand.nextDouble() * 2 - 1);
      final perpLat = -dLon / dist * perpendicular;
      final perpLon = dLat / dist * perpendicular;
      points.add(LatLng(lat + perpLat, lon + perpLon));
    }

    final distance = _haversineDistance(origin, destination);
    final speeds = {'walking': 5.0, 'taxi': 40.0, 'transit': 30.0};
    final duration = (distance / (speeds[mode] ?? 5.0)) * 60;

    final midPoint = points[points.length ~/ 2];
    final steps = <RouteStep>[
      RouteStep(
        instruction: mode == 'walking' ? '🚶 Départ' : mode == 'taxi' ? '🚕 Prenez un taxi' : '🚌 Départ en transport',
        distance: distance * 500,
        duration: duration * 0.4,
        point: points.first,
        maneuverType: 'depart',
        streetName: mode == 'walking' ? 'Chemin piéton' : mode == 'taxi' ? 'Route' : 'Bus/Métro',
      ),
      RouteStep(
        instruction: mode == 'walking' ? '🚶 Continuez' : mode == 'taxi' ? '🚕 Continuez en taxi' : '🚌 Restez dans le bus/métro',
        distance: distance * 500,
        duration: duration * 0.5,
        point: midPoint,
        maneuverType: 'continue',
        streetName: mode == 'taxi' ? 'Départementale' : 'Voirie',
      ),
      RouteStep(
        instruction: '✅ Vous êtes arrivé',
        distance: 0,
        duration: 0,
        point: points.last,
        maneuverType: 'arrive',
      ),
    ];

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
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(p1.latitude)) * cos(_toRad(p2.latitude)) * sin(dLon / 2) * sin(dLon / 2);
    return 2 * R * atan2(sqrt(a), sqrt(1 - a));
  }

  double _toRad(double deg) => deg * pi / 180;
}
