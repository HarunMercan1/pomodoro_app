import 'package:flutter/material.dart';
// Google Fonts importu kaldırıldı
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C63FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? const Color(0xFF6C63FF) : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
              : [],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            maxLines: 1,
            // GÜNCELLEME: GoogleFonts yerine yerel asset fontu
            style: TextStyle(
              fontFamily: 'Poppins',
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}