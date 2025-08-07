# 🏦 Tap Invest - Bond Information Platform

A sophisticated Flutter application for searching and analyzing financial bonds in the Indian market. The app provides users with comprehensive bond information, financial analytics, and investment insights through an intuitive, pixel-perfect interface.

## 📱 Overview

Tap Invest is a financial application designed for investors, analysts, and financial professionals who need quick access to bond information using ISIN (International Securities Identification Number) identifiers. The app features real-time search capabilities, detailed financial analytics, and professional-grade visualizations.

### Key Features

- 🔍 **Advanced Search**: Search bonds by Issuer Name or ISIN with intelligent filtering
- 📊 **Financial Analytics**: Interactive charts showing EBITDA and Revenue trends
- 📋 **Detailed Bond Information**: Comprehensive issuer details and corporate information
- ⚡ **Real-time Data**: Live API integration with up-to-date bond information
- 🎨 **Pixel-Perfect UI**: Material Design 3 with smooth animations and haptic feedback
- 📱 **Cross-Platform**: Supports Android, iOS, Windows, macOS, Linux, and Web

## 🏗️ Architecture

The application follows **Clean Architecture** principles with a clear separation of concerns:

```
lib/
├── core/
│   └── di/                 # Dependency Injection (GetIt + Injectable)
├── data/
│   ├── models/            # Freezed data models with JSON serialization
│   └── repository/        # Repository pattern for data access
└── presentation/
  ├── cubit/             # BLoC/Cubit for state management
  └── screens/           # UI screens and widgets
```

### Tech Stack

- **Framework**: Flutter 3.29.3 (Dart 3.7.2)
- **State Management**: BLoC/Cubit pattern
- **Dependency Injection**: GetIt + Injectable
- **Data Models**: Freezed + JSON Annotation
- **HTTP Client**: Dio
- **UI Components**: Material Design 3
- **Charts**: FL Chart
- **Animations**: Flutter Staggered Animations
- **Image Caching**: Cached Network Image
- **Assets**: Flutter SVG, Shimmer effects
- **UX Enhancement**: Haptic Feedback

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: 3.29.3 or higher
- **Dart SDK**: 3.7.2 or higher
- **IDE**: VS Code, Android Studio, or IntelliJ IDEA
- **Platforms**: 
  - Android: SDK 21+ (Android 5.0+)
  - iOS: iOS 12.0+
  - Windows: Windows 10+
  - macOS: macOS 10.14+
  - Linux: Ubuntu 18.04+

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd tap_invest
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code (Freezed, Injectable, JSON)**
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

### Building for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release

# Web
flutter build web --release
```

## 📡 API Integration

The application integrates with two primary APIs:

### Bond List API
- **Endpoint**: `https://eol122duf9sy4de.m.pipedream.net`
- **Purpose**: Retrieves list of available bonds
- **Response**: Array of bond summaries with basic information

### Bond Detail API
- **Endpoint**: `https://eo61q3zd4heiwke.m.pipedream.net`
- **Purpose**: Fetches detailed information for specific bonds
- **Response**: Comprehensive bond data including financials and issuer details

## 🧩 Key Components

### Data Models

**BondSummary** - List item representation
```dart
@freezed
class BondSummary with _$BondSummary {
  const factory BondSummary({
  required String logo,
  required String isin,
  required String rating,
  @JsonKey(name: 'company_name') required String companyName,
  required List<String> tags,
  }) = _BondSummary;
}
```

**BondDetail** - Complete bond information
```dart
@freezed
class BondDetail with _$BondDetail {
  const factory BondDetail({
  required String logo,
  @JsonKey(name: 'company_name') required String companyName,
  required String description,
  required String isin,
  required String status,
  @JsonKey(name: 'pros_and_cons') required ProsAndCons prosAndCons,
  required Financials financials,
  @JsonKey(name: 'issuer_details') required IssuerDetails issuerDetails,
  }) = _BondDetail;
}
```

### State Management

**BondListCubit** - Manages home screen state
- Fetches bond list from API
- Handles search functionality with real-time filtering
- Manages loading, loaded, and error states

**BondDetailCubit** - Manages detail screen state
- Fetches detailed bond information
- Handles chart type toggle (EBITDA/Revenue)
- Manages detail loading states

### Repository Pattern

**BondRepository** - Abstracts data source
```dart
abstract class BondRepository {
  Future<List<BondSummary>> getBonds();
  Future<BondDetail> getBondDetail(String isin);
}
```

## 🎨 UI/UX Features

### Design Principles
- **Material Design 3**: Modern, consistent interface
- **Responsive Layout**: Adapts to different screen sizes
- **Accessibility**: Supports screen readers and keyboard navigation
- **Performance**: Optimized with lazy loading and caching

