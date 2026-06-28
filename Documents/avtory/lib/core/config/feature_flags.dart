class FeatureFlags {
  FeatureFlags._();

  // ─── Future Modules ───
  static bool get insurance => _enabled['insurance'] ?? false;
  static bool get carMarketplace => _enabled['car_marketplace'] ?? false;
  static bool get serviceBooking => _enabled['service_booking'] ?? false;
  static bool get fuelStations => _enabled['fuel_stations'] ?? false;
  static bool get evCharging => _enabled['ev_charging'] ?? false;
  static bool get subscriptionPlans => _enabled['subscription_plans'] ?? false;
  static bool get premiumMembership => _enabled['premium_membership'] ?? false;
  static bool get fleetManagement => _enabled['fleet_management'] ?? false;
  static bool get businessDashboard => _enabled['business_dashboard'] ?? false;
  static bool get analytics => _enabled['analytics'] ?? false;
  static bool get superAdmin => _enabled['super_admin'] ?? false;
  static bool get aiAssistant => _enabled['ai_assistant'] ?? false;
  static bool get smartSearch => _enabled['smart_search'] ?? false;
  static bool get voiceCommands => _enabled['voice_commands'] ?? false;
  static bool get multiCompany => _enabled['multi_company'] ?? false;
  static bool get offlineMode => _enabled['offline_mode'] ?? false;
  static bool get darkMode => true;
  static bool get dynamicTheme => true;

  static final Map<String, bool> _enabled = {};

  static void set(String key, bool value) => _enabled[key] = value;
  static void setAll(Map<String, bool> flags) => _enabled.addAll(flags);

  static bool isEnabled(String key) => _enabled[key] ?? false;
}
