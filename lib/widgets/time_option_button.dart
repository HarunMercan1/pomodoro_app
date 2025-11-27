import 'package:flutter/material.dart';

class TimeOptionButton extends StatelessWidget {
  final String title;
  final int minutes;
  final VoidCallback onTap;
  final bool isSelected;

  const TimeOptionButton({
    super.key,
    required this.title,
    required this.minutes,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          // Seçiliyse BEYAZ, Değilse Şeffaf Beyaz (Cam Efekti)
          color: isSelected
              ? Colors.white
              : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(30), // Tam yuvarlak köşeler (Hap şekli)
          border: Border.all(
            // Seçili değilse ince bir beyaz çizgi, seçiliyse gerek yok
            color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
              : [],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  // Seçiliyse Koyu Lacivert, değilse Beyaz
                  color: isSelected ? const Color(0xFF1A2980) : Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              // Dakikayı göstermek istemezsen burayı silebilirsin ama şık durur
              Text(
                "$minutes dk",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  color: isSelected ? const Color(0xFF1A2980).withOpacity(0.7) : Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}