import 'dart:async';
import 'dart:math'; // Rastgele seçim için
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // Ses çalmak için

class TimerProvider with ChangeNotifier {
  // Varsayılan Süreler
  static const int defaultWorkTime = 25;
  static const int defaultShortBreak = 5;
  static const int defaultLongBreak = 15;

  // Değişkenler
  int _remainingSeconds = defaultWorkTime * 60;
  int _selectedTimeInMinutes = defaultWorkTime;

  // Başlangıç mesajımız artık bir ANAHTAR (JSON'dan okunacak)
  String _currentMotivation = "start_message";

  Timer? _timer;
  bool _isRunning = false;

  // Ses Oynatıcı
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Getterlar (Dışarıdan okuma yapmak için)
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  String get currentMotivation => _currentMotivation;
  int get currentDuration => _selectedTimeInMinutes;

  // İlerleme Çubuğu Hesaplama (0.0 ile 1.0 arası)
  double get progress {
    if (_selectedTimeInMinutes == 0) return 0;
    int totalSeconds = _selectedTimeInMinutes * 60;
    return 1 - (_remainingSeconds / totalSeconds);
  }

  // Zamanı Formatlama (Örn: 24:59)
  String get timeLeftString {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // --- SÖZ BANKASI (JSON Anahtarları) ---
  final List<String> _quotes = [
    "quote_1",
    "quote_2",
    "quote_3",
    "quote_4",
    "quote_5",
    "quote_6",
    "quote_7",
    "quote_8",
  ];

  // Rastgele bir söz anahtarı seçen fonksiyon
  void _changeQuote() {
    _currentMotivation = _quotes[Random().nextInt(_quotes.length)];
  }

  // --- FONKSİYONLAR ---

  // Sayacı Başlat
  void startTimer(String soundPath) {
    if (_timer != null) return; // Zaten çalışıyorsa işlem yapma

    _changeQuote(); // Başlarken rastgele bir söz seç (Örn: quote_3)
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        _isRunning = true;
        notifyListeners();
      } else {
        // --- SÜRE BİTTİ ---
        stopTimer(reset: false);
        _isRunning = false;
        _currentMotivation = "congrats"; // "Tebrikler" anahtarı

        // Sesi Çal
        try {
          // soundPath örneğin 'bell.mp3' olarak gelir, biz yolunu tamamlarız
          await _audioPlayer.play(AssetSource('sounds/$soundPath'));
        } catch (e) {
          debugPrint("Ses çalma hatası: $e");
        }

        notifyListeners();
      }
    });
  }

  // Sayacı Durdur
  void stopTimer({bool reset = true}) {
    _timer?.cancel();
    _timer = null;
    _audioPlayer.stop(); // Sesi de sustur
    _isRunning = false;
    notifyListeners();
  }

  // Sayacı Sıfırla
  void resetTimer() {
    stopTimer();
    _remainingSeconds = _selectedTimeInMinutes * 60;
    _currentMotivation = "ready"; // "Hazır mısın?" anahtarı
    notifyListeners();
  }

  // Süreyi Değiştir (Focus / Short Break / Long Break butonları için)
  void setTime(int minutes) {
    stopTimer();
    _selectedTimeInMinutes = minutes;
    _remainingSeconds = minutes * 60;
    _currentMotivation = "new_goal"; // "Yeni Hedef" anahtarı
    notifyListeners();
  }
}