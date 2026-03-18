import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../core/errors/app_exceptions.dart';

/// Result of a location lookup. All fields nullable — location is optional.
class LocationResult {
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? area;

  const LocationResult({
    this.latitude,
    this.longitude,
    this.city,
    this.area,
  });

  bool get hasLocation => city != null && city!.isNotEmpty && city != 'Unknown';
}

/// Handles device location detection for Platform.
/// Uses geolocator for coordinates, geocoding for city/area names.
/// No-op on web — geocoding is not supported.
class LocationService {

  /// Gets the current device location and reverse-geocodes it to city/area.
  /// Returns a LocationResult — city may be null if permission denied or web.
  Future<LocationResult> getCurrentLocation() async {
    // geocoding package doesn't work on web
    if (kIsWeb) return const LocationResult();

    try {
      // Check location services enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return const LocationResult();

      // Check/request permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return const LocationResult();
      }

      // Get GPS position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return _reverseGeocode(position.latitude, position.longitude);
    } catch (_) {
      return const LocationResult();
    }
  }

  /// Reverse geocodes coordinates to city/area names.
  Future<LocationResult> _reverseGeocode(
      double latitude, double longitude) async {
    try {
      final placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) {
        return LocationResult(latitude: latitude, longitude: longitude);
      }

      final place = placemarks.first;

      // city: administrativeArea (e.g. "Lagos") or locality
      final city = place.administrativeArea?.isNotEmpty == true
          ? place.administrativeArea!
          : place.locality?.isNotEmpty == true
              ? place.locality!
              : null;

      // area: subLocality (e.g. "Yaba") or locality
      final area = place.subLocality?.isNotEmpty == true
          ? place.subLocality!
          : place.locality;

      return LocationResult(
        latitude: latitude,
        longitude: longitude,
        city: city,
        area: area,
      );
    } catch (_) {
      return LocationResult(latitude: latitude, longitude: longitude);
    }
  }

  Future<bool> openAppSettings() => Geolocator.openAppSettings();
}
