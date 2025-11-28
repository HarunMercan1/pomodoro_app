import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  late SharedPreferences _prefs;
  final AudioPlayer _previewPlayer = AudioPlayer();

  // --- AYARLAR ---
  bool _isDarkMode = true;
  String _notificationSound = 'digital.mp3';
  bool _isBackgroundMusicEnabled = false;
  String _backgroundMusic = 'rain.mp3';
  double _backgroundVolume = 0.5;

  // Süreler
  int _workTime = 25;
  int _shortBreakTime = 5;
  int _longBreakTime = 15;

  // Getterlar
  bool get isDarkMode => _isDarkMode;
  String get notificationSound => _notificationSound;
  bool get isBackgroundMusicEnabled => _isBackgroundMusicEnabled;
  String get backgroundMusic => _backgroundMusic;
  double get backgroundVolume => _backgroundVolume;

  int get workTime => _workTime;
  int get shortBreakTime => _shortBreakTime;
  int get longBreakTime => _longBreakTime;

  final Map<String, String> notificationSounds = {
    'digital.mp3': 'Zil 1',
    'alarm.mp3': 'Zil 2',
    'bell.mp3': 'Zil 3',
    'bell2.mp3': 'Zil 4',
    'bell3.mp3': 'Zil 5',
    'bell4.mp3': 'Zil 6',
    'bell5.mp3': 'Zil 7',
    'bell6.mp3': 'Zil 8',
    'bell7.mp3': 'Zil 9',
    'bell8.mp3': 'Zil 10',
    'bell9.mp3': 'Zil 11',
  };

  final Map<String, String> backgroundMusics = {
    'rain.mp3': 'Yağmur',
    'rain2.mp3': 'Sağanak',
    'rain3.mp3': 'Hafif Çise',
    'rain4.mp3': 'Camda Yağmur',
    'rainandthunder.mp3': 'Fırtına',
    'forest.mp3': 'Orman',
    'forest2.mp3': 'Kuş Sesleri',
    'forest3.mp3': 'Derin Doğa',
    'ocean.mp3': 'Okyanus',
    'ocean2.mp3': 'Sahil',
    'wind.mp3': 'Rüzgar',
  };

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs.getBool('isDarkMode') ?? true;
    _notificationSound = _prefs.getString('notificationSound') ?? 'digital.mp3';
    _isBackgroundMusicEnabled = _prefs.getBool('isBackgroundMusicEnabled') ?? false;
    _backgroundMusic = _prefs.getString('backgroundMusic') ?? 'rain.mp3';
    _backgroundVolume = _prefs.getDouble('backgroundVolume') ?? 0.5;
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

  Future<void> setNotificationSound(String soundPath) async {
    _notificationSound = soundPath;
    _prefs.setString('notificationSound', soundPath);
    notifyListeners();
    await _previewPlayer.stop();
    await _previewPlayer.setSource(AssetSource('sounds/bell/$soundPath'));
    await _previewPlayer.setVolume(1.0);
    await _previewPlayer.setReleaseMode(ReleaseMode.stop);
    await _previewPlayer.resume();
  }

  Future<void> setBackgroundMusic(String soundPath) async {
    _backgroundMusic = soundPath;
    _prefs.setString('backgroundMusic', soundPath);
    notifyListeners();
    if (_isBackgroundMusicEnabled) {
      await _previewPlayer.stop();
      await _previewPlayer.setSource(AssetSource('sounds/music/$soundPath'));
      await _previewPlayer.setVolume(_backgroundVolume);
      await _previewPlayer.setReleaseMode(ReleaseMode.loop);
      await _previewPlayer.resume();
    }
  }

  // --- SES AYARLARI (GÜNCELLENDİ) ---

  // 1. Canlı Değişim (Slider oynarken çağrılır - EKRANI YENİLEMEZ)
  void setVolumeLive(double volume) {
    _backgroundVolume = volume;
    // notifyListeners() ÇAĞIRMIYORUZ! (Kasma sebebi buydu)

    // Player sesini anlık güncelle
    if (_previewPlayer.state == PlayerState.playing) {
      _previewPlayer.setVolume(volume);
    }
  }

  // 2. Kayıt (Parmak çekilince çağrılır)
  void saveVolumeToPrefs() {
    _prefs.setDouble('backgroundVolume', _backgroundVolume);
    // Burada notifyListeners çağırabiliriz ki diğer ekranlar haberdar olsun
    notifyListeners();
  }

  // ------------------------------------

  void toggleBackgroundMusic(bool value) async {
    _isBackgroundMusicEnabled = value;
    _prefs.setBool('isBackgroundMusicEnabled', value);
    notifyListeners();
    if (!value) {
      await _previewPlayer.stop();
    } else {
      setBackgroundMusic(_backgroundMusic);
    }
  }

  Future<void> stopPreview() async {
    await _previewPlayer.stop();
  }

  void setWorkTime(int minutes) { _workTime = minutes; _prefs.setInt('workTime', minutes); notifyListeners(); }
  void setShortBreakTime(int minutes) { _shortBreakTime = minutes; _prefs.setInt('shortBreakTime', minutes); notifyListeners(); }
  void setLongBreakTime(int minutes) { _longBreakTime = minutes; _prefs.setInt('longBreakTime', minutes); notifyListeners(); }
}