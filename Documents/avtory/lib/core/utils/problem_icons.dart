import 'package:flutter/material.dart';

/// Maps the backend's logical `icon` keys (ProblemCategory.icon) to concrete
/// Material icons, and `group` keys to brand-coherent colours. Shared by the
/// home grid, the "Boshqa muammolar" sheet, and the mechanic service picker.

const String _fallbackIcon = 'build_rounded';

const Map<String, String> _icons = {
  'engine': 'build_circle_rounded',
  'fuel': 'local_gas_station_rounded',
  'belt': 'sync_rounded',
  'thermostat': 'device_thermostat_rounded',
  'oil': 'oil_barrel_rounded',
  'electrical': 'electrical_services_rounded',
  'starter': 'power_settings_new_rounded',
  'generator': 'bolt_rounded',
  'battery': 'battery_charging_full_rounded',
  'sensor': 'sensors_rounded',
  'wiring': 'cable_rounded',
  'suspension': 'compress_rounded',
  'joint': 'adjust_rounded',
  'steering': 'toll_rounded',
  'arm': 'linear_scale_rounded',
  'stabilizer': 'straighten_rounded',
  'bearing': 'donut_large_rounded',
  'brake': 'disc_full_rounded',
  'fluid': 'water_drop_rounded',
  'tire': 'tire_repair_rounded',
  'balance': 'balance_rounded',
  'wheel': 'album_rounded',
  'radiator': 'heat_pump_rounded',
  'coolant': 'ac_unit_rounded',
  'ac': 'ac_unit_rounded',
  'body': 'directions_car_filled_rounded',
  'paint': 'format_paint_rounded',
  'polish': 'auto_awesome_rounded',
  'scratch': 'healing_rounded',
  'alarm': 'notifications_active_rounded',
  'multimedia': 'music_note_rounded',
  'camera': 'videocam_rounded',
  'parking': 'local_parking_rounded',
  'headlight': 'highlight_rounded',
  'evacuation': 'local_shipping_rounded',
  'wash': 'local_car_wash_rounded',
  'clean': 'cleaning_services_rounded',
  'window': 'window_rounded',
  'key': 'vpn_key_rounded',
  'gas': 'propane_tank_rounded',
  'tuning': 'tune_rounded',
  'sound': 'graphic_eq_rounded',
  'sticker': 'style_rounded',
  'other': 'more_horiz_rounded',
};

const Map<String, Color> _groupColors = {
  'dvigatel': Color(0xFF3B82F6),
  'elektr': Color(0xFFF59E0B),
  'yurish': Color(0xFF14B8A6),
  'tormoz': Color(0xFFEF4444),
  'shina': Color(0xFF10B981),
  'sovitish': Color(0xFF06B6D4),
  'konditsioner': Color(0xFF0EA5E9),
  'kuzov': Color(0xFF8B5CF6),
  'elektronika': Color(0xFF6366F1),
  'qoshimcha': Color(0xFF6B7280),
};

String problemIcon(String iconKey) => _icons[iconKey] ?? _fallbackIcon;

Color problemColor(String groupKey) => _groupColors[groupKey] ?? const Color(0xFF6B7280);
