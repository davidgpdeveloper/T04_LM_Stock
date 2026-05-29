import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/botiga.dart';
import '../repositories/botiga_repository.dart';

class BotigaFormScreen extends StatefulWidget {
  final Botiga? botiga;

  const BotigaFormScreen({super.key, this.botiga});

  @override
  State<BotigaFormScreen> createState() => _BotigaFormScreenState();
}

class _BotigaFormScreenState extends State<BotigaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomController;
  late final TextEditingController _nomCompletController;
  late final TextEditingController _nifController;
  late final TextEditingController _adrecaController;
  late final TextEditingController _poblacioController;
  late final TextEditingController _cpController;
  late final TextEditingController _mailController;
  late final TextEditingController _telefonController;
  late final TextEditingController _observacionsController;

  bool get _isEditing => widget.botiga != null;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.botiga?.nom ?? '');
    _nomCompletController =
        TextEditingController(text: widget.botiga?.nomComplet ?? '');
    _nifController = TextEditingController(text: widget.botiga?.nif ?? '');
    _adrecaController =
        TextEditingController(text: widget.botiga?.adreca ?? '');
    _poblacioController =
        TextEditingController(text: widget.botiga?.poblacio ?? '');
    _cpController =
        TextEditingController(text: widget.botiga?.codiPostal ?? '');
    _mailController = TextEditingController(text: widget.botiga?.mail ?? '');
    _telefonController =
        TextEditingController(text: widget.botiga?.telefon ?? '');
    _observacionsController =
        TextEditingController(text: widget.botiga?.observacions ?? '');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = context.read<BotigaRepository>();
    final nom = _nomController.text.trim();

    final exists = await repo.existsByName(nom, excludeId: widget.botiga?.id);
    if (exists && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ja existeix una botiga amb aquest nom'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final botiga = Botiga(
      id: widget.botiga?.id ?? repo.nextId,
      nom: nom,
      nomComplet: _nomCompletController.text.trim(),
      nif: _nifController.text.trim(),
      adreca: _adrecaController.text.trim(),
      poblacio: _poblacioController.text.trim(),
      codiPostal: _cpController.text.trim(),
      mail: _mailController.text.trim(),
      telefon: _telefonController.text.trim(),
      observacions: _observacionsController.text.trim(),
    );

    if (_isEditing) {
      await repo.update(botiga);
    } else {
      await repo.add(botiga);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Botiga actualitzada correctament'
                : 'Botiga afegida correctament',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar botiga' : 'Afegir botiga'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nomController,
                    decoration: const InputDecoration(
                      labelText: 'Nom *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.store),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nom és obligatori';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nomCompletController,
                    decoration: const InputDecoration(
                      labelText: 'Nom complet',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nifController,
                    decoration: const InputDecoration(
                      labelText: 'NIF',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.credit_card),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _adrecaController,
                    decoration: const InputDecoration(
                      labelText: 'Adreça',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _poblacioController,
                          decoration: const InputDecoration(
                            labelText: 'Població',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_city),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _cpController,
                          decoration: const InputDecoration(
                            labelText: 'Codi postal',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _mailController,
                    decoration: const InputDecoration(
                      labelText: 'Correu electrònic',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _telefonController,
                    decoration: const InputDecoration(
                      labelText: 'Telèfon',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _observacionsController,
                    decoration: const InputDecoration(
                      labelText: 'Observacions',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.notes),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: Icon(_isEditing ? Icons.save : Icons.add),
                    label: Text(_isEditing ? 'Desar canvis' : 'Afegir botiga'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _nomCompletController.dispose();
    _nifController.dispose();
    _adrecaController.dispose();
    _poblacioController.dispose();
    _cpController.dispose();
    _mailController.dispose();
    _telefonController.dispose();
    _observacionsController.dispose();
    super.dispose();
  }
}
