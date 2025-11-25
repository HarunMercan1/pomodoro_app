import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  // Varsayılan Ayarlar
  bool _isDarkMode = true;
  String _selectedSound = 'digital.mp3';

  // --- YENİ: SÜRE AYARLARI (Varsayılanlar) ---
  int _workTime = 25;
  int _shortBreakTime = 5;
  int _longBreakTime = 15;

  final AudioPlayer _audioPlayer = AudioPlayer();
  late SharedPreferences _prefs;

  // Getterlar
  bool get isDarkMode => _isDarkMode;
  String get selectedSound => _selectedSound;

  // --- YENİ GETTERLAR ---
  int get workTime => _workTime;
  int get shortBreakTime => _shortBreakTime;
  int get longBreakTime => _longBreakTime;

  final Map<String, String> soundOptions = {
    'bell.mp3': 'Klasik Zil',
    'digital.mp3': 'Dijital',
    'alarm.mp3': 'Alarm',
  };

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();

    _isDarkMode = _prefs.getBool('isDarkMode') ?? true;
    _selectedSound = _prefs.getString('selectedSound') ?? 'digital.mp3';

    // --- YENİ: SÜRELERİ HAFIZADAN OKU ---
    _workTime = _prefs.getInt('workTime') ?? 25;
    _shortBreakTime = _prefs.getInt('shortBreakTime') ?? 5;
    _longBreakTime = _prefs.getInt('longBreakTime') ?? 15;

    notifyListeners();
  }

  void toggleTheme(bool value) {
    _isDarkMode = value;
    _prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  Future<void> setSound(String soundPath) async {
    _selectedSound = soundPath;
    _prefs.setString('selectedSound', soundPath);
    notifyListeners();

    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource('sounds/$soundPath'));
  }

  Future<void> stopPreview() async {
    await _audioPlayer.stop();
  }

  // --- YENİ: SÜRE DEĞİŞTİRME FONKSİYONLARI ---

  void setWorkTime(int minutes) {
    _workTime = minutes;
    _prefs.setInt('workTime', minutes);
    notifyListeners();
  }

  void setShortBreakTime(int minutes) {
    _shortBreakTime = minutes;
    _prefs.setInt('shortBreakTime', minutes);
    notifyListeners();
  }

  void setLongBreakTime(int minutes) {
    _longBreakTime = minutes;
    _prefs.setInt('longBreakTime', minutes);
    notifyListeners();
  }
}