# 💰 Expense Tracker - Mobile App

A comprehensive personal and business expense tracking mobile application built with Flutter, featuring Arabic language support, local storage, REST API integration, and Firebase Cloud Messaging (FCM) for push notifications.

## 🌟 Features

### ✅ Core Features (MVP)
- **Quick Expense Entry** - Add expenses in seconds
- **Daily Expense View** - See today's spending at a glance  
- **Monthly Statistics** - Comprehensive spending analytics
- **Category Tracking** - Organize expenses by categories
- **Offline Storage** - Works without internet using Hive database
- **Multi-Currency Support** - SAR, USD, GBP, EUR
- **Arabic Language Support** - Full RTL layout support
- **Dark Mode** - User-friendly dark theme option
- **Business Mode** - Projects, vendors, and team management
- **Recurring Expenses** - Automate recurring payments
- **Budget Management** - Set and track budgets
- **Push Notifications** - Real-time alerts via Firebase Cloud Messaging

### 📱 Screens
1. **🏠 Home Screen** - Daily expenses and quick add
2. **📊 Statistics Screen** - Monthly totals and pie charts  
3. **⚙️ Settings Screen** - Currency, language, dark mode, data management
4. **🔔 Notifications Screen** - View and manage push notifications
5. **📁 Projects Screen** - Business project management
6. **🏢 Vendors Screen** - Vendor management
7. **💳 Accounts Screen** - Multiple account management

### 🎯 Categories
- 🍔 Food
- 🚗 Transportation  
- 🎬 Entertainment
- 🛍️ Shopping
- 📄 Bills
- 🏥 Healthcare
- 📦 Others

## 🛠️ Technical Stack

- **Frontend:** Flutter (Dart 3.7.0+)
- **Database:** Hive (Local NoSQL) + REST API
- **State Management:** BLoC Pattern (flutter_bloc)
- **Charts:** FL Chart
- **Settings:** SharedPreferences
- **Date Handling:** Intl package
- **Dependency Injection:** GetIt
- **HTTP Client:** Dio
- **Push Notifications:** Firebase Cloud Messaging (FCM)

## 📊 Architecture

```
lib/
├── core/
│   ├── di/                    # Dependency Injection
│   ├── error/                 # Error handling
│   ├── network/               # API client (Dio)
│   ├── state/                 # State management utilities
│   └── storage/               # Local storage helpers
├── features/
│   ├── accounts/              # Account management
│   ├── auth/                   # Authentication
│   ├── budgets/               # Budget management
│   ├── expenses/              # Expense CRUD
│   ├── notifications/         # Push notifications
│   ├── projects/              # Project management
│   ├── recurring_expenses/    # Recurring expenses
│   ├── settings/              # App settings
│   └── statistics/            # Analytics & reports
├── screens/                   # Main screens
├── services/                  # Core services
├── utils/                     # Utilities
└── widgets/                   # Reusable widgets
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.7.0+)
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator
- Firebase account (for notifications)
- Backend API endpoint (for data sync)

### Installation

1. **Clone the repository**
```bash
git clone <your-repo-url>
cd expense-tracker-latest
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Generate Hive adapters** (if needed)
```bash
flutter packages pub run build_runner build
```

4. **Configure Firebase** (see Firebase Setup section below)

5. **Run the app**
```bash
flutter run
```

## 🔥 Firebase Cloud Messaging (FCM) Setup

This section provides complete instructions for setting up Firebase Cloud Messaging for push notifications.

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select existing project
3. Enable Google Analytics (optional)
4. Complete project creation

### Step 2: Add Android App to Firebase

1. In Firebase Console, click "Add app" → Select Android
2. Register your app:
   - **Android package name**: `com.example.expense_tracker` (check `android/app/build.gradle.kts`)
   - **App nickname**: Expense Tracker (optional)
   - **Debug signing certificate SHA-1**: (optional for now)
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`

### Step 3: Configure Android for FCM

#### 3.1 Update `android/build.gradle.kts` (Project level)

Add Google Services classpath:

```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

#### 3.2 Update `android/app/build.gradle.kts` (App level)

Add at the **top** of the file:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")  // Add this
}
```

Add dependencies:

```kotlin
dependencies {
    // ... existing dependencies
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-messaging")
}
```

#### 3.3 Update `android/app/src/main/AndroidManifest.xml`

Add permissions and service:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Add these permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    
    <application
        android:label="expense_tracker"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Add Firebase Messaging Service -->
        <service
            android:name="com.google.firebase.messaging.FirebaseMessagingService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>
        
        <!-- ... rest of your application -->
    </application>
</manifest>
```

### Step 4: Add iOS App to Firebase

1. In Firebase Console, click "Add app" → Select iOS
2. Register your app:
   - **iOS bundle ID**: `com.example.expenseTracker` (check `ios/Runner.xcodeproj`)
   - **App nickname**: Expense Tracker (optional)
