import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// Animasyon için 'SingleTickerProviderStateMixin' ekledik
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late String _randomQuoteKey;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 1. RASTGELE SÖZ SEÇ
    int randomNum = Random().nextInt(8) + 1;
    _randomQuoteKey = "quote_$randomNum";

    // 2. ANİMASYONLARI HAZIRLA (2 Saniye sürecek)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Görünürlük (Fade In)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Hafif Büyüme (Scale Up) - Logoyu %20 büyütecek
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // Animasyonu Başlat
    _controller.forward();

    // 3. ZAMANLAYICI (Toplam 5 Saniye bekle ve git)
    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) {
            // Ana sayfaya geçerken yumuşak bir geçiş efekti
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Hafıza sızıntısını önle
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Arka plan için modern, hafif gradyanlı bir renk
    final bgColor = isDark ? const Color(0xFF1E1E2C) : const Color(0xFFF0F2F5);
    final primaryColor = Theme.of(context).primaryColor;
    final textColor = isDark ? Colors.white.withOpacity(0.9) : const Color(0xFF2D3142);

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        // Animasyonları uygulayan ana widget
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- LOGO (Modern ve Gölge Efektli) ---
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/icon/icon.png',
                    width: 160,
                    height: 160,
                  ),
                ),

                const SizedBox(height: 40),

                // --- PREMIUM UYGULAMA İSMİ ---
                Text(
                  "POMODORO",
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w300, // İnce ve zarif
                    color: textColor,
                    letterSpacing: 6.0, // Harf aralarını açtık
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "DIAMOND ELITE\nPLATINUM PLUS",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 26,
                    fontWeight: FontWeight.w900, // Kalın ve güçlü
                    color: primaryColor,
                    height: 1.1, // Satır aralığı
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 10), // Biraz boşluk bırak

                // --- GELİŞTİRİCİ İMZASI ---
                Text(
                  "by Harun Reşit Mercan",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey, // Gri renk asil durur
                    letterSpacing: 2.0, // Harfleri açarak premium hava kat
                  ),
                ),
                const SizedBox(height: 60),

                // --- DİNAMİK SÖZ KUTUSU ---
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Text(
                    _randomQuoteKey.tr(), // JSON'dan çeviri
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // --- Şık Yükleniyor Çubuğu ---
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: primaryColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}