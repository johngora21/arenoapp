class AppConstants {
  // App Info
  static const String appName = 'Areno Express';
  static const String appVersion = '1.0.0';
  
  // User Types
  static const String userTypeCustomer = 'customer';
  static const String userTypeDriver = 'driver';
  static const String userTypeAgent = 'agent';
  static const String userTypeSupervisor = 'supervisor';
  
  // Service Types
  static const String serviceTypeFreight = 'freight';
  static const String serviceTypeMoving = 'moving';
  static const String serviceTypeCourier = 'courier';
  
  // Quote Status
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  
  // Shipment Status
  static const String shipmentStatusPending = 'pending';
  static const String shipmentStatusAssigned = 'assigned';
  static const String shipmentStatusInTransit = 'in_transit';
  static const String shipmentStatusDelivered = 'delivered';
  static const String shipmentStatusCancelled = 'cancelled';
  
  // Driver Status
  static const String driverStatusAvailable = 'available';
  static const String driverStatusBusy = 'busy';
  static const String driverStatusOffline = 'offline';
  
  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx'];
  
  // API Endpoints (if needed)
  static const String baseUrl = 'https://api.arenologistics.com';
  
  // Storage Keys
  static const String userPrefsKey = 'user_preferences';
  static const String authTokenKey = 'auth_token';
  static const String userTypeKey = 'user_type';
  static const String userIdKey = 'user_id';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultRadius = 12.0;
  static const double largeRadius = 16.0;
  static const double extraLargeRadius = 24.0;
  
  // Map Constants
  static const double defaultZoom = 15.0;
  static const double minZoom = 10.0;
  static const double maxZoom = 20.0;
  
  // Notification Types
  static const String notificationTypeQuote = 'quote';
  static const String notificationTypeShipment = 'shipment';
  static const String notificationTypeDriver = 'driver';
  static const String notificationTypeGeneral = 'general';
}
