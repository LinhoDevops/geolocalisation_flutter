import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MapView extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String cityName;

  const MapView({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.cityName,
  }) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController? _mapController;
  bool _isMapLoaded = false;
  Set<Marker> _markers = {};
  final _defaultZoom = 12.0;

  @override
  void initState() {
    super.initState();
    _markers = {
      Marker(
        markerId: MarkerId(widget.cityName),
        position: LatLng(widget.latitude, widget.longitude),
        infoWindow: InfoWindow(
          title: widget.cityName,
          snippet: 'Lat: ${widget.latitude}, Lng: ${widget.longitude}',
        ),
      ),
    };
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      _isMapLoaded = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(widget.latitude, widget.longitude),
          _defaultZoom,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.latitude, widget.longitude),
            zoom: _defaultZoom,
          ),
          markers: _markers,
          mapType: MapType.normal,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          compassEnabled: true,
          // Activer le mode nuit si le thème est sombre
          mapToolbarEnabled: false,
        ),

        // Loading indicator
        if (!_isMapLoaded)
          Container(
            color: Theme.of(context).colorScheme.background.withOpacity(0.7),
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

        // Controls overlay
        Positioned(
          bottom: 16,
          right: 16,
          child: Column(
            children: [
              _buildMapButton(
                context: context,
                icon: Icons.add,
                onPressed: () {
                  _mapController?.animateCamera(
                    CameraUpdate.zoomIn(),
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildMapButton(
                context: context,
                icon: Icons.remove,
                onPressed: () {
                  _mapController?.animateCamera(
                    CameraUpdate.zoomOut(),
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildMapButton(
                context: context,
                icon: Icons.center_focus_strong,
                onPressed: () {
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      LatLng(widget.latitude, widget.longitude),
                      _defaultZoom,
                    ),
                  );
                },
              ),
            ],
          )
              .animate()
              .fadeIn(delay: 800.ms, duration: 400.ms)
              .slideX(begin: 20, end: 0, delay: 800.ms, duration: 400.ms),
        ),

        // City name overlay
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.cityName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 400.ms)
              .slideY(begin: -20, end: 0, delay: 400.ms, duration: 400.ms),
        ),
      ],
    );
  }

  Widget _buildMapButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: Theme.of(context).colorScheme.primary,
        tooltip: icon == Icons.add
            ? 'Zoom in'
            : icon == Icons.remove
            ? 'Zoom out'
            : 'Center map',
      ),
    );
  }
}