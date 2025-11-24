import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <--- YENİ PAKET

class SettingsProvider with ChangeNotifier {
  // Varsayılan Ayarlar
  bool _isDarkMode = true;
  String _selectedSound = 'digital.mp3'; // Varsayılan ses

  final AudioPlayer _audioPlayer = AudioPlayer();
  late SharedPreferences _prefs; // Not defterimiz

  // Getterlar
  bool get isDarkMode => _isDarkMode;
  String get selectedSound => _selectedSound;

  final Map<String, String> soundOptions = {
    'bell.mp3': 'Klasik Zil',
    'digital.mp3': 'Dijital',
    'alarm.mp3': 'Alarm',
  };

  // Constructor: Provider oluşturulduğu an hafızayı yükle
  SettingsProvider() {
    _loadSettings();
  }

  // 1. AYARLARI YÜKLEME (Hatırlama)
  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();

    // Defterden oku, eğer kayıt yoksa varsayılanı (?? false) kullan
    _isDarkMode = _prefs.getBool('isDarkMode') ?? true;
    _selectedSound = _prefs.getString('selectedSound') ?? 'digital.mp3';

    notifyListeners(); // Ekranı güncelle
  }

  // 2. TEMA DEĞİŞTİRME VE KAYDETME
  void toggleTheme(bool value) {
    _isDarkMode = value;
    _prefs.setBool('isDarkMode', value); // Deftere yaz
    notifyListeners();
  }

  // 3. SES DEĞİŞTİRME VE KAYDETME
  Future<void> setSound(String soundPath) async {
    _selectedSound = soundPath;
    _prefs.setString('selectedSound', soundPath); // Deftere yaz
    notifyListeners();

    // Sesi önizle (Çal)
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource('sounds/$soundPath'));
  }
}