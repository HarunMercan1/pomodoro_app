import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/settings_provider.dart';
import '../providers/timer_provider.dart';

class DurationSettingsScreen extends StatefulWidget {
  const DurationSettingsScreen({super.key});

  @override
  State<DurationSettingsScreen> createState() => _DurationSettingsScreenState();
}

class _DurationSettingsScreenState extends State<DurationSettingsScreen> {
  // Slider değerlerini anlık olarak tutacak yerel değişkenler
  // Provider'ı her milisaniyede yormamak için.
  double? _tempWorkTime;
  double? _tempShortBreak;
  double? _tempLongBreak;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final timerProvider = context.read<TimerProvider>();

    // Eğer yerel değişkenler null ise (ilk açılış), provider'dan al
    double currentWork = _tempWorkTime ?? settings.workTime.toDouble();
    double currentShort = _tempShortBreak ?? settings.shortBreakTime.toDouble();
    double currentLong = _tempLongBreak ?? settings.longBreakTime.toDouble();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "duration_settings".tr(),
          style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. Odaklanma Süresi
          _buildDurationSlider(
            context,
            label: "focus".tr(),
            value: currentWork,
            min: 10,
            max: 90,
            onChanged: (val) {
              setState(() => _tempWorkTime = val); // Sadece ekranı güncelle (HIZLI)
            },
            onChangeEnd: (val) {
              // Parmak çekilince kaydet (AĞIR İŞLEM)
              int newValue = val.toInt();
              settings.setWorkTime(newValue);
              timerProvider.updateDurationFromSettings(newValue, TimerMode.work);
              _tempWorkTime = null; // Yerel değeri sıfırla
            },
          ),

          const SizedBox(height: 20),

          // 2. Kısa Mola
          _buildDurationSlider(
            context,
            label: "short_break".tr(),
            value: currentShort,
            min: 1,
            max: 30,
            onChanged: (val) {
              setState(() => _tempShortBreak = val);
            },
            onChangeEnd: (val) {
              int newValue = val.toInt();
              settings.setShortBreakTime(newValue);
              timerProvider.updateDurationFromSettings(newValue, TimerMode.shortBreak);
              _tempShortBreak = null;
            },
          ),

          const SizedBox(height: 20),

          // 3. Uzun Mola
          _buildDurationSlider(
            context,
            label: "long_break".tr(),
            value: currentLong,
            min: 5,
            max: 45,
            onChanged: (val) {
              setState(() => _tempLongBreak = val);
            },
            onChangeEnd: (val) {
              int newValue = val.toInt();
              settings.setLongBreakTime(newValue);
              timerProvider.updateDurationFromSettings(newValue, TimerMode.longBreak);
              _tempLongBreak = null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSlider(
      BuildContext context, {
        required String label,
        required double value,
        required double min,
        required double max,
        required Function(double) onChanged,
        required Function(double) onChangeEnd, // Yeni parametre
      }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    label,
                    style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 16)
                ),
                Text(
                    "${value.toInt()} dk",
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                        fontSize: 16
                    )
                ),
              ],
            ),
            const SizedBox(height: 10),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 6.0,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                activeColor: Theme.of(context).primaryColor,
                inactiveColor: Theme.of(context).primaryColor.withOpacity(0.2),
                onChanged: onChanged, // Anlık değişim (görsel)
                onChangeEnd: onChangeEnd, // Kayıt işlemi
              ),
            ),
          ],
        ),
      ),
    );
  }
}