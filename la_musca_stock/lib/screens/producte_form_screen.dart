import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/producte.dart';
import '../repositories/producte_repository.dart';

class ProducteFormScreen extends StatefulWidget {
  final Producte? producte;

  const ProducteFormScreen({super.key, this.producte});

  @override
  State<ProducteFormScreen> createState() => _ProducteFormScreenState();
}

class _ProducteFormScreenState extends State<ProducteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomController;
  late final TextEditingController _quantitatController;
  late final TextEditingController _descripcioController;

  bool get _isEditing => widget.producte != null;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.producte?.nom ?? '');
    _quantitatController = TextEditingController(
      text: widget.producte?.quantitat.toString() ?? '0',
    );
    _descripcioController =
        TextEditingController(text: widget.producte?.descripcio ?? '');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = context.read<ProducteRepository>();
    final nom = _nomController.text.trim();

    final exists = await repo.existsByName(
      nom,
      excludeId: widget.producte?.id,
    );
    if (exists && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ja existeix un producte amb aquest nom'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final producte = Producte(
      id: widget.producte?.id ?? repo.nextId,
      nom: nom,
      quantitat: int.tryParse(_quantitatController.text.trim()) ?? 0,
      descripcio: _descripcioController.text.trim(),
    );

    if (_isEditing) {
      await repo.update(producte);
    } else {
      await repo.add(producte);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Producte actualitzat correctament'
                : 'Producte afegit correctament',
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
        title: Text(_isEditing ? 'Editar producte' : 'Afegir producte'),
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
                      labelText: 'Nom del producte *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.inventory),
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
                    controller: _quantitatController,
                    decoration: const InputDecoration(
                      labelText: 'Quantitat',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          int.tryParse(value) == null) {
                        return 'Introduïu un número vàlid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descripcioController,
                    decoration: const InputDecoration(
                      labelText: 'Descripció',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: Icon(_isEditing ? Icons.save : Icons.add),
                    label: Text(
                      _isEditing ? 'Desar canvis' : 'Afegir producte',
                    ),
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
    _quantitatController.dispose();
    _descripcioController.dispose();
    super.dispose();
  }
}
