import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'screens/home_screen.dart';
import 'providers/kalki_provider.dart';

// Hive imports can be added here once we implement persistence
// import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive (for future steps, keeping simple for now)
  // await Hive.initFlutter();

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
    return MaterialApp(
      title: 'KalKi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
