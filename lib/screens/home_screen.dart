import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../providers/timer_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/settings_screen.dart';
import '../widgets/time_option_button.dart';
import '../utils/app_colors.dart';
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

    // --- DURUM KONTROLÜ ---
    final bool isTimerRunning = timerProvider.isRunning;
    final bool isAlarmPlaying = timerProvider.isAlarmPlaying;
    final bool isPaused = !isTimerRunning &&
        !isAlarmPlaying &&
        timerProvider.remainingSeconds > 0 &&
        timerProvider.remainingSeconds < timerProvider.currentDuration * 60;

    final bool isActiveState = isTimerRunning || isAlarmPlaying || isPaused;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color defaultBg = Theme.of(context).scaffoldBackgroundColor;
    final Color defaultPrimary = Theme.of(context).primaryColor;
    final Color defaultText = Theme.of(context).colorScheme.onSurface;
    final Color defaultDivider = Theme.of(context).dividerColor;

    // --- RENKLER (HATASIZ ÇAĞRILAR) ---
    final bgGradient = AppColors.getBackgroundGradient(isTimerRunning, isPaused, isAlarmPlaying, defaultBg);
    final ringColor = AppColors.getRingColor(isTimerRunning, isPaused, isAlarmPlaying, defaultPrimary);
    final timerTextColor = AppColors.getTimerTextColor(isTimerRunning, isPaused, isAlarmPlaying, defaultText);

    final topButtonActiveColor = AppColors.getTopButtonActiveColor(isTimerRunning, isPaused, isAlarmPlaying);

    final mainButtonBgColor = AppColors.getMainButtonBackgroundColor(isTimerRunning, isPaused, isAlarmPlaying, defaultPrimary);
    final mainButtonContentColor = AppColors.getMainButtonContentColor(isTimerRunning, isPaused, isAlarmPlaying);

    final resetTextColor = AppColors.getResetTextColor(isActiveState, isPaused, defaultDivider);

    final bool useLightModeStyles = !isDark && !isActiveState;

    // Responsive
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenHeight < 700;
    final double circleSize = isSmallScreen ? 250 : 300;
    final double timerFontSize = circleSize * 0.28;
    final double btnPadV = isSmallScreen ? 12 : 16;
    final double btnPadH = isSmallScreen ? 30 : 40;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: Text(
          'title'.tr(),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: useLightModeStyles ? AppColors.darkNavy : Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
            color: useLightModeStyles ? AppColors.darkNavy : Colors.white
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

      body: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: bgGradient,
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
                          Expanded(child: _buildOption(context, timerProvider, "focus".tr(), settingsProvider.workTime, TimerMode.work, useLightModeStyles, topButtonActiveColor)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildOption(context, timerProvider, "short_break".tr(), settingsProvider.shortBreakTime, TimerMode.shortBreak, useLightModeStyles, topButtonActiveColor)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildOption(context, timerProvider, "long_break".tr(), settingsProvider.longBreakTime, TimerMode.longBreak, useLightModeStyles, topButtonActiveColor)),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // --- ORTA ALAN ---
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: circleSize,
                        height: circleSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActiveState
                              ? Colors.white.withOpacity(0.15)
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
                              backgroundColor: isActiveState
                                  ? Colors.white.withOpacity(0.2)
                                  : (isDark ? Colors.grey.shade800 : const Color(0xFFF0F0F0)),

                              valueColor: AlwaysStoppedAnimation<Color>(ringColor),
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
                                color: timerTextColor,
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
                          // Metin rengini de burada ayarlıyoruz
                          color: isActiveState
                              ? (isPaused ? AppColors.themeBronze : Colors.white.withOpacity(0.9))
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
                            padding: EdgeInsets.symmetric(horizontal: btnPadH, vertical: btnPadV),
                            decoration: BoxDecoration(
                              color: mainButtonBgColor,
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
                                  color: mainButtonContentColor,
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
                                    color: mainButtonContentColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

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
                                  color: resetTextColor,
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

  Widget _buildOption(BuildContext context, TimerProvider provider, String title, int time, TimerMode mode, bool isLightMode, Color? activeColor) {
    return TimeOptionButton(
      title: title,
      minutes: time,
      isSelected: provider.currentMode == mode,
      isLightMode: isLightMode,
      activeBackgroundColor: activeColor,
      activeTextColor: activeColor != null ? Colors.white : null,
      onTap: () => provider.setTime(time, mode),
    );
  }
}