import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/notification_service.dart';
import 'settings_provider.dart';

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
  int _completedRounds = 0;

  // Çift Player: Biri müzik, biri alarm için
  final AudioPlayer _alarmPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  // Getterlar
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  String get currentMotivation => _currentMotivation;
  int get currentDuration => _selectedTimeInMinutes;
  TimerMode get currentMode => _currentMode;
  bool get isAlarmPlaying => _isAlarmPlaying;
  int get completedRounds => _completedRounds;

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

  final List<String> _quotes = List.generate(50, (index) => "quote_${index + 1}");

  void _changeQuote() {
    _currentMotivation = _quotes[Random().nextInt(_quotes.length)];
  }

  // --- BAŞLATMA ---
  void startTimer(SettingsProvider settings) async {
    if (_timer != null) return;

    // Alarm çalıyorsa sadece sustur, başlatma
    if (_isAlarmPlaying) {
      _alarmPlayer.stop();
      _isAlarmPlaying = false;
      resetTimer();
      notifyListeners();
      return;
    }

    _isRunning = true;
    _changeQuote();
    notifyListeners();

    // MÜZİK BAŞLAT (Eğer açıksa)
    if (settings.isBackgroundMusicEnabled) {
      try {
        await _musicPlayer.setSource(AssetSource('sounds/music/${settings.backgroundMusic}'));
        await _musicPlayer.setVolume(settings.backgroundVolume);
        await _musicPlayer.setReleaseMode(ReleaseMode.loop); // Sonsuz döngü
        await _musicPlayer.resume();
      } catch (e) {
        debugPrint("Müzik hatası: $e");
      }
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        // --- SÜRE BİTTİ ---
        await _musicPlayer.stop(); // Müziği sustur

        stopTimer(reset: false);
        _isRunning = false;
        _isAlarmPlaying = true;
        _currentMotivation = "congrats";

        if (_currentMode == TimerMode.work) {
          _completedRounds++;
        }

        NotificationService().showNotification(
          title: 'congrats'.tr(),
          body: 'ready'.tr(),
        );

        try {
          // ALARMI ÇAL (bell klasöründen)
          await _alarmPlayer.play(AssetSource('sounds/bell/${settings.notificationSound}'));
        } catch (e) {
          debugPrint("Alarm hatası: $e");
        }
        notifyListeners();
      }
    });
  }

  // --- ALARMI DURDUR & SONRAKİ TURA GEÇ ---
  void stopAlarm({
    required int workTime,
    required int shortBreakTime,
    required int longBreakTime
  }) {
    _alarmPlayer.stop();
    _musicPlayer.stop();
    _isAlarmPlaying = false;

    // Otomatik Geçiş Mantığı
    if (_currentMode == TimerMode.work) {
      if (_completedRounds % 4 == 0 && _completedRounds != 0) {
        setTime(longBreakTime, TimerMode.longBreak);
      } else {
        setTime(shortBreakTime, TimerMode.shortBreak);
      }
    } else {
      setTime(workTime, TimerMode.work);
    }
    notifyListeners();
  }

  void stopTimer({bool reset = true}) {
    _timer?.cancel();
    _timer = null;
    _alarmPlayer.stop();
    _musicPlayer.stop();
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

  // Anlık Ses Ayarı (Slider oynarken)
  void updateMusicVolume(double volume) {
    if (_isRunning) {
      _musicPlayer.setVolume(volume);
    }
  }
}