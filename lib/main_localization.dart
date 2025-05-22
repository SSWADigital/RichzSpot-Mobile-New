import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:richzspot/core/utils/localization_helper.dart'; // Import helper

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Title',
      locale: LocalizationHelper.currentLocale, // Set locale saat ini
      supportedLocales: LocalizationHelper.supportedLocales, // Daftar locale yang didukung
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizations.delegate, // Delegate kustom kita
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        // Cek apakah locale yang diterima didukung
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        // Jika tidak didukung, gunakan locale default (misalnya, Inggris)
        return const Locale('en', '');
      },
      home: const MyHomePage(), // Halaman utama Anda
      // ... konfigurasi MaterialApp lainnya
    );
  }
}

// Custom LocalizationsDelegate
class AppLocalizations {
  const AppLocalizations();

  static const LocalizationsDelegate<LocalizationHelper> delegate =
    _AppLocalizationsDelegate();

  static LocalizationHelper of(BuildContext context) {
    return Localizations.of<LocalizationHelper>(context, LocalizationHelper)!;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<LocalizationHelper> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return LocalizationHelper.supportedLocales.contains(locale);
  }

  @override
  Future<LocalizationHelper> load(Locale locale) {
    return LocalizationHelper.delegateLoad(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('greeting'.tr), // Gunakan extension untuk terjemahan
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('welcome_message'.tr, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Aksi tombol
              },
              child: Text('button_submit'.tr),
            ),
            const SizedBox(height: 20),
            Text('profile'.tr, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Text('logout_confirmation'.tr),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(onPressed: () {}, child: Text('cancel'.tr)),
                ElevatedButton(onPressed: () {}, child: Text('logout'.tr)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}