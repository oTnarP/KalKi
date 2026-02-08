import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme.dart';
import 'screens/home_screen.dart';
import 'providers/kalki_provider.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize locale data for date formatting
  await initializeDateFormatting('bn_BD', null);
  await initializeDateFormatting('en_US', null);

  // Initialize notification service
  await NotificationService().initialize();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => KalKiProvider())],
      child: const KalKiApp(),
    ),
  );
}

class KalKiApp extends StatelessWidget {
  const KalKiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<KalKiProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          title: provider.t('app_name'),
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const HomeScreen(),
        );
      },
    );
  }
}
