import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/comanda.dart';
import '../repositories/botiga_repository.dart';
import '../repositories/producte_repository.dart';
import '../repositories/comanda_repository.dart';

class ComandaFormScreen extends StatefulWidget {
  final Comanda? comanda;

  const ComandaFormScreen({super.key, this.comanda});

  @override
  State<ComandaFormScreen> createState() => _ComandaFormScreenState();
}

class _ComandaFormScreenState extends State<ComandaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _albaraController;
  late final TextEditingController _quantitatController;
  late final TextEditingController _observacionsController;
  late DateTime _selectedDate;
  int? _selectedBotigaId;
  int? _selectedProducteId;
  String _selectedEstat = 'ENTREGAT';

  bool get _isEditing => widget.comanda != null;

  @override
  void initState() {
    super.initState();
    _albaraController =
        TextEditingController(text: widget.comanda?.albara ?? '');
    _quantitatController = TextEditingController(
      text: widget.comanda != null
          ? widget.comanda!.quantitat.abs().toString()
          : '',
    );
    _observacionsController =
        TextEditingController(text: widget.comanda?.observacions ?? '');
    _selectedDate = widget.comanda?.data ?? DateTime.now();
    _selectedBotigaId = widget.comanda?.botigaId;
    _selectedProducteId = widget.comanda?.producteId;
    _selectedEstat = widget.comanda?.estat ?? 'ENTREGAT';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2014),
      lastDate: DateTime(2030),
      locale: const Locale('ca'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBotigaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccioneu una botiga'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedProducteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccioneu un producte'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final repo = context.read<ComandaRepository>();
    int quantitat = int.tryParse(_quantitatController.text.trim()) ?? 0;

    if (_selectedEstat == 'RECOLLIT' || _selectedEstat == 'VENUT') {
      quantitat = -quantitat.abs();
    } else {
      quantitat = quantitat.abs();
    }

    final comanda = Comanda(
      id: widget.comanda?.id ?? repo.nextId,
      albara: _albaraController.text.trim(),
      data: _selectedDate,
      botigaId: _selectedBotigaId!,
      producteId: _selectedProducteId!,
      quantitat: quantitat,
      estat: _selectedEstat,
      observacions: _observacionsController.text.trim(),
    );

    if (_isEditing) {
      await repo.update(comanda);
    } else {
      await repo.add(comanda);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Comanda actualitzada correctament'
                : 'Comanda afegida correctament',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final botigues = context.watch<BotigaRepository>().botigues;
    final productes = context.watch<ProducteRepository>().productes;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar comanda' : 'Afegir comanda'),
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
                    controller: _albaraController,
                    decoration: const InputDecoration(
                      labelText: 'Albarà *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.receipt),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "L'albarà és obligatori";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        '${_selectedDate.day.toString().padLeft(2, '0')}/'
                        '${_selectedDate.month.toString().padLeft(2, '0')}/'
                        '${_selectedDate.year}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedBotigaId,
                    decoration: const InputDecoration(
                      labelText: 'Botiga *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.store),
                    ),
                    items: botigues
                        .map(
                          (b) => DropdownMenuItem<int>(
                            value: b.id,
                            child: Text(b.nom),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBotigaId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Seleccioneu una botiga';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedProducteId,
                    decoration: const InputDecoration(
                      labelText: 'Producte *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.inventory),
                    ),
                    items: productes
                        .map(
                          (p) => DropdownMenuItem<int>(
                            value: p.id,
                            child: Text(p.nom),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProducteId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Seleccioneu un producte';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _quantitatController,
                    decoration: const InputDecoration(
                      labelText: 'Quantitat *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                      helperText:
                          'Introduïu un valor positiu. El signe es calcula segons l\'estat.',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La quantitat és obligatòria';
                      }
                      if (int.tryParse(value.trim()) == null) {
                        return 'Introduïu un número vàlid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedEstat,
                    decoration: const InputDecoration(
                      labelText: 'Estat *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.flag),
                    ),
                    items: Comanda.estatsDisponibles
                        .map(
                          (estat) => DropdownMenuItem<String>(
                            value: estat,
                            child: Text(estat),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedEstat = value ?? 'ENTREGAT';
                      });
                    },
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
                    label: Text(
                      _isEditing ? 'Desar canvis' : 'Afegir comanda',
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
    _albaraController.dispose();
    _quantitatController.dispose();
    _observacionsController.dispose();
    super.dispose();
  }
}
