import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/timer_provider.dart'; // Senin oluşturduğun dosya
import 'screens/home_screen.dart'; // Birazdan oluşturacağımız ekran

void main() {
  runApp(
    // MultiProvider: İleride başka özellikler (Tema, Ayarlar vb.) eklersek
    // buraya virgül koyup eklemeye devam edeceğiz. Geleceğe yatırım.
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gazi Pomodoro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(), // Ana sayfamız burası olacak
    );
  }
}