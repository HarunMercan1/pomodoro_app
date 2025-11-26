import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../utils/notification_service.dart';
import 'package:easy_localization/easy_localization.dart'; // Çeviri için

// Zamanlayıcı Modları (Hangi durumdayız?)
enum TimerMode { work, shortBreak, longBreak }

class TimerProvider with ChangeNotifier {
  // Varsayılan değerler (Başlangıç için)
  static const int defaultWorkTime = 25;

  int _remainingSeconds = defaultWorkTime * 60;
  int _selectedTimeInMinutes = defaultWorkTime;
  TimerMode _currentMode = TimerMode.work; // Varsayılan mod Odaklanma

  String _currentMotivation = "start_message";

  Timer? _timer;
  bool _isRunning = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Getterlar
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  String get currentMotivation => _currentMotivation;
  int get currentDuration => _selectedTimeInMinutes;
  TimerMode get currentMode => _currentMode; // Dışarıdan modu okumak için

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

    _changeQuote();
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        _isRunning = true;
        notifyListeners();
      } else {
        stopTimer(reset: false);
        _isRunning = false;
        _currentMotivation = "congrats";

        // --- BİLDİRİM GÖNDER ---
        NotificationService().showNotification(
          title: 'congrats'.tr(), // "Tebrikler!"
          body: 'ready'.tr(),     // "Hazır mısın?" (veya başka bir mesaj)
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

  void stopTimer({bool reset = true}) {
    _timer?.cancel();
    _timer = null;
    _audioPlayer.stop();
    _isRunning = false;
    notifyListeners();
  }

  void resetTimer() {
    stopTimer();
    _remainingSeconds = _selectedTimeInMinutes * 60;
    _currentMotivation = "ready";
    notifyListeners();
  }

  // SÜRE VE MOD DEĞİŞTİRME (Ana Ekrandan Çağrılır)
  void setTime(int minutes, TimerMode mode) {
    stopTimer();
    _selectedTimeInMinutes = minutes;
    _remainingSeconds = minutes * 60;
    _currentMode = mode; // Modu güncelle
    _currentMotivation = "new_goal";
    notifyListeners();
  }

  // AYARLARDAN GELEN GÜNCELLEME (Anlık Değişim İçin)
  // Eğer sayaç çalışmıyorsa ve değiştirilen ayar şu anki mod ise, süreyi güncelle.
  void updateDurationFromSettings(int newMinutes, TimerMode mode) {
    if (_isRunning) return; // Çalışıyorsa elleme, adamın konsantrasyonu bozulmasın

    if (_currentMode == mode) {
      _selectedTimeInMinutes = newMinutes;
      _remainingSeconds = newMinutes * 60;
      notifyListeners();
    }
  }
}