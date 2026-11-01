import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:registagrodriver/models/geo_point.dart';
import 'package:registagrodriver/providers/location_provider.dart';

/// Map screen using OpenStreetMap tiles + OSRM route (unified with Web).
class MapScreen extends StatefulWidget {
  final String requestId;
  const MapScreen({super.key, required this.requestId});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  bool _modoDestino = false;

  static const LatLng _defaultLatLng = LatLng(-8.8583, 13.2312);

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final loc = context.read<SourceLocationProvider>();
      await loc.fetchCurrentLocation(widget.requestId);
      if (!mounted) return;

      _fitBounds(loc);
      _slideController.forward();
    });
  }

  LatLng _toLatLng(GeoPoint p) => LatLng(p.latitude, p.longitude);

  void _fitBounds(SourceLocationProvider loc) {
    if (loc.currentPoint != null && loc.destinationPoint != null) {
      final points = [
        _toLatLng(loc.currentPoint!),
        _toLatLng(loc.destinationPoint!),
        ...loc.routePoints.map(_toLatLng),
      ];
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(80)),
      );
    } else if (loc.currentPoint != null) {
      _mapController.move(_toLatLng(loc.currentPoint!), 15);
    }
  }

  List<Marker> _buildMarkers(SourceLocationProvider loc) {
    final markers = <Marker>[];

    if (loc.currentPoint != null) {
      markers.add(
        Marker(
          point: _toLatLng(loc.currentPoint!),
          width: 40,
          height: 40,
          child: Icon(Icons.trip_origin, color: Colors.green.shade700, size: 32),
        ),
      );
    }

    if (loc.destinationPoint != null) {
      markers.add(
        Marker(
          point: _toLatLng(loc.destinationPoint!),
          width: 40,
          height: 40,
          child: Icon(Icons.location_on, color: Colors.red.shade700, size: 36),
        ),
      );
    }

    return markers;
  }

  List<Polyline> _buildPolylines(SourceLocationProvider loc) {
    if (loc.routePoints.length < 2) return const [];
    return [
      Polyline(
        points: loc.routePoints.map(_toLatLng).toList(),
        color: Colors.blue.shade700,
        strokeWidth: 5,
      ),
    ];
  }

  Future<void> _onMapTap(
    LatLng latLng,
    SourceLocationProvider loc,
  ) async {
    HapticFeedback.lightImpact();
    if (_modoDestino) {
      await loc.setDestination(widget.requestId);
      if (!mounted) return;
      _fitBounds(loc);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<SourceLocationProvider>();
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned.fill(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: loc.currentPoint != null
                      ? _toLatLng(loc.currentPoint!)
                      : _defaultLatLng,
                  initialZoom: 15,
                  onTap: (_, point) => _onMapTap(point, loc),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.registagro.carrier',
                  ),
                  PolylineLayer(polylines: _buildPolylines(loc)),
                  MarkerLayer(markers: _buildMarkers(loc)),
                ],
              ),
            ),
            if (loc.isLoading)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.8),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  _InfoBar(
                    cor: Colors.green.shade600,
                    icone: Icons.trip_origin,
                    label: loc.isLoading
                        ? 'A obter localização...'
                        : loc.error ??
                              (loc.currentAddress.isNotEmpty
                                  ? loc.currentAddress
                                  : 'A carregar origem...'),
                    isLoading: loc.isLoading,
                    hasError: loc.error != null,
                  ),
                  const SizedBox(height: 8),
                  _InfoBar(
                    cor: Colors.red.shade600,
                    icone: Icons.location_on,
                    label: loc.destinationPoint == null
                        ? 'A carregar destino...'
                        : loc.destinationAddress.isNotEmpty
                            ? loc.destinationAddress
                            : 'Destino definido',
                    isLoading: false,
                    hasError: false,
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 30 + bottomPad,
              right: 16,
              child: Column(
                children: [
                  _CircleButton(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom + 1,
                      );
                    },
                    child: const Icon(Icons.add, size: 20, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  _CircleButton(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom - 1,
                      );
                    },
                    child: const Icon(
                      Icons.remove,
                      size: 20,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _CircleButton(
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      await loc.fetchCurrentLocation(widget.requestId);
                      if (!mounted) return;
                      _fitBounds(loc);
                    },
                    child: const Icon(
                      Icons.my_location,
                      size: 20,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 30 + bottomPad,
              left: 16,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _ToggleBtn(
                        label: 'Origem',
                        ativo: !_modoDestino,
                        cor: Colors.green.shade600,
                        onTap: () {
                          setState(() => _modoDestino = false);
                          if (loc.currentPoint != null) {
                            _mapController.move(
                              _toLatLng(loc.currentPoint!),
                              16,
                            );
                          }
                        },
                      ),
                      _ToggleBtn(
                        label: 'Destino',
                        ativo: _modoDestino,
                        cor: Colors.red.shade600,
                        onTap: () {
                          setState(() => _modoDestino = true);
                          if (loc.destinationPoint != null) {
                            _mapController.move(
                              _toLatLng(loc.destinationPoint!),
                              16,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _mapController.dispose();
    super.dispose();
  }
}

class _InfoBar extends StatelessWidget {
  final Color cor;
  final IconData icone;
  final String label;
  final bool isLoading;
  final bool hasError;

  const _InfoBar({
    required this.cor,
    required this.icone,
    required this.label,
    required this.isLoading,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          isLoading
              ? SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: cor),
                )
              : Icon(icone, size: 16, color: cor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: hasError ? Colors.red.shade400 : Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool ativo;
  final Color cor;
  final VoidCallback onTap;

  const _ToggleBtn({
    required this.label,
    required this.ativo,
    required this.cor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: ativo ? cor : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: ativo ? Colors.white : Colors.black54,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _CircleButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}
