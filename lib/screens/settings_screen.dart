import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Ayarlar', style: GoogleFonts.poppins()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. TEMA AYARI
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: SwitchListTile(
              title: Text('Karanlık Mod', style: GoogleFonts.poppins()),
              secondary: Icon(settings.isDarkMode ? Icons.dark_mode : Icons.light_mode),
              value: settings.isDarkMode,
              activeColor: Theme.of(context).primaryColor,
              onChanged: (value) {
                settings.toggleTheme(value);
              },
            ),
          ),

          const SizedBox(height: 20),

          // 2. SES AYARI
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: const Icon(Icons.music_note),
              title: Text('Bildirim Sesi', style: GoogleFonts.poppins()),
              trailing: DropdownButton<String>(
                value: settings.selectedSound,
                underline: Container(), // Alt çizgiyi kaldırdık
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    settings.setSound(newValue);
                    // İstersek burada sesi test amaçlı çaldırabiliriz (sonra ekleriz)
                  }
                },
                items: settings.soundOptions.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value, style: GoogleFonts.poppins()),
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