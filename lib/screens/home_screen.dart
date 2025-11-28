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

    final bool isTimerRunning = timerProvider.isRunning;
    final bool isAlarmPlaying = timerProvider.isAlarmPlaying; // Yeni durum kontrolü
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color defaultBgColor = Theme.of(context).scaffoldBackgroundColor;

    // --- RESPONSIVE AYARLAR ---
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenHeight < 700;

    final double circleSize = isSmallScreen ? 250 : 300;
    final double timerFontSize = circleSize * 0.28;

    final double buttonPaddingVertical = isSmallScreen ? 12 : 16;
    final double buttonPaddingHorizontal = isSmallScreen ? 30 : 40;

    // --- RENK PALETİ ---
    const Color accentColor = Color(0xFF64FFDA);
    const Color darkNavy = Color(0xFF1A2980);

    // --- GRADYAN RENKLERİ ---
    // 1. Çalışırken (Mavi/Turkuaz)
    const List<Color> runningGradient = [
      Color(0xFF1A2980),
      Color(0xFF26D0CE),
    ];

    // 2. Bittiğinde/Alarm (Zafer Moru)
    const List<Color> finishedGradient = [
      Color(0xFF8E2DE2), // Derin Mor
      Color(0xFF4A00E0), // Parlak İndigo
    ];

    // 3. Dururken (Düz Renk)
    final List<Color> idleGradient = [defaultBgColor, defaultBgColor];

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: Text(
          'title'.tr(),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            // Alarm veya Timer çalışıyorsa yazı beyaz olsun
            color: (isTimerRunning || isAlarmPlaying) ? Colors.white : null,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
            color: (isTimerRunning || isAlarmPlaying) ? Colors.white : null
        ),
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

      // --- ANİMASYONLU ARKA PLAN (3 AŞAMALI) ---
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // Mantık: Alarm çalıyor mu? -> Mor. Çalışıyor mu? -> Mavi. Hiçbiri mi? -> Düz.
            colors: isAlarmPlaying
                ? finishedGradient
                : isTimerRunning
                ? runningGradient
                : idleGradient,
          ),
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- ÜST BUTONLAR ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: _buildOption(context, timerProvider, "focus".tr(), settingsProvider.workTime, TimerMode.work, isTimerRunning || isAlarmPlaying)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildOption(context, timerProvider, "short_break".tr(), settingsProvider.shortBreakTime, TimerMode.shortBreak, isTimerRunning || isAlarmPlaying)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildOption(context, timerProvider, "long_break".tr(), settingsProvider.longBreakTime, TimerMode.longBreak, isTimerRunning || isAlarmPlaying)),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // --- ORTA ALAN ---
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Daire Arka Planı
                      Container(
                        width: circleSize,
                        height: circleSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (isTimerRunning || isAlarmPlaying)
                              ? Colors.white.withOpacity(0.05)
                              : Theme.of(context).cardColor,
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
                      // Progress Bar
                      SizedBox(
                        width: circleSize - 20,
                        height: circleSize - 20,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                              begin: 0.0,
                              end: timerProvider.progress
                          ),
                          duration: const Duration(seconds: 1),
                          curve: Curves.linear,
                          builder: (context, value, _) {
                            return CircularProgressIndicator(
                              value: value,
                              strokeWidth: 18,
                              backgroundColor: (isTimerRunning || isAlarmPlaying)
                                  ? Colors.white.withOpacity(0.15)
                                  : (isDark ? Colors.grey.shade800 : const Color(0xFFF0F0F0)),

                              // Alarm çalarken YEŞİL veya BEYAZ yapabiliriz,
                              // ama Turkuaz morun üstünde de güzel durur.
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  (isTimerRunning || isAlarmPlaying)
                                      ? accentColor
                                      : Theme.of(context).primaryColor
                              ),
                              strokeCap: StrokeCap.round,
                            );
                          },
                        ),
                      ),

                      // --- SÜRE YAZISI ---
                      SizedBox(
                        width: circleSize * 0.70,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Transform.translate(
                            offset: const Offset(0, 5),
                            child: Text(
                              timerProvider.timeLeftString,
                              style: TextStyle(
                                fontFamily: 'BebasNeue',
                                fontSize: timerFontSize,
                                color: (isTimerRunning || isAlarmPlaying)
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurface,
                                letterSpacing: 2,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // --- MOTİVASYON SÖZÜ ---
                  Container(
                    height: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    alignment: Alignment.center,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        timerProvider.currentMotivation.tr(),
                        key: ValueKey<String>(timerProvider.currentMotivation),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w500,
                          color: (isTimerRunning || isAlarmPlaying)
                              ? Colors.white.withOpacity(0.9)
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // --- ALT BUTONLAR ---
                  Padding(
                    padding: EdgeInsets.only(bottom: isSmallScreen ? 20 : 40),
                    child: Column(
                      children: [
                        // --- ANA BUTON ---
                        GestureDetector(
                          onTap: () {
                            if (timerProvider.isAlarmPlaying) {
                              timerProvider.stopAlarm(
                                workTime: settingsProvider.workTime,
                                shortBreakTime: settingsProvider.shortBreakTime,
                                longBreakTime: settingsProvider.longBreakTime,
                              );
                            } else if (timerProvider.isRunning) {
                              timerProvider.stopTimer(reset: false);
                            } else {
                              timerProvider.startTimer(settingsProvider);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: EdgeInsets.symmetric(horizontal: buttonPaddingHorizontal, vertical: buttonPaddingVertical),
                            decoration: BoxDecoration(
                              color: timerProvider.isAlarmPlaying
                                  ? Colors.green // Bitince Yeşil
                                  : timerProvider.isRunning
                                  ? Colors.white
                                  : Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
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
                                  color: timerProvider.isRunning && !timerProvider.isAlarmPlaying
                                      ? darkNavy
                                      : Colors.white,
                                  size: isSmallScreen ? 28 : 32,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  timerProvider.isAlarmPlaying
                                      ? "stop_alarm".tr()
                                      : timerProvider.isRunning
                                      ? "pause".tr()
                                      : (timerProvider.remainingSeconds < timerProvider.currentDuration * 60)
                                      ? "resume".tr()
                                      : "start".tr(),
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: isSmallScreen ? 18 : 20,
                                    fontWeight: FontWeight.bold,
                                    color: timerProvider.isRunning && !timerProvider.isAlarmPlaying
                                        ? darkNavy
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // --- SIFIRLA BUTONU ---
                        IgnorePointer(
                          ignoring: timerProvider.isAlarmPlaying ||
                              timerProvider.remainingSeconds == timerProvider.currentDuration * 60,
                          child: Opacity(
                            opacity: (!timerProvider.isAlarmPlaying &&
                                timerProvider.remainingSeconds != timerProvider.currentDuration * 60)
                                ? 1.0
                                : 0.0,
                            child: GestureDetector(
                              onTap: () => timerProvider.resetTimer(),
                              child: Text(
                                "reset".tr(),
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: (isTimerRunning || isAlarmPlaying)
                                      ? Colors.white.withOpacity(0.6)
                                      : Theme.of(context).dividerColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
      ),
    );
  }

  Widget _buildOption(BuildContext context, TimerProvider provider, String title, int time, TimerMode mode, bool isColoredBackground) {
    return TimeOptionButton(
      title: title,
      minutes: time,
      isSelected: provider.currentMode == mode,
      onTap: () => provider.setTime(time, mode),
    );
  }
}