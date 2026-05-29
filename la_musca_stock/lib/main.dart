import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'repositories/botiga_repository.dart';
import 'repositories/producte_repository.dart';
import 'repositories/comanda_repository.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.load();
  runApp(const LaMuscaStockApp());
}

class LaMuscaStockApp extends StatelessWidget {
  const LaMuscaStockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BotigaRepository()),
        ChangeNotifierProvider(create: (_) => ProducteRepository()),
        ChangeNotifierProvider(create: (_) => ComandaRepository()),
      ],
      child: MaterialApp(
        title: 'La Musca Stock',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.deepPurple,
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
