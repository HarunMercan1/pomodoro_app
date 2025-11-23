import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'dart:math'; // Yıldız çizimi için
import '../providers/timer_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/settings_screen.dart';
import '../widgets/time_option_button.dart';
import 'package:easy_localization/easy_localization.dart'; // <--- BUNU EKLE

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

    // TimerProvider'ı dinle, süre 0 olunca konfeti patlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimerProvider>().addListener(() {
        if (!mounted) return;
        final provider = context.read<TimerProvider>();
        // Eğer süre 0 ise ve konfeti henüz oynamıyorsa -> PATLAT
        if (provider.remainingSeconds == 0 &&
            provider.currentDuration != 0 &&
            _confettiController.state != ConfettiControllerState.playing) {
          _confettiController.play();
        }
      });
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  /// Yıldız şekli çizen fonksiyon (Konfeti için)
  Path drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);
    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step), halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep), halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    final timerProvider = context.watch<TimerProvider>();
    final settingsProvider = context.read<SettingsProvider>(); // Sadece okumak için

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'title'.tr(),
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
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // UYGULAMA İÇERİĞİ
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _buildOption(context, timerProvider, "focus".tr(), 25)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildOption(context, timerProvider, "short_break".tr(), 5)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildOption(context, timerProvider, "long_break".tr(), 15)),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          spreadRadius: 10,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 260,
                    height: 260,
                    child: CircularProgressIndicator(
                      value: timerProvider.progress,
                      strokeWidth: 18,
                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : const Color(0xFFF0F0F0),
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timerProvider.timeLeftString,
                        style: GoogleFonts.bebasNeue(
                          fontSize: 90,
                          color: Theme.of(context).colorScheme.onSurface,
                          letterSpacing: 2,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20), // Çok uzun söz olursa kenarlara yapışmasın
                        child: Text(
                          timerProvider.currentMotivation, // <--- ARTIK BURASI DEĞİŞKEN
                          textAlign: TextAlign.center, // Uzun söz olursa ortalasın
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            letterSpacing: 1.0, // Biraz kıstık ki sığsın
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (timerProvider.isRunning) {
                          timerProvider.stopTimer();
                        } else {
                          timerProvider.startTimer(settingsProvider.selectedSound);
                        }
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
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
                    GestureDetector(
                      onTap: () => timerProvider.resetTimer(),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Theme.of(context).dividerColor.withOpacity(0.1)
                          ),
                        ),
                        child: Icon(
                            Icons.refresh_rounded,
                            color: Theme.of(context).iconTheme.color?.withOpacity(0.7) ?? Colors.grey
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // KONFETİ WIDGET (YILDIZLI)
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple
            ],
            createParticlePath: drawStar, // Yıldız fonksiyonunu bağladık
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