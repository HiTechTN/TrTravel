import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:trtravel/core/services/local_storage.dart';
import 'package:trtravel/core/services/logger.dart';

class RouteStep {
  final String instruction;
  final double distance;
  final double duration;
  final LatLng point;

  const RouteStep({required this.instruction, required this.distance, required this.duration, required this.point});
}

class RouteResult {
  final List<LatLng> points;
  final double totalDistance; // meters
  final double totalDuration; // seconds
  final List<RouteStep> steps;

  RouteResult({required this.points, required this.totalDistance, required this.totalDuration, required this.steps});

  String get distanceFormatted {
    if (totalDistance > 1000) return '${(totalDistance / 1000).toStringAsFixed(1)} km';
    return '${totalDistance.toStringAsFixed(0)} m';
  }

  String get durationFormatted {
    if (totalDuration > 3600) {
      final h = (totalDuration / 3600).floor();
      final m = ((totalDuration % 3600) / 60).round();
      return '${h}h${m > 0 ? ' $m min' : ''}';
    }
    return '${(totalDuration / 60).round()} min';
  }
}

class RoutingService {
  static const _baseUrl = 'https://router.project-osrm.org';

  static Future<RouteResult?> getRoute(LatLng origin, LatLng destination, {String profile = 'walking'}) async {
    try {
      final profileParam = profile == 'taxi' ? 'driving' : profile;
      final url = Uri.parse('$_baseUrl/route/v1/$profileParam/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=geojson&steps=true&language=fr&alternatives=false');

      final response = await http.get(url).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        return _parseResponse(response.body);
      }
    } catch (e) {
      LogService.warning('Routing', 'Failed to get route: $e');
    }
    return null;
  }

  static Future<RouteResult?> getRouteWithCache(LatLng origin, LatLng destination, {String profile = 'walking'}) async {
    final cacheKey = 'route_${origin.latitude}_${origin.longitude}_${destination.latitude}_${destination.longitude}_$profile';
    final cached = LocalStorage.getJson(cacheKey);
    if (cached != null) {
      return _parseCachedRoute(cached);
    }

    final route = await getRoute(origin, destination, profile: profile);
    if (route != null) {
      LocalStorage.setJson(cacheKey, {
        'points': route.points.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
        'totalDistance': route.totalDistance,
        'totalDuration': route.totalDuration,
        'steps': route.steps.map((s) => {'instruction': s.instruction, 'distance': s.distance, 'duration': s.duration, 'lat': s.point.latitude, 'lng': s.point.longitude}).toList(),
      });
    }
    return route;
  }

  static RouteResult _parseResponse(String body) {
    final data = jsonDecode(body) as Map<String, dynamic>;
    final routes = data['routes'] as List;
    if (routes.isEmpty) throw Exception('No route found');

    final route = routes[0] as Map<String, dynamic>;
    final geometry = route['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List;

    final points = coordinates.map((c) {
      final coord = c as List;
      return LatLng(coord[1] as double, coord[0] as double);
    }).toList();

    final distance = (route['distance'] as num).toDouble();
    final duration = (route['duration'] as num).toDouble();
    final legs = route['legs'] as List;
    final steps = <RouteStep>[];

    if (legs.isNotEmpty) {
      final leg = legs[0] as Map<String, dynamic>;
      final legSteps = leg['steps'] as List;
      for (final step in legSteps) {
        final s = step as Map<String, dynamic>;
        final maneuver = s['maneuver'] as Map<String, dynamic>;
        final location = maneuver['location'] as List;
        steps.add(RouteStep(
          instruction: s['maneuver']?['instruction'] as String? ?? 'Continuer',
          distance: (s['distance'] as num).toDouble(),
          duration: (s['duration'] as num).toDouble(),
          point: LatLng(location[1] as double, location[0] as double),
        ));
      }
    }

    return RouteResult(points: points, totalDistance: distance, totalDuration: duration, steps: steps);
  }

  static RouteResult _parseCachedRoute(Map<String, dynamic> data) {
    final points = (data['points'] as List).map((p) {
      final pt = p as Map<String, dynamic>;
      return LatLng(pt['lat'] as double, pt['lng'] as double);
    }).toList();

    final steps = (data['steps'] as List).map((s) {
      final st = s as Map<String, dynamic>;
      return RouteStep(
        instruction: st['instruction'] as String,
        distance: (st['distance'] as num).toDouble(),
        duration: (st['duration'] as num).toDouble(),
        point: LatLng(st['lat'] as double, st['lng'] as double),
      );
    }).toList();

    return RouteResult(
      points: points,
      totalDistance: (data['totalDistance'] as num).toDouble(),
      totalDuration: (data['totalDuration'] as num).toDouble(),
      steps: steps,
    );
  }
}
