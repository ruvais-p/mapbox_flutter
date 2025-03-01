# Mapbox Flutter Location Tracker

## Overview
This Flutter project integrates **Mapbox Maps** to display an interactive map with real-time location tracking. The app continuously updates the user's position and displays it on the map using **Mapbox Maps SDK** and **Geolocator**.

## Features
- Displays an interactive Mapbox map
- Tracks user's real-time location using **Geolocator**
- Custom marker support for annotations
- Automatic camera adjustment to follow user movement
- Environment variable support for API keys using **flutter_dotenv**

## Installation

### Prerequisites
Make sure you have:
- Flutter installed (Check [Flutter Install Guide](https://flutter.dev/docs/get-started/install))
- A **Mapbox Access Token** (Create an account and get a token from [Mapbox](https://account.mapbox.com))

### Steps
1. **Clone the repository:**
   ```sh
   git clone [https://github.com/your-repo/flutter-mapbox-tracker.git](https://github.com/ruvais-p/mapbox_flutter.git)
   cd flutter-mapbox-tracker
   ```
2. **Install dependencies:**
   ```sh
   flutter pub get
   ```
3. **Set up environment variables:**
   - Create a `.env` file in the root of the project and add:
     ```env
     MAPBOX_ACCESS_TOKEN=your_mapbox_access_token_here
     ```
4. **Run the app:**
   ```sh
   flutter run
   ```

## Project Structure
```
|-- assets/
|   |-- Floating Button.png 
|-- lib/
|   |-- main.dart             # Entry point of the application
|   |-- screens/
|   |   |-- homepage.dart     # Main map screen with location tracking
|-- pubspec.yaml              # Dependencies and package configurations
|-- .env                      # Environment variables (not committed to Git)
```

## Code Explanation

### `main.dart`
- Loads environment variables using **flutter_dotenv**
- Initializes **Mapbox API Token** from `.env`
- Runs the **MyApp** widget

```dart
void main() async {
  await setup();
  runApp(const MyApp());
}

Future<void> setup() async {
  await dotenv.load(fileName: '.env');
  MapboxOptions.setAccessToken(dotenv.env['MAPBOX_ACCESS_TOKEN']!);
}
```

### `homepage.dart`
- Displays **Mapbox Map**
- Tracks **user location** and updates the camera position
- Uses **Geolocator** to fetch real-time location updates
- Loads a custom marker image

```dart
void _onMapcreated(mp.MapboxMap controller) async {
  setState(() {
    mapboxController = controller;
  });

  // Enable location tracking
  mapboxController?.location.updateSettings(
    mp.LocationComponentSettings(enabled: true, pulsingEnabled: true, pulsingColor: Colors.blue.value),
  );

  // Load custom marker
  final Uint8List imagedata = await loadHQmarkerImage();
  mp.PointAnnotationOptions pointAnnotationOptions = mp.PointAnnotationOptions(
    image: imagedata,
    iconSize: 1,
    geometry: mp.Point(coordinates: mp.Position(-122.3012186, 37.33233141)),
  );
  await mapboxController?.annotations.createPointAnnotationManager()?.create(pointAnnotationOptions);
}
```

## Dependencies
This project uses the following Flutter packages:
- **mapbox_maps_flutter** → Mapbox Maps SDK
- **geolocator** → Fetch real-time user location
- **flutter_dotenv** → Manage environment variables


