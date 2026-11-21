import 'dart:convert';

import 'package:http/http.dart' as http;

/// Acesso à API pública do RainViewer (radar de precipitação global,
/// gratuito para uso pessoal com atribuição: https://www.rainviewer.com).
class RainViewerService {
  RainViewerService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _mapsUri = 'https://api.rainviewer.com/public/weather-maps.json';

  Future<RadarFrames> fetchFrames() async {
    final resp = await _client
        .get(Uri.parse(_mapsUri))
        .timeout(const Duration(seconds: 10));
    if (resp.statusCode != 200) {
      throw RainViewerException('HTTP ${resp.statusCode}');
    }
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    final host = json['host'] as String? ?? 'https://tilecache.rainviewer.com';
    final radar = (json['radar'] as Map?)?.cast<String, dynamic>() ?? const {};
    final past = (radar['past'] as List?) ?? const [];

    final frames = <RadarFrame>[];
    for (final item in past) {
      if (item is! Map) continue;
      final time = (item['time'] as num?)?.toInt();
      final path = item['path'] as String?;
      if (time == null || path == null) continue;
      frames.add(RadarFrame(
        time: DateTime.fromMillisecondsSinceEpoch(time * 1000, isUtc: true)
            .toLocal(),
        // size 256 · colorScheme 2 (saturação alta) · suavização e neve ligadas
        tileUrlTemplate: '$host$path/256/{z}/{x}/{y}/2/1_1.png',
      ));
    }
    frames.sort((a, b) => a.time.compareTo(b.time));
    return RadarFrames(frames: frames);
  }
}

class RadarFrames {
  const RadarFrames({required this.frames});
  final List<RadarFrame> frames;
  bool get isEmpty => frames.isEmpty;
}

class RadarFrame {
  const RadarFrame({required this.time, required this.tileUrlTemplate});
  final DateTime time;
  final String tileUrlTemplate;
}

class RainViewerException implements Exception {
  const RainViewerException(this.message);
  final String message;
  @override
  String toString() => message;
}
