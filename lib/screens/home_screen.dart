import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../providers/settings_provider.dart'; // Settings'e erişmek için
import '../screens/settings_screen.dart';
import '../widgets/time_option_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timerProvider = context.watch<TimerProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    // SettingsProvider'ı buraya ekleyelim ki currentDuration'ı oradan almayalım,
    // timerProvider zaten süreyi yönetiyor, sorun yok.

    return Scaffold(
      // backgroundColor SATIRINI SİLDİK! Artık main.dart'taki temadan otomatik alacak.
      appBar: AppBar(
        title: Text(
          'Pomodoro',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. ÜST BUTONLAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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

          // 2. ORTA SAYAÇ
          Stack(
            alignment: Alignment.center,
            children: [
              // Gölge ve Derinlik Efekti (Dinamik Renk)
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // BURASI DEĞİŞTİ: Sabit beyaz yerine Tema'nın kart rengini kullandık
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05), // Gölgeyi biraz yumuşattık
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
                  // Arka plan izi dinamik olsun (açık modda gri, koyu modda daha koyu gri)
                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : const Color(0xFFF0F0F0),
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  strokeCap: StrokeCap.round,
                ),
              ),
              // Sayaç Yazısı
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timerProvider.timeLeftString,
                    style: GoogleFonts.bebasNeue(
                      fontSize: 90,
                      // BURASI DEĞİŞTİ: Sabit siyah yerine "OnSurface" (Zemin üstü yazı) rengi
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    timerProvider.isRunning ? "Odaklan" : "Hazır",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      // BURASI DEĞİŞTİ: Biraz saydamlık verdik, her zemine uyar
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                // Play Butonu
                GestureDetector(
                  onTap: () {
                    if (timerProvider.isRunning) {
                      timerProvider.stopTimer();
                    } else {
                      // HAH! İŞTE BURADA AYARLARDAKİ SESİ GÖNDERİYORUZ
                      timerProvider.startTimer(settingsProvider.selectedSound);
                    }
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor, // Temadan al
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withOpacity(0.4),
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

                // Reset Butonu
                GestureDetector(
                  onTap: () => timerProvider.resetTimer(),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      // Dinamik renk
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Theme.of(context).dividerColor.withOpacity(0.1)
                      ),
                    ),
                    child: Icon(
                        Icons.refresh_rounded,
                        // İkon rengi de dinamik
                        color: Theme.of(context).iconTheme.color?.withOpacity(0.7) ?? Colors.grey
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, TimerProvider provider, String title, int time) {
    return TimeOptionButton(
      title: title,
      minutes: time,
      isSelected: provider.currentDuration == time,
      onTap: () => provider.setTime(time),
    );
  }
}