import 'dart:async';
import 'package:flutter/material.dart';

class TimerProvider with ChangeNotifier {
  // Varsayılan süreler (Dakika cinsinden)
  static const int defaultWorkTime = 25;
  static const int defaultShortBreak = 5;
  static const int defaultLongBreak = 15;

  // Anlık sayaç süresi (Saniye cinsinden tutacağız, yönetmesi kolay olsun)
  int _remainingSeconds = defaultWorkTime * 60;

  // Kullanıcının seçtiği hedef süre (İleride ayarlar sayfasından değiştireceğiz)
  int _selectedTimeInMinutes = defaultWorkTime;

  Timer? _timer;
  bool _isRunning = false;

  // Dışarıdan verilere erişmek için "Getter"lar
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;

  // Süreyi ekranda "25:00" gibi göstermek için yardımcı fonksiyon
  String get timeLeftString {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    // 9 saniye kaldıysa "9" değil "09" göstersin diye padLeft kullanıyoruz
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // --- FONKSİYONLAR ---

  void startTimer() {
    if (_timer != null) return; // Zaten çalışıyorsa tekrar başlatma

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        _isRunning = true;
        notifyListeners(); // Arayüze "Hey süre değişti, ekranı güncelle!" diyoruz.
      } else {
        stopTimer();
        _isRunning = false;
        // Burada ileride ses çalma veya bildirim gönderme kodu olacak.
        notifyListeners();
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    notifyListeners();
  }

  void resetTimer() {
    stopTimer();
    _remainingSeconds = _selectedTimeInMinutes * 60;
    notifyListeners();
  }

  // ... diğer kodların altına, class kapanmadan önce ...

  // İlerleme çubuğu için 0.0 ile 1.0 arası değer üretir
  double get progress {
    if (_selectedTimeInMinutes == 0) return 0;
    int totalSeconds = _selectedTimeInMinutes * 60;
    // Kalan süreyi toplam süreye bölüyoruz
    return 1 - (_remainingSeconds / totalSeconds);
  }

  // ... (yukarıdaki kodlar aynı kalacak) ...

  // YENİ EKLENECEK KISIM:
  // Süreyi dışarıdan değiştirmemizi sağlayan fonksiyon
  void setTime(int minutes) {
    stopTimer(); // Önce sayacı durdur ki karışmasın
    _selectedTimeInMinutes = minutes; // Yeni hedefi belirle
    _remainingSeconds = minutes * 60; // Saniyeye çevir
    notifyListeners(); // Arayüze "Hey, süre değişti, kendini güncelle!" de
  }
} // Class burada bitiyor
