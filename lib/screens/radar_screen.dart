import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../data/cities.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

/// Radar de precipitação (RainViewer) sobre mapa escuro (Esri Dark Gray),
/// com animação dos últimos quadros e marcadores das 33 cidades.
class RadarScreen extends ConsumerStatefulWidget {
  const RadarScreen({super.key});

  @override
  ConsumerState<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends ConsumerState<RadarScreen> {
  Timer? _timer;
  int _index = 0;
  int _framesLength = 0;
  bool _initialized = false;
  bool _playing = true;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1100), _tick);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tick(Timer _) {
    if (!_playing || _framesLength < 2) return;
    setState(() => _index = (_index + 1) % _framesLength);
  }

  @override
  Widget build(BuildContext context) {
    final radarAsync = ref.watch(radarFramesProvider);
    final selectedId = ref.watch(selectedCityIdProvider);
    final frames = radarAsync.maybeWhen(
      data: (f) => f.frames,
      orElse: () => null,
    );

    if (frames != null && frames.isNotEmpty) {
      _framesLength = frames.length;
      if (!_initialized) {
        _index = frames.length - 1; // começa no quadro mais recente
        _initialized = true;
      } else if (_index >= frames.length) {
        _index = frames.length - 1;
      }
    }

    final current = (frames != null && frames.isNotEmpty) ? frames[_index] : null;

    return Stack(
      children: [
        // ── Mapa ────────────────────────────────────────────────
        FlutterMap(
          options: MapOptions(
            initialCenter: const LatLng(regionCenterLat, regionCenterLng),
            initialZoom: 8.6,
            minZoom: 6.6,
            maxZoom: 13.5,
            cameraConstraint: CameraConstraint.containCenter(
              bounds: LatLngBounds(
                const LatLng(-34.6, -58.5),
                const LatLng(-26.2, -46.8),
              ),
            ),
            backgroundColor: const Color(0xFF051F38),
          ),
          children: [
            TileLayer(
              // Esri World Dark Gray Canvas — livre, com atribuição
              urlTemplate:
                  'https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Dark_Gray_Base/MapServer/tile/{z}/{y}/{x}',
              userAgentPackageName: 'com.climasul.app',
              maxZoom: 16,
            ),
            if (current != null)
              TileLayer(
                key: ValueKey(current.tileUrlTemplate),
                urlTemplate: current.tileUrlTemplate,
                userAgentPackageName: 'com.climasul.app',
                tileDisplay: const TileDisplay.instantaneous(opacity: 0.72),
                maxNativeZoom: 7,
                maxZoom: 19,
              ),
            MarkerLayer(
              markers: [
                for (final city in allCities)
                  Marker(
                    point: LatLng(city.latitude, city.longitude),
                    width: 24,
                    height: 24,
                    child: GestureDetector(
                      onTap: () =>
                          ref.read(selectedCityIdProvider.notifier).select(city.id),
                      child: Center(
                        child: Container(
                          width: city.id == selectedId ? 16 : 10,
                          height: city.id == selectedId ? 16 : 10,
                          decoration: BoxDecoration(
                            color: city.id == selectedId
                                ? AppColors.amber
                                : AppColors.cyan.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF051F38),
                              width: 1.6,
                            ),
                            boxShadow: city.id == selectedId
                                ? const [
                                    BoxShadow(
                                      color: Color(0x88FFB545),
                                      blurRadius: 10,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                // Rótulo da cidade selecionada
                Marker(
                  point: LatLng(
                    cityById(selectedId).latitude,
                    cityById(selectedId).longitude,
                  ),
                  width: 150,
                  height: 30,
                  alignment: Alignment.topCenter,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xE014294A),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: AppColors.amber.withValues(alpha: 0.6)),
                      ),
                      child: Text(
                        cityById(selectedId).name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.amber,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        // ── Título (canto superior esquerdo) ────────────────────
        Positioned(
          top: 12,
          left: 12,
          child: _GlassChip(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.radar, color: AppColors.amber, size: 20),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RADAR DE CHUVA',
                      style: TextStyle(
                        color: AppColors.grayLight,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                      ),
                    ),
                    Text(
                      'Vale dos Sinos e RMPOA',
                      style: TextStyle(
                          color: const Color(0xFFA9BEDA), fontSize: 9.5),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── Controles de reprodução (canto superior direito) ─────
        Positioned(
          top: 12,
          right: 12,
          child: Row(
            children: [
              _GlassIconButton(
                icon: _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                tooltip: _playing ? 'Pausar' : 'Reproduzir',
                onTap: () => setState(() => _playing = !_playing),
              ),
              const SizedBox(width: 8),
              _GlassIconButton(
                icon: Icons.skip_next_rounded,
                tooltip: 'Quadro mais recente',
                onTap: frames == null || frames.isEmpty
                    ? null
                    : () => setState(() {
                          _index = frames.length - 1;
                          _playing = false;
                        }),
              ),
            ],
          ),
        ),

        // ── Estado: carregando / erro ───────────────────────────
        if (radarAsync.isLoading)
          Positioned(
            top: 74,
            left: 0,
            right: 0,
            child: Center(child: _GlassChip(child: Text(
              'Carregando radar…',
              style: TextStyle(
                  color: const Color(0xFFA9BEDA), fontSize: 11.5),
            ))),
          ),
        if (radarAsync.hasError)
          Positioned(
            top: 74,
            left: 16,
            right: 16,
            child: Center(
              child: _GlassChip(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded,
                        size: 16, color: AppColors.warn),
                    const SizedBox(width: 8),
                    Text(
                      'Radar indisponível — mapa base ativo',
                      style: TextStyle(
                          color: const Color(0xFFA9BEDA), fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => ref.invalidate(radarFramesProvider),
                      child: const Text(
                        'Tentar de novo',
                        style: TextStyle(
                          color: AppColors.amber,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // ── Legenda + horário (canto inferior esquerdo) ─────────
        Positioned(
          bottom: 14,
          left: 12,
          child: _GlassChip(
            child: SizedBox(
              width: 196,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('INTENSIDADE',
                          style: TextStyle(
                            color: const Color(0xFF8FA6C4),
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                          )),
                      if (current != null)
                        Text(
                          '${formatHour(current.time)} · quadro ${_index + 1}/${frames?.length ?? 1}',
                          style: const TextStyle(
                            color: AppColors.amber,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(colors: [
                        Color(0xFF3B82F6),
                        Color(0xFF22D3EE),
                        Color(0xFF34D399),
                        Color(0xFFFBBF24),
                        Color(0xFFEF4444),
                        Color(0xFFE879F9),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Fraca',
                          style: TextStyle(
                              color: const Color(0xFF8FA6C4), fontSize: 9)),
                      Text('Forte',
                          style: TextStyle(
                              color: const Color(0xFF8FA6C4), fontSize: 9)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Radar © RainViewer · Base © Esri, Maxar, Earthstar Geographics',
                    style: TextStyle(
                        color: const Color(0xFF8FA6C4),
                        fontSize: 8,
                        height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Contagem de cidades (canto inferior direito) ─────────
        Positioned(
          bottom: 14,
          right: 12,
          child: _GlassChip(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, size: 12, color: AppColors.cyan),
                SizedBox(width: 5),
                Text(
                  '33 cidades',
                  style: TextStyle(
                    color: const Color(0xFFA9BEDA),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Peças visuais ────────────────────────────────────────────────────

class _GlassChip extends StatelessWidget {
  const _GlassChip({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xCC0D1E3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1FFFFFFF)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x66000000), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: child,
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0xCC0D1E3A),
        shape: CircleBorder(
          side: const BorderSide(color: Color(0x1FFFFFFF)),
        ),
        elevation: 6,
        shadowColor: Colors.black54,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: Icon(
              icon,
              size: 20,
              color: onTap == null
                  ? const Color(0xFF6E88A6)
                  : AppColors.grayLight,
            ),
          ),
        ),
      ),
    );
  }
}
