# Soil Health Monitoring App

A Flutter application for monitoring soil health through Bluetooth-connected sensors with Firebase integration.

## Features

- **Bluetooth Connectivity**: Connect to Bluetooth-enabled soil monitoring devices
- **Real-time Data**: Capture temperature and moisture readings
- **Firebase Integration**: Store and sync data across devices
- **Authentication**: Secure login/signup with Firebase Auth
- **Data Visualization**: View historical data in lists and charts
- **Clean UI**: Intuitive Material Design interface

## Setup Instructions

### Prerequisites

1. Flutter SDK (3.0.0 or later)
2. Android Studio or VS Code
3. Firebase project with Firestore and Authentication enabled
4. Android device or emulator for testing

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd soil_health_monitoring
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
    - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
    - Add an Android app to your project
    - Download `google-services.json` and place it in `android/app/`
    - Enable Firestore Database and Authentication (Email/Password) in Firebase Console

4. **Android Configuration**
    - Ensure your `android/app/build.gradle` has minimum SDK version 21
    - Add Bluetooth permissions (already included in the template)

5. **Run the app**
   ```bash
   flutter run
   ```

### Building APK

```bash
flutter build apk --release
```

The APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`

## Project Structure

```
lib/
├── models/
│   └── soil_reading.dart       # Data model for soil readings
├── providers/
│   ├── auth_provider.dart      # Authentication state management
│   ├── bluetooth_provider.dart # Bluetooth connectivity
│   └── data_provider.dart      # Firebase data operations
├── screens/
│   ├── login_screen.dart       # Authentication UI
│   ├── home_screen.dart        # Main dashboard
│   ├── history_screen.dart     # Data visualization
│   └── bluetooth_screen.dart   # Device management
└── main.dart                   # App entry point
```

## Assumptions Made

### Bluetooth Implementation
- **Mock Data**: Since hardware access may be limited, the app generates mock readings (temperature: 18-30°C, moisture: 30-70%)
- **Device Protocol**: Assumes standard Bluetooth serial communication
- **Bonded Devices**: Only shows already paired Bluetooth devices from system settings
- **Data Format**: Expects simple numeric values for temperature and moisture

### Firebase Structure
- **User-based Collections**: Data is stored under `users/{userId}/readings/`
- **Real-time Sync**: Uses Firestore streams for live updates
- **Offline Support**: Basic offline capabilities through Firestore caching

### UI/UX Decisions
- **Material Design**: Follows Android Material Design guidelines
- **Responsive Layout**: Adapts to different screen sizes
- **Error Handling**: Basic error messages with snackbars
- **State Management**: Uses Provider pattern for simplicity

## Configuration Files

### Android Permissions
The app requests the following permissions:
- `BLUETOOTH` and `BLUETOOTH_ADMIN` for device connectivity
- `ACCESS_FINE_LOCATION` for Bluetooth scanning
- `INTERNET` for Firebase connectivity

### Firebase Security Rules
Recommended Firestore rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/readings/{readingId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Troubleshooting

### Common Issues

1. **Bluetooth Connection Failed**
    - Ensure device is paired in system Bluetooth settings
    - Check that location permissions are granted
    - Verify device is in range and powered on

2. **Firebase Connection Issues**
    - Verify `google-services.json` is in correct location
    - Check internet connectivity
    - Ensure Firebase project configuration is correct

3. **Build Errors**
    - Run `flutter clean` and `flutter pub get`
    - Check that all dependencies are compatible
    - Verify Android SDK and build tools are up to date

### Mock vs Real Integration

The current implementation uses mock data for testing. To integrate with real hardware:

1. Implement actual Bluetooth communication in `BluetoothProvider.getReading()`
2. Parse incoming data according to your device's protocol
3. Handle connection stability and error recovery
4. Add device-specific configuration if needed

## Dependencies

- `provider: ^6.1.1` - State management
- `firebase_core: ^2.24.2` - Firebase core functionality
- `firebase_auth: ^4.15.3` - Authentication
- `cloud_firestore: ^4.13.6` - Database
- `flutter_blue_plus: ^1.35.5` - Bluetooth connectivity
- `permission_handler: ^11.0.1` - Runtime permissions
- `syncfusion_flutter_charts: ^30.2.7` - Data visualization
- `intl: ^0.18.1` - Date formatting

## License

This project is created for DDverse Initiatives Private Limited as part of an Android App Development Assignment.
