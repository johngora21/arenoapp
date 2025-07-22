# Areno Express - Logistics Management Mobile App

A comprehensive Flutter mobile application for Areno Logistics, designed to serve 4 different user types with role-based interfaces.

## 🚚 User Types

### 1. 📱 Customers
- **Role:** Primary service consumers
- **Features:** Quote requests, real-time tracking, payment integration, chat support
- **Interface:** User-friendly mobile experience for service requests

### 2. 🏍️ Motorbike Drivers
- **Role:** Company drivers for local pickup and delivery
- **Features:** Assigned shipments, GPS navigation, status updates, earnings tracking
- **Interface:** Job-focused mobile app for delivery operations

### 3. 🏪 Agents
- **Role:** Pickup and dropoff points only
- **Features:** Package management, dropoff registration, pickup coordination
- **Interface:** Simple interface for package handling

### 4. 👨‍💼 Supervisors
- **Role:** Freight and Moving supervisors managing assigned shipments
- **Features:** Shipment management, driver assignment, progress tracking
- **Interface:** Management dashboard for operations oversight

## 🎨 Design System

Based on the existing Areno Logistics web system:

### Colors
- **Primary Orange:** `#F97316` - Brand color for CTAs and highlights
- **Primary Blue:** `#3B82F6` - Links and secondary actions
- **Slate Gradients:** Background gradients for depth
- **Success Green:** `#22C55E` - Success states
- **Warning Yellow:** `#EAB308` - Warning states
- **Error Red:** `#EF4444` - Error states

### Typography
- **Font:** Poppins (Google Fonts)
- **Weights:** 300, 400, 500, 600, 700, 800
- **Responsive:** Mobile-first design approach

### UI Components
- **Cards:** Rounded corners with shadows
- **Buttons:** Orange primary, blue secondary
- **Forms:** Consistent styling with focus states
- **Animations:** Smooth transitions and micro-interactions

## 🏗️ Architecture

### Project Structure
```
lib/
├── core/
│   ├── theme/          # Design system
│   ├── constants/      # App constants
│   ├── utils/          # Utility functions
│   └── services/       # Core services
├── features/
│   ├── auth/           # Authentication
│   ├── customer/       # Customer interface
│   ├── driver/         # Driver interface
│   ├── agent/          # Agent interface
│   └── supervisor/     # Supervisor interface
└── shared/
    ├── widgets/        # Shared components
    ├── models/         # Data models
    └── providers/      # State management
```

### Technology Stack
- **Framework:** Flutter 3.7.2
- **State Management:** Riverpod
- **Backend:** Firebase (Auth, Firestore, Storage, Messaging)
- **Maps:** Google Maps Flutter
- **UI:** Material Design 3 with custom theme
- **Navigation:** Go Router

## 🔧 Setup & Installation

1. **Prerequisites**
   - Flutter SDK 3.7.2+
   - Dart SDK
   - Firebase project setup

2. **Installation**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Add `google-services.json` (Android)
   - Add `GoogleService-Info.plist` (iOS)
   - Configure Firebase project

4. **Run the App**
   ```bash
   flutter run
   ```

## 📱 Features

### Authentication
- Multi-role login system
- User type selection during signup
- Firebase Authentication integration

### Customer Features
- Quote request forms (Freight, Moving, Courier)
- Real-time shipment tracking
- Payment integration
- Chat support
- Service history

### Driver Features
- Assigned shipment management
- GPS navigation
- Status updates
- Earnings tracking
- Route optimization

### Agent Features
- Package management
- Dropoff registration
- Pickup coordination
- Inventory tracking

### Supervisor Features
- Assigned shipment management
- Driver assignment
- Progress tracking
- Issue resolution
- Reports generation

## 🔄 Integration

The Flutter app integrates with the existing Areno Logistics web system:

- **Shared Backend:** Firebase Firestore database
- **Real-time Sync:** Live data updates across platforms
- **Unified Auth:** Same authentication system
- **Consistent UI:** Matching design language

## 🚀 Next Steps

1. **Firebase Configuration**
   - Set up Firebase project
   - Configure authentication rules
   - Set up Firestore collections

2. **Feature Implementation**
   - Complete quote forms
   - Implement GPS tracking
   - Add payment processing
   - Set up push notifications

3. **Testing & Deployment**
   - Unit and widget tests
   - Integration testing
   - App store deployment

## 📄 License

This project is proprietary to Areno Logistics.

---

**Built with ❤️ for Areno Logistics**