3. Download `GoogleService-Info.plist`
4. Place it in: `ios/Runner/GoogleService-Info.plist`
5. Open `ios/Runner.xcworkspace` in Xcode
6. Right-click `Runner` folder → "Add Files to Runner"
7. Select `GoogleService-Info.plist` → Ensure "Copy items if needed" is checked

### Step 5: Configure iOS for FCM

#### 5.1 Update `ios/Podfile`

Ensure Firebase pods are included:

```ruby
platform :ios, '12.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  
  # Firebase pods
  pod 'Firebase/Messaging'
end
```

Run:
```bash
cd ios
pod install
cd ..
```

#### 5.2 Update `ios/Runner/AppDelegate.swift`

```swift
import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    
    // Request notification permissions
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { _, _ in }
      )
    } else {
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }
    
    application.registerForRemoteNotifications()
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
  }
}
```

#### 5.3 Enable Push Notifications in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select `Runner` target → "Signing & Capabilities"
3. Click "+ Capability"
4. Add "Push Notifications"
5. Add "Background Modes" → Check "Remote notifications"

### Step 6: Add Required Flutter Packages

Update `pubspec.yaml`:

```yaml
dependencies:
  # ... existing dependencies
  
  # Firebase
  firebase_core: ^3.6.0
  firebase_messaging: ^14.7.9
  
  # Local notifications
  flutter_local_notifications: ^16.3.0
  
  # Permissions
  permission_handler: ^11.3.0
```

Run:
```bash
flutter pub get
```

### Step 7: Initialize Firebase in Flutter

Update `lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart'; // Generated file

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // ... rest of your initialization
  
  runApp(const ExpenseTrackerApp());
}
```

### Step 8: Generate Firebase Options File

Run FlutterFire CLI:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

This will:
- Detect your Firebase projects
- Generate `lib/firebase_options.dart`
- Configure for both Android and iOS

**Alternative (Manual):**

If FlutterFire CLI doesn't work, create `lib/firebase_options.dart` manually:

```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web not supported');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Platform not supported');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    iosBundleId: 'com.example.expenseTracker',
  );
}
```

Get these values from:
- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

### Step 9: Request Permissions and Get FCM Token

Create a notification service (e.g., `lib/services/notification_service.dart`):

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Request permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
    
    // Send token to your backend
    if (token != null) {
      await _sendTokenToBackend(token);
    }

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print('New FCM Token: $newToken');
      _sendTokenToBackend(newToken);
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Foreground message: ${message.messageId}');
    
    // Show local notification
    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'expense_tracker_channel',
          'Expense Tracker Notifications',
          channelDescription: 'Notifications for expense tracker app',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: message.data.toString(),
    );
  }

  static void _handleNotificationTap(RemoteMessage message) {
    print('Notification opened: ${message.messageId}');
    // Navigate to appropriate screen based on message.data
  }

  static Future<void> _sendTokenToBackend(String token) async {
    // TODO: Send token to your backend API
    // POST /notifications/register-device
    // Body: { deviceToken: token, platform: 'android' or 'ios' }
  }
}
```

### Step 10: Initialize in main.dart

Update `lib/main.dart`:

```dart
import 'package:expense_tracker/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize notifications
  await NotificationService.initialize();
  
  // ... rest of initialization
  
  runApp(const ExpenseTrackerApp());
}
```

## 📡 Backend API Integration

### Notification Endpoints

Your backend should implement these endpoints:

#### 1. Register Device Token
```
POST /notifications/register-device
Body: {
  "deviceToken": "fcm_token_here",
  "platform": "android" | "ios"
}
Response: { "success": true }
```

#### 2. Get Notifications
```
GET /notifications
Headers: { "Authorization": "Bearer <token>" }
Response: {
  "notifications": [...],
  "unreadCount": 5
}
```

#### 3. Get Unread Count
```
GET /notifications/unread-count
Response: { "count": 5 }
```

#### 4. Mark as Read
```
PUT /notifications/:id/read
Response: { "success": true }
```

#### 5. Mark All as Read
```
PUT /notifications/read-all
Response: { "success": true }
```

#### 6. Delete Notification
```
DELETE /notifications/:id
Response: { "success": true }
```

#### 7. Get Notification Settings
```
GET /notifications/settings
Response: {
  "enablePushNotifications": true,
  "budgetNotifications": true,
  "recurringExpenseNotifications": true,
  "projectNotifications": true,
  "approvalNotifications": true
}
```

#### 8. Update Notification Settings
```
PUT /notifications/settings
Body: {
  "budgetNotifications": false,
  ...
}
Response: { "success": true }
```

### Notification Types

**Personal:**
- `budget_warning` - Budget warning (80%)
- `budget_exceeded` - Budget exceeded (100%)
- `recurring_expense_due` - Recurring expense due soon
- `recurring_expense_added` - Recurring expense added
- `account_low_balance` - Low account balance

**Business:**
- `project_budget_warning` - Project budget warning
- `project_budget_exceeded` - Project budget exceeded
- `project_deadline_near` - Project deadline approaching
- `project_deadline_today` - Project deadline today
- `expense_needs_approval` - Expense needs approval
- `expense_approved` - Expense approved
- `expense_rejected` - Expense rejected

## 🧪 Testing Notifications

### Test from Firebase Console

1. Go to Firebase Console → Cloud Messaging
2. Click "Send test message"
3. Enter FCM token (from app logs)
4. Enter title and message
5. Click "Test"

### Test from Backend

Use FCM REST API:

```bash
curl -X POST https://fcm.googleapis.com/v1/projects/YOUR_PROJECT_ID/messages:send \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "token": "FCM_TOKEN",
      "notification": {
        "title": "Test Notification",
        "body": "This is a test message"
      },
      "data": {
        "type": "budget_warning",
        "actionUrl": "/budgets"
      }
    }
  }'
