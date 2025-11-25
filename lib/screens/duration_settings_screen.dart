import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/settings_provider.dart';
import '../providers/timer_provider.dart';

class DurationSettingsScreen extends StatelessWidget {
  const DurationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Hem Ayarları hem de Timer'ı dinliyoruz/yönetiyoruz
    final settings = context.watch<SettingsProvider>();
    final timerProvider = context.read<TimerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "duration_settings".tr(), // JSON'a ekleyeceğiz
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
            value: settings.workTime,
            min: 10,
            max: 90, // 90 dakikaya kadar çıkabilsin
            onChanged: (val) {
              int newValue = val.toInt();
              settings.setWorkTime(newValue);
              // ANLIK GÜNCELLEME SİNYALİ
              timerProvider.updateDurationFromSettings(newValue, TimerMode.work);
            },
          ),

          const SizedBox(height: 20),

          // 2. Kısa Mola
          _buildDurationSlider(
            context,
            label: "short_break".tr(),
            value: settings.shortBreakTime,
            min: 1,
            max: 30,
            onChanged: (val) {
              int newValue = val.toInt();
              settings.setShortBreakTime(newValue);
              // ANLIK GÜNCELLEME SİNYALİ
              timerProvider.updateDurationFromSettings(newValue, TimerMode.shortBreak);
            },
          ),

          const SizedBox(height: 20),

          // 3. Uzun Mola
          _buildDurationSlider(
            context,
            label: "long_break".tr(),
            value: settings.longBreakTime,
            min: 5,
            max: 45,
            onChanged: (val) {
              int newValue = val.toInt();
              settings.setLongBreakTime(newValue);
              // ANLIK GÜNCELLEME SİNYALİ
              timerProvider.updateDurationFromSettings(newValue, TimerMode.longBreak);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSlider(
      BuildContext context, {
        required String label,
        required int value,
        required double min,
        required double max,
        required Function(double) onChanged,
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
                    "$value dk",
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
                value: value.toDouble(),
                min: min,
                max: max,
                // divisions: ...  <--- BU SATIRI SİLDİK! ARTIK NOKTA YOK, KAYMAK GİBİ.
                activeColor: Theme.of(context).primaryColor,
                inactiveColor: Theme.of(context).primaryColor.withOpacity(0.2),
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}