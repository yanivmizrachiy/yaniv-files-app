class AppConstants {
  static const String appTitle = 'הקבצים של יניב';
  static const String downloadRoot = '/storage/emulated/0/Download';
  static const int maxSelection = 5;

  // WhatsApp "self" target (Israel country code 972 + number without leading 0)
  static const String waCountryCode = '972';
  static const String waSelfNumberNoLeadingZero = '523748115'; // 0523748115 -> 972523748115
  static String get waSelfFullPhone => '$waCountryCode$waSelfNumberNoLeadingZero';
}
