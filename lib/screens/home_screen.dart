import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../providers/timer_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/settings_screen.dart';
import '../widgets/time_option_button.dart';
import 'package:easy_localization/easy_localization.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimerProvider>().addListener(() {
        if (!mounted) return;
        final provider = context.read<TimerProvider>();
        // Eğer süre bittiyse (ve 0 ise) konfeti patlat
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

  Path drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);
    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / 5);
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
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'title'.tr(),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _buildOption(context, timerProvider, "focus".tr(), settingsProvider.workTime, TimerMode.work)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildOption(context, timerProvider, "short_break".tr(), settingsProvider.shortBreakTime, TimerMode.shortBreak)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildOption(context, timerProvider, "long_break".tr(), settingsProvider.longBreakTime, TimerMode.longBreak)),
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
                        style: TextStyle(
                          fontFamily: 'BebasNeue',
                          fontSize: 90,
                          color: Theme.of(context).colorScheme.onSurface,
                          letterSpacing: 2,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          timerProvider.currentMotivation.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),

              // --- YENİLENMİŞ BUTON ALANI ---
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    // --- ANA AKSİYON BUTONU ---
                    GestureDetector(
                      onTap: () {
                        if (timerProvider.isAlarmPlaying) {
                          // Alarm çalıyorsa -> Sustur ve Bitir
                          timerProvider.stopAlarm();
                        } else if (timerProvider.isRunning) {
                          // Sayaç çalışıyorsa -> Duraklat
                          timerProvider.stopTimer(reset: false);
                        } else {
                          // Durmuşsa veya hiç başlamamışsa -> Başlat
                          timerProvider.startTimer(settingsProvider.selectedSound);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        decoration: BoxDecoration(
                          // Duruma göre renk
                          color: timerProvider.isAlarmPlaying
                              ? Colors.green // Alarm = Yeşil
                              : timerProvider.isRunning
                              ? Colors.orangeAccent // Çalışıyor = Turuncu
                              : Theme.of(context).primaryColor, // Bekliyor = Tema Rengi
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: (timerProvider.isAlarmPlaying
                                  ? Colors.green
                                  : timerProvider.isRunning
                                  ? Colors.orangeAccent
                                  : Theme.of(context).primaryColor)
                                  .withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              timerProvider.isAlarmPlaying
                                  ? Icons.check_rounded
                                  : timerProvider.isRunning
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              timerProvider.isAlarmPlaying
                                  ? "stop_alarm".tr() // BİTİR
                                  : timerProvider.isRunning
                                  ? "pause".tr() // DURAKLAT
                                  : (timerProvider.remainingSeconds < timerProvider.currentDuration * 60)
                                  ? "resume".tr() // DEVAM ET
                                  : "start".tr(), // BAŞLAT
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- SIFIRLAMA BUTONU (Metin Halinde) ---
                    Visibility(
                      visible: !timerProvider.isAlarmPlaying &&
                          timerProvider.remainingSeconds != timerProvider.currentDuration * 60,
                      child: GestureDetector(
                        onTap: () => timerProvider.resetTimer(),
                        child: Text(
                          "reset".tr(),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Theme.of(context).dividerColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple
            ],
            createParticlePath: drawStar,
          ),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, TimerProvider provider, String title, int time, TimerMode mode) {
    return TimeOptionButton(
      title: title,
      minutes: time,
      isSelected: provider.currentMode == mode,
      onTap: () => provider.setTime(time, mode),
    );
  }
}