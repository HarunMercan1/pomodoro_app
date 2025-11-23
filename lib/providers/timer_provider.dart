import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class TimerProvider with ChangeNotifier {
  // Varsayılan süreler (Dakika cinsinden)
  static const int defaultWorkTime = 25;
  static const int defaultShortBreak = 5;
  static const int defaultLongBreak = 15;
  final AudioPlayer _audioPlayer = AudioPlayer(); // Ses oynatıcımız

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

  void startTimer(String soundPath) {
    if (_timer != null) return;

    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) async { // async yaptık çünkü ses çalacağız
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        _isRunning = true;
        notifyListeners();
      } else {
        stopTimer(reset: false); // Durdur ama resetleme (00:00 görünsün)
        _isRunning = false;

        // --- SES ÇALMA ANI ---
        // soundPath bize 'bell.mp3' olarak gelecek.
        // Ama asset klasörümüz 'assets/sounds/bell.mp3'.
        // AudioPlayer paketi 'assets/' kısmını kendi halleder, biz 'sounds/...' diyeceğiz.
        await _audioPlayer.play(AssetSource('sounds/$soundPath'));

        notifyListeners();
      }
    });
  }

  void stopTimer({bool reset = true}) {
    _timer?.cancel();
    _timer = null;
    _audioPlayer.stop(); // <--- SESİ DE KES!
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

  int get currentDuration => _selectedTimeInMinutes;

  // Süreyi dışarıdan değiştirmemizi sağlayan fonksiyon
  void setTime(int minutes) {
    stopTimer(); // Önce sayacı durdur ki karışmasın
    _selectedTimeInMinutes = minutes; // Yeni hedefi belirle
    _remainingSeconds = minutes * 60; // Saniyeye çevir
    notifyListeners(); // Arayüze "Hey, süre değişti, kendini güncelle!" de
  }
} // Class burada bitiyor
