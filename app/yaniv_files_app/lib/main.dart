import 'package:flutter/material.dart';

void main() => runApp(const YanivFilesApp());

class YanivFilesApp extends StatelessWidget {
  const YanivFilesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'הקבצים של יניב',
      locale: const Locale('he', 'IL'),
      supportedLocales: const [Locale('he', 'IL')],
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('הקבצים של יניב'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text('PDF'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {},
                child: const Text('תמונות'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {},
                child: const Text('אחרונים'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {},
                child: const Text('מועדפים'),
              ),
              const Spacer(),
              const Text(
                'שלב זה: שלד אפליקציה + ארכיטקטורה + Build אוטומטי ב-GitHub.\n'
                'השלב הבא: אינדוקס PDF + גלריית תמונות מדורגת + מסך תצוגה לפני שליחה + כפתור גדול לוואטסאפ שלך + בחירה עד 5.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
