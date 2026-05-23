import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:provider/provider.dart';
import 'package:registagrodriver/components/google_maps/location_provider.dart';

class MapScreen extends StatefulWidget {
  final gmaps.LatLng destino;
  const MapScreen({super.key, required this.destino});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  gmaps.GoogleMapController? _mapController;
  bool _modoDestino = false;

  static const gmaps.LatLng _defaultLatLng = gmaps.LatLng(-8.8583, 13.2312); // Aeroporto de Luanda

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final loc = context.read<SourceLocationProvider>();
      await loc.fetchCurrentLocation();
      if (!mounted) return;
      await loc.setDestination(widget.destino);

      if (loc.currentLatLng != null) {
        _mapController?.animateCamera(
          gmaps.CameraUpdate.newLatLngZoom(loc.currentLatLng!, 15),
        );
      }
      _slideController.forward();
    });
  }

  Set<gmaps.Polyline> _buildPolylines(SourceLocationProvider loc) {
    if (loc.currentLatLng == null || loc.destinationLatLng == null) return {};
    return {
      gmaps.Polyline(
        polylineId: const gmaps.PolylineId('rota'),
        points: [loc.currentLatLng!, loc.destinationLatLng!],
        color: Colors.blue.shade700,
        width: 5,
        patterns: [
          gmaps.PatternItem.dash(30),
          gmaps.PatternItem.gap(15),
        ],
      ),
    };
  }

  Set<gmaps.Marker> _buildMarkers(SourceLocationProvider loc) {
    final markers = <gmaps.Marker>{};

    if (loc.currentLatLng != null) {
      markers.add(gmaps.Marker(
        markerId: const gmaps.MarkerId('origem'),
        position: loc.currentLatLng!,
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
            gmaps.BitmapDescriptor.hueGreen),
        infoWindow: gmaps.InfoWindow(
          title: '📍 Origem',
          snippet: loc.currentAddress.isNotEmpty ? loc.currentAddress : null,
        ),
      ));
    }

    if (loc.destinationLatLng != null) {
      markers.add(gmaps.Marker(
        markerId: const gmaps.MarkerId('destino'),
        position: loc.destinationLatLng!,
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
            gmaps.BitmapDescriptor.hueRed),
        infoWindow: gmaps.InfoWindow(
          title: '🏁 Destino',
          snippet: loc.destinationAddress.isNotEmpty ? loc.destinationAddress : null,
        ),
      ));
    }

    return markers;
  }

  void _onMapTap(gmaps.LatLng latLng, SourceLocationProvider loc) async {
    HapticFeedback.lightImpact();
    await loc.updateLocation(latLng);
    _mapController?.animateCamera(gmaps.CameraUpdate.newLatLng(latLng));
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
              child: gmaps.GoogleMap(
                initialCameraPosition: gmaps.CameraPosition(
                  target: loc.currentLatLng ?? _defaultLatLng,
                  zoom: 15,
                ),
                onMapCreated: (controller) => _mapController = controller,
                markers: _buildMarkers(loc),
                polylines: _buildPolylines(loc),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
                onTap: (latLng) => _onMapTap(latLng, loc),
              ),
            ),
            if (loc.isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(0.8),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2.5,
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
                        : loc.error ?? (loc.currentAddress.isNotEmpty
                            ? loc.currentAddress
                            : 'Toque no mapa para definir origem'),
                    isLoading: loc.isLoading,
                    hasError: loc.error != null,
                  ),
                  const SizedBox(height: 8),
                  _InfoBar(
                    cor: Colors.red.shade600,
                    icone: Icons.location_on,
                    label: loc.destinationLatLng == null
                        ? 'Toque no mapa para definir destino'
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
              bottom: 24 + bottomPad,
              right: 16,
              child: Column(
                children: [
                  _CircleButton(
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      await loc.fetchCurrentLocation();
                      if (loc.currentLatLng != null) {
                        _mapController?.animateCamera(
                          gmaps.CameraUpdate.newLatLngZoom(loc.currentLatLng!, 15),
                        );
                      }
                    },
                    child: const Icon(Icons.my_location, size: 20, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  if (loc.destinationLatLng != null)
                    _CircleButton(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        loc.clearDestination();
                      },
                      child: const Icon(Icons.close, size: 20, color: Colors.red),
                    ),
                ],
              ),
            ),
            Positioned(
              bottom: 24 + bottomPad,
              left: 16,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      _ToggleBtn(
                        label: 'Origem',
                        ativo: !_modoDestino,
                        cor: Colors.green.shade600,
                        onTap: () => setState(() => _modoDestino = false),
                      ),
                      _ToggleBtn(
                        label: 'Destino',
                        ativo: _modoDestino,
                        cor: Colors.red.shade600,
                        onTap: () => setState(() => _modoDestino = true),
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
    _mapController?.dispose();
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
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 3),
          )
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
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}