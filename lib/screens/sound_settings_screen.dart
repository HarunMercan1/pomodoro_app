import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/settings_provider.dart';
import '../providers/timer_provider.dart';

class SoundSettingsScreen extends StatefulWidget {
  const SoundSettingsScreen({super.key});

  @override
  State<SoundSettingsScreen> createState() => _SoundSettingsScreenState();
}

class _SoundSettingsScreenState extends State<SoundSettingsScreen> {
  double? _currentSliderValue;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final timerProvider = context.watch<TimerProvider>(); // Watch yaptık ki timer durumunu görelim

    double sliderValue = _currentSliderValue ?? settings.backgroundVolume;

    // --- KİLİT KONTROLÜ ---
    // Eğer sayaç çalışıyorsa (isRunning) ayarları kilitle
    final bool isLocked = timerProvider.isRunning;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "sound_settings".tr(),
          style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            settings.stopPreview();
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // --- UYARI MESAJI (Sadece kilitliyse görünür) ---
          if (isLocked)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orangeAccent),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, color: Colors.orange),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Müzik değiştirmek için sayacı durdurun.", // Çeviriye eklenebilir
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // --- AYARLAR LİSTESİ ---
          Expanded(
            child: IgnorePointer(
              ignoring: isLocked, // Kilitliyse tıklamayı engelle
              child: Opacity(
                opacity: isLocked ? 0.5 : 1.0, // Kilitliyse soluk göster
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // MÜZİK BÖLÜMÜ
                    _buildSectionHeader(context, "background_music".tr()),
                    Card(
                      elevation: 0,
                      color: Theme.of(context).cardColor.withOpacity(0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: Text("enable_music".tr(), style: const TextStyle(fontFamily: 'Poppins')),
                              value: settings.isBackgroundMusicEnabled,
                              activeColor: Theme.of(context).primaryColor,
                              onChanged: (val) => settings.toggleBackgroundMusic(val),
                            ),
                            if (settings.isBackgroundMusicEnabled) ...[
                              const Divider(),
                              Row(
                                children: [
                                  const Icon(Icons.volume_mute_rounded, size: 20),
                                  Expanded(
                                    child: Slider(
                                      value: sliderValue,
                                      min: 0.0,
                                      max: 1.0,
                                      activeColor: Theme.of(context).primaryColor,
                                      onChanged: (val) {
                                        setState(() => _currentSliderValue = val);
                                        settings.setVolumeLive(val);
                                      },
                                      onChangeEnd: (val) {
                                        settings.saveVolumeToPrefs();
                                        _currentSliderValue = null;
                                      },
                                    ),
                                  ),
                                  const Icon(Icons.volume_up_rounded, size: 20),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ...settings.backgroundMusics.entries.map((entry) {
                                final isSelected = settings.backgroundMusic == entry.key;
                                return ListTile(
                                  title: Text(entry.value, style: const TextStyle(fontFamily: 'Poppins')),
                                  leading: Icon(
                                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                    color: isSelected ? Theme.of(context).primaryColor : null,
                                  ),
                                  onTap: () => settings.setBackgroundMusic(entry.key),
                                );
                              }).toList(),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // BİLDİRİM BÖLÜMÜ
                    _buildSectionHeader(context, "notification_sound".tr()),
                    Card(
                      elevation: 0,
                      color: Theme.of(context).cardColor.withOpacity(0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        children: settings.notificationSounds.entries.map((entry) {
                          final isSelected = settings.notificationSound == entry.key;
                          return ListTile(
                            title: Text(entry.value, style: const TextStyle(fontFamily: 'Poppins')),
                            trailing: isSelected
                                ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
                                : null,
                            onTap: () => settings.setNotificationSound(entry.key),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).dividerColor,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}