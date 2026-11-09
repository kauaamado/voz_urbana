import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:latlong2/latlong.dart';

abstract class AddressService {
  /// Endereço legível da posição, ou `null` se indisponível (nunca lança).
  Future<String?> reverse(LatLng position);
}

typedef NominatimFetch = Future<String> Function(double lat, double lon);

/// Geocodificação reversa via Nominatim (OpenStreetMap): gratuita, sem chave.
/// Política: ≤1 req/s, User-Agent identificável e cache no cliente.
class NominatimAddressService implements AddressService {
  NominatimAddressService({NominatimFetch? fetch}) : _fetch = fetch ?? _httpFetch;

  final NominatimFetch _fetch;
  final Map<String, String?> _cache = {};

  static const _userAgent = 'voz_urbana/1.0 (projeto academico CEFET/RJ)';
  static const _timeout = Duration(seconds: 5);

  @override
  Future<String?> reverse(LatLng position) async {
    final key =
        '${position.latitude.toStringAsFixed(5)},${position.longitude.toStringAsFixed(5)}';
    if (_cache.containsKey(key)) return _cache[key];
    try {
      final body = await _fetch(position.latitude, position.longitude);
      return _cache[key] = parse(body);
    } catch (_) {
      return null; // falhas não entram no cache: o usuário pode tentar de novo
    }
  }

  static String? parse(String body) {
    try {
      final json = jsonDecode(body);
      if (json is! Map<String, dynamic>) return null;
      final address = json['address'];
      if (address is Map<String, dynamic>) {
        String? pick(List<String> keys) {
          for (final k in keys) {
            final v = address[k];
            if (v is String && v.trim().isNotEmpty) return v.trim();
          }
          return null;
        }

        final parts = [
          pick(['road']),
          pick(['suburb', 'neighbourhood']),
          pick(['city', 'town', 'village', 'municipality']),
        ].whereType<String>().toList();
        if (parts.isNotEmpty) return parts.join(', ');
      }
      final display = json['display_name'];
      if (display is String && display.trim().isNotEmpty) return display.trim();
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<String> _httpFetch(double lat, double lon) async {
    final client = HttpClient()..connectionTimeout = _timeout;
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'format': 'jsonv2',
        'lat': '$lat',
        'lon': '$lon',
        'accept-language': 'pt-BR',
      });
      final request = await client.getUrl(uri).timeout(_timeout);
      request.headers.set(HttpHeaders.userAgentHeader, _userAgent);
      final response = await request.close().timeout(_timeout);
      if (response.statusCode != 200) {
        throw HttpException('Nominatim respondeu ${response.statusCode}');
      }
      return await response.transform(utf8.decoder).join().timeout(_timeout);
    } finally {
      client.close(force: true);
    }
  }
}