### Animations
- **Page Transitions**: Smooth navigation between screens
- **List Animations**: Staggered animations for bond list items
- **Chart Animations**: Smooth transitions when switching chart types
- **Loading States**: Shimmer effects for better perceived performance

### Haptic Feedback
- **Light Impact**: On bond item selection
- **Selection Click**: On chart toggle buttons
- **Medium Impact**: On pull-to-refresh actions
- **Error Vibration**: On API failures (when appropriate)

## 📊 Features Breakdown

### Home Screen
- **Smart Search Bar**: Real-time filtering by company name, ISIN, or tags
- **Suggested Results**: Shows popular bonds before user input
- **Search Results**: Displays filtered bonds with highlighting
- **Bond Cards**: Clean cards showing logo, rating, company name, and ISIN
- **Pull-to-Refresh**: Updates bond list from API
- **Error Handling**: Graceful error states with retry options

### Bond Detail Screen
- **Company Header**: Logo, name, description, and status
- **Tab Navigation**: Switches between "ISIN Analysis" and "Pros & Cons"
- **Financial Charts**: Interactive EBITDA and Revenue bar charts
- **Issuer Details**: Comprehensive company information
- **Pros & Cons Analysis**: Curated investment insights
- **Back Navigation**: Smooth return to search results

## 🔧 Development

### Code Generation
The project uses several code generation tools:

```bash
# Generate all (Freezed, Injectable, JSON)
flutter packages pub run build_runner build

# Watch mode for development
flutter packages pub run build_runner watch

# Clean and regenerate
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Project Structure
```
tap_invest/
├── android/           # Android-specific files
├── ios/              # iOS-specific files
├── web/              # Web-specific files
├── windows/          # Windows-specific files
├── linux/            # Linux-specific files
├── macos/            # macOS-specific files
├── assets/           # App assets (SVG icons, animations)
├── lib/              # Main application code
│   ├── core/         # Core utilities and DI
│   ├── data/         # Data layer (models, repositories)
│   ├── presentation/ # Presentation layer (UI, state management)
│   └── main.dart     # App entry point
├── pubspec.yaml      # Dependencies and app configuration
└── analysis_options.yaml # Linting rules
```

### Dependencies

**Core Dependencies:**
- `flutter_bloc: ^8.1.6` - State management
- `get_it: ^7.7.0` - Service locator
- `injectable: ^2.3.2` - Dependency injection
- `dio: ^5.3.2` - HTTP client
- `freezed_annotation: ^2.4.4` - Immutable data classes

**UI Dependencies:**
- `fl_chart: ^0.64.0` - Charts and graphs
- `cached_network_image: ^3.4.1` - Image caching
- `flutter_svg: ^2.2.0` - SVG support
- `shimmer: ^3.0.0` - Loading animations
- `flutter_staggered_animations: ^1.1.1` - List animations
- `haptic_feedback: ^0.4.2` - Tactile feedback

**Development Dependencies:**
- `build_runner: ^2.4.7` - Code generation runner
- `freezed: ^2.5.8` - Data class generator
- `json_serializable: ^6.7.1` - JSON serialization
- `injectable_generator: ^2.4.1` - DI code generation


### 📊 Test Coverage
- **Data Models**: 100% coverage with JSON serialization, equality, and edge cases
- **Repository Layer**: Complete API interaction testing with mocked HTTP client
- **Presentation Layer**: Full cubit testing with state management and business logic

### 🏗️ Test Architecture
```
test/
├── data/
│   ├── models/
│   │   ├── bond_detail_model_test.dart
│   │   └── bond_summary_model_test.dart
│   └── repository/
│       ├── bond_repository_test.dart
│       └── bond_repository_test.mocks.dart
└── presentation/
    └── cubit/
        ├── bond_detail_cubit_test.dart
        ├── bond_detail_cubit_test.mocks.dart
        ├── bond_list_cubit_test.dart
        └── bond_list_cubit_test.mocks.dart
```

### 🔧 Testing Tools
- **flutter_test**: Core Flutter testing framework
- **bloc_test**: BLoC/Cubit state management testing
- **mockito**: Mock generation for dependencies

### 🚀 Running Tests
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Generate mocks first
flutter packages pub run build_runner build

# Run specific test files
flutter test test/data/models/
flutter test test/presentation/cubit/
```

### 📋 What's Tested
- ✅ JSON serialization/deserialization
- ✅ API error handling (network, 404, timeouts)
- ✅ Search functionality (name, ISIN, tags)
- ✅ State transitions and error states
- ✅ Chart type toggling
- ✅ Edge cases and null handling
