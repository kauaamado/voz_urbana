import 'package:latlong2/latlong.dart';
import 'package:voz_urbana/services/address_service.dart';
import 'package:voz_urbana/services/location_service.dart';

class FakeLocation implements LocationService {
  FakeLocation(this.result);
  LocationResult result;
  int calls = 0, locationSettings = 0, appSettings = 0;

  @override
  Future<LocationResult> current() async {
    calls++;
    return result;
  }

  @override
  Future<void> openLocationSettings() async => locationSettings++;

  @override
  Future<void> openAppSettings() async => appSettings++;
}

class FakeAddress implements AddressService {
  FakeAddress(this.value);
  String? value;
  @override
  Future<String?> reverse(LatLng position) async => value;
}
