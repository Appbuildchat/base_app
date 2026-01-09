# Map Domain Rules

## STRICT Scope
- ONLY Google Maps implementation (NO Apple Maps, OpenStreetMap, etc.)
- ONLY location services via Google APIs
- ALWAYS copy templates/domain/map/ structure first

## MANDATORY Setup Order

### 1. Package Installation
```bash
flutter pub add google_maps_flutter
flutter pub add geolocator  
flutter pub add geocoding
flutter pub add permission_handler
```

### 2. Android Manifest Permissions
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<!-- At top level -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

<!-- In <application> after </activity> -->
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="API_KEY"/>
```

### 3. iOS Permissions
Add to `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to show your current location on the map.</string>
```

## Required File Structure
```
domain/map/
├── functions/
│   ├── map_function.dart
│   ├── map_repository.dart
│   └── location_search_function.dart
└── presentation/
    ├── screens/
    │   └── map_screen.dart
    └── widgets/
        ├── simple_map_widget.dart
        ├── map_container_widget.dart
        └── map_with_search_widget.dart
```

## Template Widget Usage

### Simple Map Display
```dart
SimpleMapWidget(
  latitude: 37.5665,
  longitude: 126.9780,
  height: 200,
  markerTitle: 'Location',
)
```

### Full Map with Controls
```dart
MapContainerWidget(
  showDistanceSlider: true,
  showLocationButton: true,
  onMapTap: (position) { },
)
```

### Search-Enabled Map
```dart
MapWithSearchWidget(
  showControls: true,
  onLocationSelected: (result) { },
)
```

## FORBIDDEN
- Using any map provider except Google Maps
- Creating custom map implementations from scratch
- Skipping permission setup
- Direct API calls without using template functions
- Modifying template structure without copying first