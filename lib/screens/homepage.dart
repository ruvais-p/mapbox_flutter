import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  mp.MapboxMap? mapboxController;
  StreamSubscription<gl.Position>? userPositionStream;

  @override
  void initState() {
    super.initState();
    // Map setup will be done once the map is created.
  }

  @override
  void dispose() {
    // Cancel the position tracking stream when the widget is disposed to avoid memory leaks.
    userPositionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: mp.MapWidget(
        // Calls `_onMapCreated` when the map is successfully created.
        onMapCreated: _onMapCreated,
        styleUri: mp.MapboxStyles.DARK, // Sets the map style to dark theme.
      ),
    );
  }

  void _onMapCreated(mp.MapboxMap controller) async {
    setState(() {
      mapboxController = controller; // Stores the map controller for later use.
    });

    // Enable and configure the location component.
    mapboxController?.location.updateSettings(mp.LocationComponentSettings(
      enabled: true,
      pulsingEnabled: true,
      pulsingColor: Colors.blue.value, // Set pulsing color to blue.
    ));

    // Create an annotation (marker) manager.
    final pointAnnotationManager =
        await mapboxController?.annotations.createPointAnnotationManager();

    // Load a high-quality marker image from assets.
    final Uint8List imageData = await loadHQMarkerImage();

    // Define marker options with an icon and coordinates.
    mp.PointAnnotationOptions pointAnnotationOptions =
        mp.PointAnnotationOptions(
            image: imageData,
            iconSize: 1, // Adjust icon size as needed.
            geometry:
                mp.Point(coordinates: mp.Position(-122.3012186, 37.33233141)));

    // Add the marker to the map.
    pointAnnotationManager?.create(pointAnnotationOptions);

    // Start tracking the user's position after the map is ready.
    _setupPositionTracking();
  }

  Future<void> _setupPositionTracking() async {
    try {
      // Check if location services are enabled.
      bool serviceEnabled = await gl.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("Location services are disabled");
      }

      // Check and request location permissions.
      gl.LocationPermission permission = await gl.Geolocator.checkPermission();
      if (permission == gl.LocationPermission.denied) {
        permission = await gl.Geolocator.requestPermission();
        if (permission == gl.LocationPermission.denied) {
          throw Exception("Location permissions were denied");
        }
      }

      // Handle case where location permissions are permanently denied.
      if (permission == gl.LocationPermission.deniedForever) {
        throw Exception("Location permissions are permanently denied");
      }

      // Set up location tracking settings.
      gl.LocationSettings locationSettings = gl.LocationSettings(
        accuracy: gl.LocationAccuracy.high, // Use high accuracy for GPS.
        distanceFilter: 100, // Update location when the user moves 100 meters.
      );

      // Cancel any existing position tracking stream before starting a new one.
      userPositionStream?.cancel();

      // Start listening to position updates.
      userPositionStream = gl.Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((gl.Position? position) {
        if (position != null && mapboxController != null) {
          // Update the camera position to follow the user's location.
          mapboxController!.setCamera(
            mp.CameraOptions(
              center: mp.Point(
                coordinates: mp.Position(
                  position.longitude,
                  position.latitude,
                ),
              ),
              zoom: 15.0, // Set zoom level for better visibility.
            ),
          );
        }
      });

      // Get the initial position and center the map on it.
      final initialPosition = await gl.Geolocator.getCurrentPosition();
      if (mapboxController != null) {
        mapboxController!.setCamera(
          mp.CameraOptions(
            center: mp.Point(
              coordinates: mp.Position(
                initialPosition.longitude,
                initialPosition.latitude,
              ),
            ),
            zoom: 15.0,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error setting up location tracking: $e");
      // Handle errors such as permission denial or service issues.
    }
  }

  // Loads a high-quality marker image from the assets folder.
  Future<Uint8List> loadHQMarkerImage() async {
    var byteData = await rootBundle.load("assets/Floating Button.png");
    return byteData.buffer.asUint8List();
  }
}
