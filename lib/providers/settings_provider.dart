import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // <--- 1. YENİ KÜTÜPHANE

class SettingsProvider with ChangeNotifier {
  // Varsayılan Ayarlar
  bool _isDarkMode = false;
  String _selectedSound = 'digital.mp3';

  // <--- 2. YENİ: Ses çalma aleti (DJ Seti)
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Getterlar
  bool get isDarkMode => _isDarkMode;
  String get selectedSound => _selectedSound;

  // Ses Listesi
  final Map<String, String> soundOptions = {
    'bell.mp3': 'Klasik Zil',
    'digital.mp3': 'Dijital',
    'alarm.mp3': 'Alarm',
  };

  void toggleTheme(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  // <--- 3. GÜNCELLENEN KISIM: Hem ayarla hem çal
  Future<void> setSound(String soundPath) async {
    _selectedSound = soundPath;
    notifyListeners(); // Arayüzü güncelle (Dropdown değişsin)

    // Önceki ses çalıyorsa sustur, karışıklık olmasın
    await _audioPlayer.stop();

    // Yeni seçilen sesi çal (Önizleme)
    // Not: 'sounds/' klasöründe olduğunu belirtiyoruz
    await _audioPlayer.play(AssetSource('sounds/$soundPath'));
  }
}