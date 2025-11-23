import 'dart:async';
import 'dart:math'; // <--- Random için gerekli
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class TimerProvider with ChangeNotifier {
  static const int defaultWorkTime = 25;
  static const int defaultShortBreak = 5;
  static const int defaultLongBreak = 15;

  int _remainingSeconds = defaultWorkTime * 60;
  int _selectedTimeInMinutes = defaultWorkTime;

  // YENİ: Başlangıç mesajımız
  String _currentMotivation = "Hadi Başlayalım! 🚀";

  Timer? _timer;
  bool _isRunning = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  String get currentMotivation => _currentMotivation; // <--- Dışarıya açtık

  // Hangi sürenin seçili olduğunu dışarıya söyleyen değişken
  int get currentDuration => _selectedTimeInMinutes;

  // İlerleme çubuğu
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

  // --- SÖZ BANKASI ---
  final List<String> _quotes = [
    "Başlamak bitirmenin yarısıdır!",
    "Bugün harika işler çıkaracaksın.",
    "Odaklan ve başar.",
    "Hayallerin için çalış.",
    "Asla pes etme!",
    "Gelecekteki sen sana teşekkür edecek.",
    "Biraz daha gayret!",
    "Sadece yap!",
  ];

  void _changeQuote() {
    // Listeden rastgele bir söz seç
    _currentMotivation = _quotes[Random().nextInt(_quotes.length)];
  }

  void startTimer(String soundPath) {
    if (_timer != null) return;

    _changeQuote(); // <--- Başlarken gaz ver!
    notifyListeners();

    _timer = Timer.periodic(const Duration(milliseconds: 1), (timer) async {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        _isRunning = true;
        notifyListeners();
      } else {
        stopTimer(reset: false);
        _isRunning = false;
        _currentMotivation = "Tebrikler! 🎉"; // <--- Bitince kutla

        try {
          await _audioPlayer.play(AssetSource('sounds/$soundPath'));
        } catch (e) {
          print("Hata: $e");
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
    _currentMotivation = "Hazır mısın? 💪"; // <--- Sıfırlanınca sor
    notifyListeners();
  }

  void setTime(int minutes) {
    stopTimer();
    _selectedTimeInMinutes = minutes;
    _remainingSeconds = minutes * 60;
    _currentMotivation = "Yeni Hedef Belirlendi 🎯"; // <--- Süre değişince
    notifyListeners();
  }
}