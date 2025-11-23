import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider'ı dinlemeye başlıyoruz.
    // context.watch: "TimerProvider'da bir değişiklik olursa bu sayfayı yeniden çiz" demek.
    final timerProvider = context.watch<TimerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. KOCAMAN SAYAÇ
            // 1. KOCAMAN SAYAÇ ve İLERLEME ÇUBUĞU
            Stack(
              alignment: Alignment.center,
              children: [
                // Arkadaki silik çember (Pist)
                SizedBox(
                  width: 250,
                  height: 250,
                  child: CircularProgressIndicator(
                    value: 1.0, // Hep dolu
                    strokeWidth: 15,
                    color: Colors.grey[300], // Silik gri renk
                  ),
                ),
                // Öndeki dolan çember (Koşucu)
                SizedBox(
                  width: 250,
                  height: 250,
                  child: CircularProgressIndicator(
                    value: timerProvider.progress, // Provider'dan gelen oran!
                    strokeWidth: 15,
                    color: Theme.of(context).primaryColor, // Temanın ana rengi
                    strokeCap: StrokeCap.round, // Uçları yuvarlak olsun
                  ),
                ),
                // Ortadaki Yazı
                Text(
                  timerProvider.timeLeftString,
                  style: const TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            const SizedBox(height: 50), // Biraz boşluk

            // 2. BUTONLAR
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Başlat / Duraklat Butonu
                FloatingActionButton.large(
                  onPressed: () {
                    if (timerProvider.isRunning) {
                      timerProvider.stopTimer();
                    } else {
                      timerProvider.startTimer();
                    }
                  },
                  tooltip: timerProvider.isRunning ? 'Duraklat' : 'Başlat',
                  child: Icon(
                    timerProvider.isRunning ? Icons.pause : Icons.play_arrow,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 20),

                // Sıfırla Butonu (Sadece süre durmuşsa veya işlememişse görünsün opsiyonel, şimdilik hep koyalım)
                FloatingActionButton(
                  onPressed: () => timerProvider.resetTimer(),
                  backgroundColor: Colors.red[100],
                  elevation: 0,
                  child: const Icon(Icons.refresh, color: Colors.red),
                ),
              ],
            ),

            // 3. DURUM BİLGİSİ (Çalışıyor mu?)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                timerProvider.isRunning ? "Hadi Bakalım, Odaklan! 💪" : "Hazır mısın?",
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}