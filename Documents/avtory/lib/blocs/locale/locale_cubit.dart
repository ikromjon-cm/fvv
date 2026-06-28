import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('uz')) {
    _load();
  }

  static const _key = 'app_locale';

  static const languages = [
    ('uz', "O'zbek", '🇺🇿'),
    ('ru', 'Русский', '🇷🇺'),
    ('en', 'English', '🇬🇧'),
  ];

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'uz';
    emit(Locale(code));
  }

  Future<void> setLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, languageCode);
    emit(Locale(languageCode));
  }
}
