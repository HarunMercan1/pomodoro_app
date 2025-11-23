import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; // <--- DİL İÇİN
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        // 'settings_title' anahtarını JSON'dan çekiyoruz
        title: Text('settings_title'.tr(), style: GoogleFonts.poppins()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          // 1. DİL AYARI (YENİ EKLENEN KISIM)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text('language_label'.tr(), style: GoogleFonts.poppins()),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Türkçe Butonu
                  _LanguageButton(
                    langCode: 'tr',
                    flag: '🇹🇷',
                    isSelected: context.locale.languageCode == 'tr',
                    onTap: () => context.setLocale(const Locale('tr',)),
                  ),
                  const SizedBox(width: 10),
                  // İngilizce Butonu
                  _LanguageButton(
                    langCode: 'en',
                    flag: '🇺🇸',
                    isSelected: context.locale.languageCode == 'en',
                    onTap: () => context.setLocale(const Locale('en',)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 2. TEMA AYARI
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: SwitchListTile(
              title: Text('dark_mode'.tr(), style: GoogleFonts.poppins()),
              secondary: Icon(settings.isDarkMode ? Icons.dark_mode : Icons.light_mode),
              value: settings.isDarkMode,
              activeColor: Theme.of(context).primaryColor,
              onChanged: (value) {
                settings.toggleTheme(value);
              },
            ),
          ),

          const SizedBox(height: 20),

          // 3. SES AYARI
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: const Icon(Icons.music_note),
              title: Text('sound_label'.tr(), style: GoogleFonts.poppins()),
              trailing: DropdownButton<String>(
                value: settings.selectedSound,
                underline: Container(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    settings.setSound(newValue);
                  }
                },
                // Ses isimlerini de JSON'dan çekiyoruz
                items: settings.soundOptions.entries.map((entry) {
                  // entry.key: 'bell.mp3' gibi dosya adı
                  // entry.value: 'Klasik Zil' gibi eski isim.
                  // Ama biz JSON'da anahtarları 'classic_bell', 'digital', 'alarm' diye tanımladık.
                  // Basit bir eşleştirme yapalım:
                  String labelKey = '';
                  if (entry.key.contains('bell')) labelKey = 'classic_bell';
                  else if (entry.key.contains('digital')) labelKey = 'digital';
                  else if (entry.key.contains('alarm')) labelKey = 'alarm';

                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(labelKey.tr(), style: GoogleFonts.poppins()), // .tr() ile çevir
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Küçük şık bir dil butonu
class _LanguageButton extends StatelessWidget {
  final String langCode;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.langCode,
    required this.flag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Text(flag, style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}