```

### Test Notification Payload Format

```json
{
  "notification": {
    "title": "Budget Warning",
    "body": "You've used 80% of your monthly budget"
  },
  "data": {
    "type": "budget_warning",
    "budgetId": "123",
    "actionUrl": "/budgets/123"
  }
}
```

## 📦 Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^3.6.0
  firebase_messaging: ^14.7.9
  
  # Local notifications
  flutter_local_notifications: ^16.3.0
  
  # Permissions
  permission_handler: ^11.3.0
  
  # Local database
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Charts
  fl_chart: ^1.1.1
  
  # Settings
  shared_preferences: ^2.5.4
  
  # Dependency injection
  get_it: ^9.2.0
  
  # State management
  flutter_bloc: ^9.1.1
  bloc: ^9.1.0
  equatable: ^2.0.7
  
  # HTTP client
  dio: ^5.4.0
  
  # Utilities
  uuid: ^4.5.2
  intl: ^0.20.2
  image_picker: ^1.2.1
  path_provider: ^2.1.5
  url_launcher: ^6.3.2
  lottie: ^3.3.2
  crypto: any
```

## 🏗️ Building for Release

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

### iOS IPA
```bash
flutter build ios --release
```

## 🌍 Localization

### Supported Languages
- **English** (en) - Default
- **Arabic** (ar) - Full RTL support

### Currency Support
- **SAR** (ر.س) - Saudi Riyal
- **USD** ($) - US Dollar  
- **GBP** (£) - British Pound
- **EUR** (€) - Euro

## 🔒 Security Notes

1. **Never commit Firebase config files to public repos**
   - Add to `.gitignore`:
     ```
     android/app/google-services.json
     ios/Runner/GoogleService-Info.plist
     lib/firebase_options.dart
     ```

2. **Use environment variables for sensitive data**
   - API endpoints
   - Firebase project IDs
   - Backend tokens

3. **Validate FCM tokens on backend**
   - Verify token format
   - Check token ownership
   - Handle expired tokens

## 🐛 Troubleshooting

### Common Issues

#### 1. "No Firebase App '[DEFAULT]' has been created"
**Solution:** Ensure `Firebase.initializeApp()` is called before using Firebase services.

#### 2. "MissingPluginException" on Android
**Solution:** 
```bash
flutter clean
flutter pub get
cd android && ./gradlew clean && cd ..
flutter run
```

#### 3. Notifications not received on iOS
**Solution:**
- Check APNs certificate in Firebase Console
- Verify Push Notifications capability in Xcode
- Ensure device is registered for remote notifications

#### 4. Token not generated
**Solution:**
- Check internet connection
- Verify `google-services.json` / `GoogleService-Info.plist` are correct
- Check app permissions

#### 5. Background notifications not working
**Solution:**
- Ensure `FirebaseMessaging.onBackgroundMessage` is top-level function
- Check Android manifest service configuration
- Verify iOS background modes

## 📚 Additional Resources

- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- [FCM REST API](https://firebase.google.com/docs/cloud-messaging/send-message)

## 🤝 Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙋‍♂️ Support

For support and questions:
- **Email:** support@expensetracker.com
- **Issues:** GitHub Issues tab
- **Documentation:** See `DEVELOPER_GUIDE.md` for detailed development guide

## 🔮 Roadmap

### Version 1.1 (Next Release)
- [x] Push notifications via FCM
- [ ] OCR for receipt scanning
- [ ] Subscription management
- [ ] Advanced analytics

### Version 1.2 (Future)
- [ ] Multi-account support
- [ ] Bill reminders
- [ ] Expense photos
- [ ] Export to Excel/PDF

### Version 2.0 (Major Update)
- [ ] Web dashboard
- [ ] Team expense sharing
- [ ] AI spending insights
- [ ] Advanced reporting

---

Made with ❤️ using Flutter
