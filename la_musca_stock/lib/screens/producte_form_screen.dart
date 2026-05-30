import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/producte.dart';
import '../models/comanda.dart';
import '../repositories/producte_repository.dart';
import '../repositories/comanda_repository.dart';
import '../widgets/image_picker_widget.dart';

class ProducteFormScreen extends StatefulWidget {
  final Producte? producte;

  // ID de la botiga magatzem
  static const int magatzemId = 25;

  const ProducteFormScreen({super.key, this.producte});

  @override
  State<ProducteFormScreen> createState() => _ProducteFormScreenState();
}

class _ProducteFormScreenState extends State<ProducteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomController;
  late final TextEditingController _quantitatController;
  late final TextEditingController _descripcioController;
  String? _imatgeBase64;

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
    _imatgeBase64 = widget.producte?.imatgeBase64;
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
      imatgeBase64: _imatgeBase64,
      // Marcar com a registre creat des de l'app nova
      isFromNewApp: _isEditing ? widget.producte?.isFromNewApp : true,
    );

    if (_isEditing) {
      await repo.update(producte);
    } else {
      await repo.add(producte);
      // Obtenir el producte creat amb l'ID real assignat pel servidor
      final producteCreat = repo.productes.lastWhere(
        (p) => p.nom == producte.nom,
      );
      // Crear comanda automàtica per al magatzem
      await _createAutoComanda(producteCreat);
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
                  const SizedBox(height: 16),
                  ImagePickerWidget(
                    currentImageBase64: _imatgeBase64,
                    onImageChanged: (value) {
                      setState(() => _imatgeBase64 = value);
                    },
                    label: 'Imatge del producte',
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

  /// Genera l'albarà automàtic per al magatzem (ID 25).
  /// Busca l'últim albarà amb format 'MAG X' i incrementa el número.
  /// Si no en troba cap, genera 'MAG' + data + hora en mil·lisegons.
  String _generateMagatzemAlbara(ComandaRepository comandaRepo) {
    final comandesMagatzem = comandaRepo.comandes
        .where((c) => c.botigaId == ProducteFormScreen.magatzemId && c.albara.startsWith('MAG'))
        .toList();

    // Buscar l'albarà amb el número més alt
    int maxNum = -1;
    final regExp = RegExp(r'^MAG\s*(\d+)$');
    for (final c in comandesMagatzem) {
      final match = regExp.firstMatch(c.albara.trim());
      if (match != null) {
        final num = int.tryParse(match.group(1)!) ?? 0;
        if (num > maxNum) maxNum = num;
      }
    }

    if (maxNum >= 0) {
      return 'MAG ${maxNum + 1}';
    }

    // Si no es troba cap albarà amb format numèric, generar amb data+hora
    final now = DateTime.now();
    return 'MAG${now.year}${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}'
        '${now.millisecondsSinceEpoch}';
  }

  /// Crea una comanda automàtica al magatzem quan s'afegeix un producte nou.
  Future<void> _createAutoComanda(Producte producte) async {
    final comandaRepo = context.read<ComandaRepository>();
    final albara = _generateMagatzemAlbara(comandaRepo);

    final comanda = Comanda(
      id: comandaRepo.nextId,
      albara: albara,
      data: DateTime.now(),
      botigaId: ProducteFormScreen.magatzemId,
      producteId: producte.id,
      quantitat: producte.quantitat,
      estat: 'MAGATZEM IN',
      observacions: 'Comanda auto-generada per registre de producte nou.',
      // Marcar com a registre creat des de l'app nova
      isFromNewApp: true,
    );

    await comandaRepo.add(comanda);
  }
}
