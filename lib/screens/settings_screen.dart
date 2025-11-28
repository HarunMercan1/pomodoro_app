import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/settings_provider.dart';
import 'duration_settings_screen.dart';
import 'sound_settings_screen.dart'; // Yeni ekranı import et

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void deactivate() {
    context.read<SettingsProvider>().stopPreview();
    super.deactivate();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      context.read<SettingsProvider>().stopPreview();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'settings_title'.tr(),
          style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // SÜRE AYARLARI
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: Text("duration_settings".tr(), style: const TextStyle(fontFamily: 'Poppins')),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DurationSettingsScreen()),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // SES AYARLARI (YENİ)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: const Icon(Icons.music_note_rounded),
              title: Text("sound_settings".tr(), style: const TextStyle(fontFamily: 'Poppins')),
              subtitle: Text(
                settings.isBackgroundMusicEnabled ? "Açık" : "Kapalı",
                style: const TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SoundSettingsScreen()),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // DİL AYARI
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text('language_label'.tr(), style: const TextStyle(fontFamily: 'Poppins')),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LanguageButton(
                    flag: '🇹🇷',
                    isSelected: context.locale.languageCode == 'tr',
                    onTap: () => context.setLocale(const Locale('tr')),
                  ),
                  const SizedBox(width: 10),
                  _LanguageButton(
                    flag: '🇺🇸',
                    isSelected: context.locale.languageCode == 'en',
                    onTap: () => context.setLocale(const Locale('en')),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // TEMA AYARI
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: SwitchListTile(
              title: Text('dark_mode'.tr(), style: const TextStyle(fontFamily: 'Poppins')),
              secondary: Icon(settings.isDarkMode ? Icons.dark_mode : Icons.light_mode),
              value: settings.isDarkMode,
              activeColor: Theme.of(context).primaryColor,
              onChanged: (value) => settings.toggleTheme(value),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({super.key, required this.flag, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300),
        ),
        child: Text(flag, style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}