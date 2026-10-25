import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/occurrence_provider.dart';
import 'screens/home_screen.dart';
import 'theme/design_system.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar locale pt_BR se necessário (pra intl)
  await initializeDateFormatting('pt_BR', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OccurrenceProvider()),
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
      title: 'Voz Urbana',
      debugShowCheckedModeBanner: false,
      theme: DesignSystem.themeData,
      home: const HomeScreen(),
    );
  }
}
