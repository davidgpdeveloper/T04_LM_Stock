import 'package:flutter/material.dart';
import '../config/app_config.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _modeDemo = false;

  static const _validCredentials = {
    'Lamusca': 'Doremi',
    'Galan': 'David0',
    'Amigo': 'Marta1',
    'Vidal': 'David0',
    'Tarres': 'David0',
  };

  void _login() {
    if (_modeDemo) {
      AppConfig.usarDadesDeProva = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
      return;
    }

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (_validCredentials[username] == password) {
      AppConfig.usarDadesDeProva = false;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(() {
        _errorMessage = 'Usuari o contrasenya incorrectes';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                margin: const EdgeInsets.all(32),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                    const Icon(
                      Icons.inventory_2,
                      size: 80,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'La Musca Stock',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Control d'Stock",
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    SwitchListTile(
                      title: const Text('Mode demostració'),
                      value: _modeDemo,
                      onChanged: (value) {
                        setState(() {
                          _modeDemo = value;
                          _errorMessage = null;
                        });
                      },
                      secondary: Icon(
                        _modeDemo ? Icons.science : Icons.cloud,
                        color: _modeDemo ? Colors.orange : Colors.deepPurple,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _modeDemo
                            ? Colors.orange.shade50
                            : Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _modeDemo
                              ? Colors.orange.shade200
                              : Colors.deepPurple.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _modeDemo ? Icons.info_outline : Icons.cloud_done,
                            size: 16,
                            color: _modeDemo
                                ? Colors.orange.shade700
                                : Colors.deepPurple.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _modeDemo
                                ? 'Carregarà dades de prova'
                                : 'Connectarà a la base de dades',
                            style: TextStyle(
                              fontSize: 12,
                              color: _modeDemo
                                  ? Colors.orange.shade700
                                  : Colors.deepPurple.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (!_modeDemo) ...[
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Usuari',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Contrasenya',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        onSubmitted: (_) => _login(),
                      ),
                    ],
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _login,
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            'Entrar',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
              ),
              const SizedBox(height: 16),
              Text(
                'v1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
