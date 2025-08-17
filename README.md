# Flutter In-App Inspector

A mini app that provides insights into app performance, requests and logs.

## Features

- **Requests Tab**: View HTTP requests sent from the host app sorted by latest
- **Storage Tab**: View and manage data stored in SharedPreferences and SecureStorage
- **Bloc Tab**: Track and inspect Bloc state changes in real-time
- **Navigation Tab**: Visualize navigation history in a tree-like UI
- **Logs Tab**: View and filter logs with different levels (debug, info, warning, error)

## Usage

Add the app_inspector package to your pubspec.yaml:

```yaml
dependencies:
  flutter_inapp_inspector:
    git:
      url: https://github.com/iamstanlee/flutter_inapp_inspector.git
```

Initialize the App Inspector in your app (dev/qa flavor only):

```dart
import 'package:flutter_inapp_inspector/app_inspector.dart';
import 'package:flutter/foundation.dart';

void main() {
  // Somewhere in your app
  if (appFlavor == 'dev') { // Check if the app is running in development/qa mode
    // Initialize the App Inspector with all available features
    AppInspector.init(
      context,
      sharedPrefs: sharedPrefs, // Optional: Pass your SharedPreferences instance
      secureStorage: secureStorage, // Optional: Pass your FlutterSecureStorage instance
    );
  }
}
```

This will add a floating action button to your app that opens the App Inspector dashboard when tapped.

## Using the Inspectors

### Requests Inspector

The Requests Inspector automatically tracks all HTTP requests made using Dio. You can view the request method, URL,
status code, and response time. The requests are sorted by the latest request first.
```dart
  dio.interceptors.add(AppInspectorDioInterceptor()); 
```

### Bloc Inspector

The Bloc Inspector is automatically set up when you initialize the App Inspector. It will track all Bloc state changes in your app.
You can view the current state of each Bloc and see how it changes over time. This is useful for debugging state management issues.
```dart
  Bloc.observer = AppInspectorBlocObserver();
```

### Navigation Inspector

The Navigation Inspector is automatically set up when you initialize the App Inspector with the `navigatorObservers` parameter. Make sure to use the same list of observers in your MaterialApp.
```dart
  MaterialApp(
    navigatorObservers: [AppInspectorNavigatorObserver()],
    // other properties...
  );
```

### Log Inspector

The Log Inspector provides methods to log messages at different levels:
- Debug: For general debugging information
- Info: For informational messages
- Warning: For potential issues that aren't errors
- Error: For error messages
```dart
final log = LogFactory('main'); 
log.i('App started successfully');
log.d('Debugging some feature');
log.w('This is a warning message');
log.e('An error occurred', stackTrace);
```

You can also add tags to categorize logs and include error and stack trace information for better debugging.