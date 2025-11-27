import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/notification_service.dart';

enum TimerMode { work, shortBreak, longBreak }

class TimerProvider with ChangeNotifier {
  static const int defaultWorkTime = 25;

  int _remainingSeconds = defaultWorkTime * 60;
  int _selectedTimeInMinutes = defaultWorkTime;
  TimerMode _currentMode = TimerMode.work;
  String _currentMotivation = "start_message";

  Timer? _timer;
  bool _isRunning = false;
  bool _isAlarmPlaying = false;

  // --- YENİ: Kaç tane pomodoro bitirdik? ---
  int _completedRounds = 0;

  final AudioPlayer _audioPlayer = AudioPlayer();

  // Getterlar
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  String get currentMotivation => _currentMotivation;
  int get currentDuration => _selectedTimeInMinutes;
  TimerMode get currentMode => _currentMode;
  bool get isAlarmPlaying => _isAlarmPlaying;
  int get completedRounds => _completedRounds; // Bunu ekranda göstermek istersen diye

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

  // --- SÖZ LİSTESİ (50 Tane) ---
  final List<String> _quotes = List.generate(50, (index) => "quote_${index + 1}");

  void _changeQuote() {
    _currentMotivation = _quotes[Random().nextInt(_quotes.length)];
  }

  void startTimer(String soundPath) {
    if (_timer != null) return;

    // Eğer alarm çalıyorsa ve kullanıcı başlata bastıysa alarmı susturur ama modu değiştirmez (manual start)
    if (_isAlarmPlaying) {
      _audioPlayer.stop();
      _isAlarmPlaying = false;
      resetTimer(); // Sadece resetler
      notifyListeners();
      return;
    }

    _isRunning = true;
    _changeQuote();
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        // --- SÜRE BİTTİ ---
        stopTimer(reset: false);
        _isRunning = false;
        _isAlarmPlaying = true;
        _currentMotivation = "congrats";

        // Eğer biten mod ODAKLANMA ise tur sayısını artır
        if (_currentMode == TimerMode.work) {
          _completedRounds++;
        }

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

  // --- GÜNCELLENEN STOP ALARM ---
  // Artık sadece sesi kesmiyor, bir sonraki tura hazırlıyor.
  void stopAlarm({
    required int workTime,
    required int shortBreakTime,
    required int longBreakTime
  }) {
    _audioPlayer.stop();
    _isAlarmPlaying = false;

    // --- OTOMATİK MOD GEÇİŞ MANTIĞI ---
    if (_currentMode == TimerMode.work) {
      // Eğer Odaklanma bittiyse -> Molaya geçeceğiz
      // 4. Odaklanma bittiyse (Mod 4 == 0) -> Uzun Mola
      if (_completedRounds % 4 == 0 && _completedRounds != 0) {
        setTime(longBreakTime, TimerMode.longBreak);
      } else {
        // Yoksa -> Kısa Mola
        setTime(shortBreakTime, TimerMode.shortBreak);
      }
    } else {
      // Eğer Mola (Kısa veya Uzun) bittiyse -> İşe Geri Dön
      setTime(workTime, TimerMode.work);
    }

    notifyListeners();
  }

  // Manuel durdurma
  void stopTimer({bool reset = true}) {
    _timer?.cancel();
    _timer = null;
    _audioPlayer.stop();
    _isRunning = false;
    _isAlarmPlaying = false;
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

  void updateDurationFromSettings(int newMinutes, TimerMode mode) {
    if (_isRunning) return;
    if (_currentMode == mode) {
      _selectedTimeInMinutes = newMinutes;
      _remainingSeconds = newMinutes * 60;
      notifyListeners();
    }
  }
}