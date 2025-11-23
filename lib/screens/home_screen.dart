import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../widgets/time_option_button.dart'; // Yeni widget'ımızı çağırdık

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timerProvider = context.watch<TimerProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Kırık beyaz, göz yormaz
      appBar: AppBar(
        title: Text(
          'Pomodoro',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. ÜST BUTONLAR (HİZALI VE EŞİT BOYDA)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: IntrinsicHeight( // <--- SİHİRLİ KOMUT BU! (En uzuna göre boy ayarlar)
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch, // <--- Hepsi yukarıdan aşağıya uzasın
                children: [
                  Expanded(child: _buildOption(context, timerProvider, "Focus", 25)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildOption(context, timerProvider, "Short Break", 5)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildOption(context, timerProvider, "Long Break", 15)),
                ],
              ),
            ),
          ),

          const Spacer(),

          // 2. ORTA SAYAÇ (MODERN GÖRÜNÜM)
          Stack(
            alignment: Alignment.center,
            children: [
              // Gölge ve Derinlik Efekti
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 20,
                      spreadRadius: 10,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),
              // İlerleme Çubuğu
              SizedBox(
                width: 260,
                height: 260,
                child: CircularProgressIndicator(
                  value: timerProvider.progress,
                  strokeWidth: 18,
                  backgroundColor: const Color(0xFFF0F0F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                  strokeCap: StrokeCap.round,
                ),
              ),
              // Sayaç Yazısı
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timerProvider.timeLeftString,
                    style: GoogleFonts.bebasNeue( // SAAT FONTU
                      fontSize: 90,
                      color: const Color(0xFF2D2D2D),
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    timerProvider.isRunning ? "Odaklan" : "Hazır",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // 3. ALT KONTROL BUTONLARI
          Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Başlat / Durdur (Büyük Buton)
                GestureDetector(
                  onTap: () {
                    timerProvider.isRunning
                        ? timerProvider.stopTimer()
                        : timerProvider.startTimer();
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Icon(
                      timerProvider.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),

                const SizedBox(width: 25),

                // Yenile Butonu (Küçük)
                GestureDetector(
                  onTap: () => timerProvider.resetTimer(),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Icon(Icons.refresh_rounded, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Yardımcı metot: Hangi sürenin seçili olduğunu anlamak için
  // (Not: Bunu yapmak için TimerProvider'a şu an seçili olan dakikayı tutan bir değişken eklememiz gerekecek
  // ama şimdilik görsel olarak hepsi aynı dursun, sonra orayı bağlarız.)
  Widget _buildOption(BuildContext context, TimerProvider provider, String title, int time) {
    return TimeOptionButton(
      title: title,
      minutes: time,
      // Basit bir mantık: Eğer seçilen süre butonun süresine eşitse 'seçili' yap (şimdilik manuel)
      isSelected: provider.currentDuration == time, // İleride burayı düzelteceğiz
      onTap: () => provider.setTime(time),
    );
  }
}