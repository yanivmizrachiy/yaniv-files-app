import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'features/pdf/ui/pdf_screen.dart';

void main() => runApp(const YanivFilesApp());

class YanivFilesApp extends StatelessWidget {
  const YanivFilesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appTitle,
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
        appBar: AppBar(title: const Text('הקבצים של יניב')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PdfScreen())),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                child: const Text('PDF'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: () {}, child: const Text('תמונות (בקרוב)')),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: () {}, child: const Text('אחרונים (בקרוב)')),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: () {}, child: const Text('מועדפים (בקרוב)')),
              const Spacer(),
              const Text(
                'שלב זה: PDF אמיתי + בחירה עד 5 + תצוגה לפני שליחה.\n'
                'השלב הבא: תמונות (טעינה מדורגת) + מועדפים + אחרונים.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
