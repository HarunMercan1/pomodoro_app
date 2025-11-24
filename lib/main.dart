import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; // <--- PAKETİ EKLEDİK
import 'providers/timer_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'package:wakelock_plus/wakelock_plus.dart'; // <--- BUNU EKLE
import 'screens/splash_screen.dart';

// main artık async çünkü dil yüklemesini bekleyeceğiz
void main() async {
  // Flutter motorunu manuel çalıştırıyoruz (Dil yüklenmeden hata vermesin diye)
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // --- EKRANI AÇIK TUTMA EMRİ ---
  // Bu komut, uygulama açık olduğu sürece ekranın kararmasını engeller.
  try {
    await WakelockPlus.enable();
  } catch (e) {
    debugPrint('Wakelock hatası: $e');
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('tr',), Locale('en',)],
      path: 'assets/translations', // JSON'ların olduğu yer
      fallbackLocale: const Locale('en',), // Dil bulunamazsa İngilizce olsun
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TimerProvider()),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // DİL AYARLARI BURADAN GELİYOR
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale, // Şu anki aktif dil neyse o

      title: 'Pomodoro App',
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // Aydınlık Tema
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        cardColor: Colors.white,
        dividerColor: Colors.grey.shade300,
        primaryColor: const Color(0xFF6C63FF),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
        useMaterial3: true,
      ),

      // Karanlık Tema
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        dividerColor: Colors.grey.shade800,
        primaryColor: const Color(0xFFBB86FC),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFBB86FC),
          secondary: Color(0xFF03DAC6),
          onSurface: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}