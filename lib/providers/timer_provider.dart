import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/notification_service.dart'; // Bildirim servisi

// Zamanlayıcı Modları
enum TimerMode { work, shortBreak, longBreak }

class TimerProvider with ChangeNotifier {
  // Varsayılan değerler
  static const int defaultWorkTime = 25;

  int _remainingSeconds = defaultWorkTime * 60;
  int _selectedTimeInMinutes = defaultWorkTime;
  TimerMode _currentMode = TimerMode.work;
  String _currentMotivation = "start_message";

  Timer? _timer;
  bool _isRunning = false;

  // --- YENİ: Alarm çalıyor mu kontrolü ---
  bool _isAlarmPlaying = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  // Getterlar
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  String get currentMotivation => _currentMotivation;
  int get currentDuration => _selectedTimeInMinutes;
  TimerMode get currentMode => _currentMode;
  bool get isAlarmPlaying => _isAlarmPlaying;

  double get progress {
    if (_selectedTimeInMinutes == 0) return 0;
    int totalSeconds = _selectedTimeInMinutes * 60;
    return 1 - (_remainingSeconds / totalSeconds);
  }

  String get timeLeftString {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  final List<String> _quotes = [
    "quote_1", "quote_2", "quote_3", "quote_4",
    "quote_5", "quote_6", "quote_7", "quote_8",
  ];

  void _changeQuote() {
    _currentMotivation = _quotes[Random().nextInt(_quotes.length)];
  }

  // --- FONKSİYONLAR ---

  void startTimer(String soundPath) {
    if (_timer != null) return;

    if (_isAlarmPlaying) {
      stopAlarm();
      return;
    }

    // --- DÜZELTME BURADA ---
    // Sayacın içine girmeden ÖNCE durumu güncelle ki buton anında değişsin.
    _isRunning = true;
    _changeQuote();
    notifyListeners();
    // -----------------------

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        // _isRunning = true; // Buradan sildik, zaten yukarıda true yaptık.
        notifyListeners();
      } else {
        // --- SÜRE BİTTİ ---
        stopTimer(reset: false);
        _isRunning = false;
        _isAlarmPlaying = true;
        _currentMotivation = "congrats";

        NotificationService().showNotification(
          title: 'congrats'.tr(),
          body: 'ready'.tr(),
        );

        try {
          await _audioPlayer.play(AssetSource('sounds/$soundPath'));
        } catch (e) {
          debugPrint("Ses hatası: $e");
        }
        notifyListeners();
      }
    });
  }

  // YENİ: Alarmı Susturma Fonksiyonu
  void stopAlarm() {
    _audioPlayer.stop();
    _isAlarmPlaying = false;
    resetTimer(); // Alarm susunca sayacı başa sar
    notifyListeners();
  }

  void stopTimer({bool reset = true}) {
    _timer?.cancel();
    _timer = null;
    _audioPlayer.stop();
    _isRunning = false;
    _isAlarmPlaying = false; // Garanti olsun
    notifyListeners();
  }

  void resetTimer() {
    stopTimer();
    _remainingSeconds = _selectedTimeInMinutes * 60;
    _currentMotivation = "ready";
    _isAlarmPlaying = false;
    notifyListeners();
  }

  void setTime(int minutes, TimerMode mode) {
    stopTimer();
    _selectedTimeInMinutes = minutes;
    _remainingSeconds = minutes * 60;
    _currentMode = mode;
    _currentMotivation = "new_goal";
    _isAlarmPlaying = false;
    notifyListeners();
  }

  // Ayarlardan gelen güncelleme
  void updateDurationFromSettings(int newMinutes, TimerMode mode) {
    if (_isRunning) return;

    if (_currentMode == mode) {
      _selectedTimeInMinutes = newMinutes;
      _remainingSeconds = newMinutes * 60;
      notifyListeners();
    }
  }
}