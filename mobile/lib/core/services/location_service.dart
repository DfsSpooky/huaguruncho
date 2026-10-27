import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double? altitude;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.altitude,
  });
}

class LocationService {
  Future<LocationResult?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
      );
    } catch (_) {
      // Fallback a última posición conocida si el GPS tarda en fijar en zonas altas
      final lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null) {
        return LocationResult(
          latitude: lastPosition.latitude,
          longitude: lastPosition.longitude,
          accuracy: lastPosition.accuracy,
          altitude: lastPosition.altitude,
        );
      }
      return null;
    }
  }

  Stream<Position>? getPositionStream() {
    try {
      return Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      );
    } catch (_) {
      return null;
    }
  }
}
