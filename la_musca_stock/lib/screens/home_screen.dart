import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../models/comanda.dart';
import '../repositories/botiga_repository.dart';
import '../repositories/producte_repository.dart';
import '../repositories/comanda_repository.dart';
import '../widgets/delete_confirmation_dialog.dart';
import '../widgets/export_button.dart';
import '../widgets/searchable_dropdown.dart';
import 'login_screen.dart';
import 'botiga_form_screen.dart';
import 'producte_form_screen.dart';
import 'comanda_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _dataLoaded = false;

  // Filtres de comandes
  int? _filtreBotigaId;
  int? _filtreProducteId;
  String? _filtreEstat;

  // Cercadors de botigues i productes
  final TextEditingController _searchBotiguesController = TextEditingController();
  final TextEditingController _searchProductesController = TextEditingController();
  String _searchBotiguesQuery = '';
  String _searchProductesQuery = '';

  // ID de la botiga 'La Musca magatzem' per identificar-la a la UI
  static const int _magatzemId = 25;

  // Filtres de consultes d'estoc
  String _consultaTipus = 'botiga'; // 'botiga' o 'producte'
  int? _consultaBotigaId;
  int? _consultaProducteId;
  String? _consultaEstat; // Filtre per estat a consulta per producte

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final botigaRepo = context.read<BotigaRepository>();
    final producteRepo = context.read<ProducteRepository>();
    final comandaRepo = context.read<ComandaRepository>();
    await Future.wait([
      botigaRepo.loadData(),
      producteRepo.loadData(),
      comandaRepo.loadData(),
    ]);
    if (mounted) {
      setState(() => _dataLoaded = true);
    }
  }

  void _onAddPressed() {
    switch (_tabController.index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ComandaFormScreen()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BotigaFormScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProducteFormScreen()),
        );
        break;
      // La pestanya 3 (Consultes) no té botó d'afegir
    }
  }

  String _getAddLabel() {
    switch (_tabController.index) {
      case 0:
        return 'Afegir comanda';
      case 1:
        return 'Afegir botiga';
      case 2:
        return 'Afegir producte';
      default:
        return 'Afegir';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('La Musca Stock'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Tancar sessió',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.receipt_long), text: 'Comandes'),
            Tab(icon: Icon(Icons.store), text: 'Botigues'),
            Tab(icon: Icon(Icons.inventory), text: 'Productes'),
            Tab(icon: Icon(Icons.analytics), text: 'Consultes'),
          ],
        ),
      ),
      body: _dataLoaded
          ? TabBarView(
              controller: _tabController,
              children: [
                _buildComandesTab(),
                _buildBotiguesTab(),
                _buildProductesTab(),
                _buildConsultesTab(),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: _dataLoaded && _tabController.index != 3
          ? FloatingActionButton.extended(
              onPressed: _onAddPressed,
              icon: const Icon(Icons.add),
              label: Text(_getAddLabel()),
            )
          : null,
    );
  }

  // ─── COMANDES TAB ──────────────────────────────────────────────

  Widget _buildComandesTab() {
    final comandaRepo = context.watch<ComandaRepository>();
    final botigaRepo = context.watch<BotigaRepository>();
    final producteRepo = context.watch<ProducteRepository>();

    List<Comanda> comandes = List.of(comandaRepo.comandes);

    if (_filtreBotigaId != null) {
      comandes =
          comandes.where((c) => c.botigaId == _filtreBotigaId).toList();
    }
    if (_filtreProducteId != null) {
      comandes =
          comandes.where((c) => c.producteId == _filtreProducteId).toList();
    }
    if (_filtreEstat != null) {
      comandes =
          comandes.where((c) => c.estat == _filtreEstat).toList();
    }

    comandes.sort((a, b) => b.data.compareTo(a.data));

    return Column(
      children: [
        // Filtre
        Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                // Botigues disponibles segons el producte seleccionat
                SizedBox(
                  width: 200,
                  child: SearchableDropdown<int>(
                    fieldKey: ValueKey('filtre_botiga_$_filtreBotigaId$_filtreProducteId'),
                    value: _filtreBotigaId,
                    decoration: const InputDecoration(
                      labelText: 'Botiga',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: [
                      ...(_filtreProducteId != null
                          ? botigaRepo.botigues.where((b) =>
                              comandaRepo.comandes.any((c) =>
                                  c.producteId == _filtreProducteId &&
                                  c.botigaId == b.id))
                          : botigaRepo.botigues
                      ).map(
                        (b) => SearchableDropdownItem<int>(
                          value: b.id,
                          label: b.nom,
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filtreBotigaId = value;
                        // Verificar que el producte seleccionat segueix sent vàlid
                        if (_filtreProducteId != null && value != null) {
                          final valid = comandaRepo.comandes.any((c) =>
                              c.botigaId == value &&
                              c.producteId == _filtreProducteId);
                          if (!valid) _filtreProducteId = null;
                        }
                      });
                    },
                  ),
                ),
                // Productes disponibles segons la botiga seleccionada
                SizedBox(
                  width: 200,
                  child: SearchableDropdown<int>(
                    fieldKey: ValueKey('filtre_producte_$_filtreProducteId$_filtreBotigaId'),
                    value: _filtreProducteId,
                    decoration: const InputDecoration(
                      labelText: 'Producte',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: [
                      ...(_filtreBotigaId != null
                          ? producteRepo.productes.where((p) =>
                              comandaRepo.comandes.any((c) =>
                                  c.botigaId == _filtreBotigaId &&
                                  c.producteId == p.id))
                          : producteRepo.productes
                      ).map(
                        (p) => SearchableDropdownItem<int>(
                          value: p.id,
                          label: p.nom,
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filtreProducteId = value;
                        // Verificar que la botiga seleccionada segueix sent vàlida
                        if (_filtreBotigaId != null && value != null) {
                          final valid = comandaRepo.comandes.any((c) =>
                              c.producteId == value &&
                              c.botigaId == _filtreBotigaId);
                          if (!valid) _filtreBotigaId = null;
                        }
                      });
                    },
                  ),
                ),
                // Filtre per estat
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String?>(
                    key: ValueKey('filtre_estat_$_filtreEstat'),
                    initialValue: _filtreEstat,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Estat',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Tots els estats'),
                      ),
                      ...Comanda.estatsDisponibles.map(
                        (estat) => DropdownMenuItem<String?>(
                          value: estat,
                          child: Text(estat),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filtreEstat = value;
                      });
                    },
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _filtreBotigaId = null;
                      _filtreProducteId = null;
                      _filtreEstat = null;
                    });
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Netejar filtres'),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'Llegenda d\'estats',
                  onPressed: () => _showEstatLegend(),
                ),
              ],
            ),
          ),
        ),
        // Resultats
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Text(
                '${comandes.length} comandes',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              if (comandes.isNotEmpty)
                ExportButton(
                  title: 'Comandes',
                  headers: const ['Albarà', 'Botiga', 'Producte', 'Quantitat', 'Estat', 'Data'],
                  rows: comandes.map((c) {
                    final botiga = botigaRepo.getById(c.botigaId);
                    final producte = producteRepo.getById(c.producteId);
                    return [
                      c.albara,
                      botiga?.nom ?? 'Desconeguda',
                      producte?.nom ?? 'Desconegut',
                      c.quantitat.toString(),
                      c.estat,
                      '${c.data.day.toString().padLeft(2, '0')}/${c.data.month.toString().padLeft(2, '0')}/${c.data.year}',
                    ];
                  }).toList(),
                ),
            ],
          ),
        ),
        Expanded(
          child: comandes.isEmpty
              ? const Center(
                  child: Text(
                    'No hi ha comandes',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: comandes.length,
                  itemBuilder: (context, index) {
                    final comanda = comandes[index];
                    final botiga = botigaRepo.getById(comanda.botigaId);
                    final producte =
                        producteRepo.getById(comanda.producteId);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      color: botiga?.id == _magatzemId
                          ? Theme.of(context).colorScheme.secondaryContainer
                          : null,
                      child: ListTile(
                        leading: _buildEstatIcon(comanda.estat),
                        title: Row(
                          children: [
                            // Indicador verd per a registres creats des de l'app nova
                            if (comanda.isFromNewApp == true)
                              const Padding(
                                padding: EdgeInsets.only(right: 6),
                                child: Icon(Icons.circle, color: Colors.green, size: 10),
                              ),
                            Expanded(
                              child: Text(
                                '${comanda.albara} — ${botiga?.nom ?? "Desconeguda"}',
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          '${producte?.nom ?? "Desconegut"} · '
                          'Quantitat: ${comanda.quantitat} · '
                          '${comanda.data.day.toString().padLeft(2, '0')}/'
                          '${comanda.data.month.toString().padLeft(2, '0')}/'
                          '${comanda.data.year}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blue,
                              ),
                              tooltip: 'Editar',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ComandaFormScreen(
                                      comanda: comanda,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              tooltip: 'Eliminar',
                              onPressed: () => _deleteComanda(comanda),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEstatIcon(String estat) {
    IconData icon;
    Color color;
    switch (estat) {
      case 'ENTREGAT':
        icon = Icons.local_shipping;
        color = Colors.green;
        break;
      case 'RECOLLIT':
        icon = Icons.assignment_return;
        color = Colors.orange;
        break;
      case 'VENUT':
        icon = Icons.point_of_sale;
        color = Colors.blue;
        break;
      case 'MAGATZEM IN':
        icon = Icons.move_to_inbox;
        color = Colors.teal;
        break;
      case 'DEFECTUOS':
        icon = Icons.warning_amber;
        color = Colors.red.shade800;
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
    }
    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.15),
      child: Icon(icon, color: color, size: 20),
    );
  }

  /// Mostra un diàleg amb la llegenda dels icones d'estat.
  void _showEstatLegend() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Llegenda d\'estats'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _legendRow(Icons.local_shipping, Colors.green, 'ENTREGAT'),
            _legendRow(Icons.assignment_return, Colors.orange, 'RECOLLIT'),
            _legendRow(Icons.point_of_sale, Colors.blue, 'VENUT'),
            _legendRow(Icons.move_to_inbox, Colors.teal, 'MAGATZEM IN'),
            _legendRow(Icons.warning_amber, Colors.red.shade800, 'DEFECTUÓS'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tancar'),
          ),
        ],
      ),
    );
  }

  Widget _legendRow(IconData icon, Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  Future<void> _deleteComanda(Comanda comanda) async {
    final confirmed = await DeleteConfirmationDialog.show(
      context,
      "la comanda '${comanda.albara}' (ID: ${comanda.id})",
    );
    if (confirmed && mounted) {
      await context.read<ComandaRepository>().delete(comanda.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comanda eliminada correctament'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  // ─── BOTIGUES TAB ──────────────────────────────────────────────

  Widget _buildBotiguesTab() {
    final botigaRepo = context.watch<BotigaRepository>();
    final totesBotigues = botigaRepo.botigues.toList()
      ..sort((a, b) => a.nom.compareTo(b.nom));

    // Filtrar per cerca en temps real
    final botigues = _searchBotiguesQuery.isEmpty
        ? totesBotigues
        : totesBotigues.where((b) {
            final query = _searchBotiguesQuery.toLowerCase();
            return b.nom.toLowerCase().contains(query) ||
                b.nomFiscal.toLowerCase().contains(query) ||
                b.poblacio.toLowerCase().contains(query) ||
                b.nif.toLowerCase().contains(query);
          }).toList();

    return Column(
      children: [
        // Cercador en temps real
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: TextField(
            controller: _searchBotiguesController,
            decoration: InputDecoration(
              hintText: 'Cercar botigues...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchBotiguesQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchBotiguesController.clear();
                        setState(() => _searchBotiguesQuery = '');
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            onChanged: (value) {
              setState(() => _searchBotiguesQuery = value);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Text(
                '${botigues.length} botigues',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              if (botigues.isNotEmpty)
                ExportButton(
                  title: 'Botigues',
                  headers: const ['Nom', 'Nom fiscal', 'NIF', 'Adreça', 'Població', 'Codi postal', 'Correu', 'Telèfon'],
                  rows: botigues.map((b) => [
                    b.nom,
                    b.nomFiscal,
                    b.nif,
                    b.adreca,
                    b.poblacio,
                    b.codiPostal,
                    b.mail,
                    b.telefon,
                  ]).toList(),
                ),
            ],
          ),
        ),
        Expanded(
          child: botigues.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'No hi ha botigues',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Icon(
                        Icons.search_off,
                        size: 28,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: botigues.length,
            itemBuilder: (context, index) {
              final botiga = botigues[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                color: botiga.id == _magatzemId
                    ? Theme.of(context).colorScheme.secondaryContainer
                    : null,
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundImage: botiga.imatgeBase64 != null &&
                            botiga.imatgeBase64!.isNotEmpty
                        ? MemoryImage(base64Decode(botiga.imatgeBase64!))
                        : null,
                    child: botiga.imatgeBase64 == null ||
                            botiga.imatgeBase64!.isEmpty
                        ? const Icon(Icons.store)
                        : null,
                  ),
                  title: Row(
                    children: [
                      // Indicador verd per a registres creats des de l'app nova
                      if (botiga.isFromNewApp == true)
                        const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Icon(Icons.circle, color: Colors.green, size: 10),
                        ),
                      Expanded(child: Text(botiga.nom)),
                    ],
                  ),
                  subtitle: botiga.poblacio.isNotEmpty
                      ? Text(botiga.poblacio)
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'Editar',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  BotigaFormScreen(botiga: botiga),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Eliminar',
                        onPressed: () => _deleteBotiga(botiga),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (botiga.nomFiscal.isNotEmpty)
                            _detailRow('Nom fiscal', botiga.nomFiscal),
                          if (botiga.nif.isNotEmpty)
                            _detailRow('NIF', botiga.nif),
                          if (botiga.adreca.isNotEmpty)
                            _detailRow('Adreça', botiga.adreca),
                          if (botiga.poblacio.isNotEmpty)
                            _detailRow('Població', botiga.poblacio),
                          if (botiga.codiPostal.isNotEmpty)
                            _detailRow('Codi postal', botiga.codiPostal),
                          if (botiga.mail.isNotEmpty)
                            _detailRow('Correu', botiga.mail),
                          if (botiga.telefon.isNotEmpty)
                            _detailRow('Telèfon', botiga.telefon),
                          if (botiga.observacions.isNotEmpty)
                            _detailRow('Observacions', botiga.observacions),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _deleteBotiga(dynamic botiga) async {
    final comandaRepo = context.read<ComandaRepository>();
    final relatedComandes = comandaRepo.getByBotigaId(botiga.id);
    final warning = relatedComandes.isEmpty
        ? "la botiga '${botiga.nom}'"
        : "la botiga '${botiga.nom}' i les seves ${relatedComandes.length} comandes associades";

    final confirmed = await DeleteConfirmationDialog.show(context, warning);
    if (confirmed && mounted) {
      await comandaRepo.deleteByBotigaId(botiga.id);
      if (!mounted) return;
      await context.read<BotigaRepository>().delete(botiga.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Botiga eliminada correctament'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  // ─── PRODUCTES TAB ─────────────────────────────────────────────

  Widget _buildProductesTab() {
    final producteRepo = context.watch<ProducteRepository>();
    final totsProductes = producteRepo.productes.toList()
      ..sort((a, b) => a.nom.compareTo(b.nom));

    // Filtrar per cerca en temps real
    final productes = _searchProductesQuery.isEmpty
        ? totsProductes
        : totsProductes.where((p) {
            final query = _searchProductesQuery.toLowerCase();
            return p.nom.toLowerCase().contains(query) ||
                p.descripcio.toLowerCase().contains(query);
          }).toList();

    return Column(
      children: [
        // Cercador en temps real
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: TextField(
            controller: _searchProductesController,
            decoration: InputDecoration(
              hintText: 'Cercar productes...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchProductesQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchProductesController.clear();
                        setState(() => _searchProductesQuery = '');
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            onChanged: (value) {
              setState(() => _searchProductesQuery = value);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Text(
                '${productes.length} productes',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              if (productes.isNotEmpty)
                ExportButton(
                  title: 'Productes',
                  headers: const ['Nom', 'Quantitat', 'Descripció'],
                  rows: productes.map((p) => [
                    p.nom,
                    p.quantitat.toString(),
                    p.descripcio,
                  ]).toList(),
                ),
            ],
          ),
        ),
        Expanded(
          child: productes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'No hi ha productes',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Icon(
                        Icons.search_off,
                        size: 28,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: productes.length,
            itemBuilder: (context, index) {
              final producte = productes[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    backgroundImage: producte.imatgeBase64 != null &&
                            producte.imatgeBase64!.isNotEmpty
                        ? MemoryImage(base64Decode(producte.imatgeBase64!))
                        : null,
                    child: producte.imatgeBase64 == null ||
                            producte.imatgeBase64!.isEmpty
                        ? const Icon(Icons.inventory)
                        : null,
                  ),
                  title: Row(
                    children: [
                      // Indicador verd per a registres creats des de l'app nova
                      if (producte.isFromNewApp == true)
                        const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Icon(Icons.circle, color: Colors.green, size: 10),
                        ),
                      Expanded(child: Text(producte.nom)),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quantitat: ${producte.quantitat}'),
                      if (producte.descripcio.isNotEmpty)
                        Text(
                          producte.descripcio,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'Editar',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProducteFormScreen(producte: producte),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Eliminar',
                        onPressed: () => _deleteProducte(producte),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _deleteProducte(dynamic producte) async {
    final comandaRepo = context.read<ComandaRepository>();
    final relatedComandes = comandaRepo.getByProducteId(producte.id);
    final warning = relatedComandes.isEmpty
        ? "el producte '${producte.nom}'"
        : "el producte '${producte.nom}' i les seves ${relatedComandes.length} comandes associades";

    final confirmed = await DeleteConfirmationDialog.show(context, warning);
    if (confirmed && mounted) {
      await comandaRepo.deleteByProducteId(producte.id);
      if (!mounted) return;
      await context.read<ProducteRepository>().delete(producte.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producte eliminat correctament'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  // ─── CONSULTES TAB ──────────────────────────────────────────────

  Widget _buildConsultesTab() {
    final comandaRepo = context.watch<ComandaRepository>();
    final botigaRepo = context.watch<BotigaRepository>();
    final producteRepo = context.watch<ProducteRepository>();

    return Column(
      children: [
        // Filtre de consulta
        Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tipus de consulta
                Row(
                  children: [
                    const Text(
                      'Consulta per:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                    ChoiceChip(
                      label: const Text('Botiga'),
                      selected: _consultaTipus == 'botiga',
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _consultaTipus = 'botiga';
                            _consultaProducteId = null;
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Producte'),
                      selected: _consultaTipus == 'producte',
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _consultaTipus = 'producte';
                            _consultaBotigaId = null;
                            _consultaEstat = null;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Selector segons el tipus
                if (_consultaTipus == 'botiga')
                  SizedBox(
                    width: 300,
                    child: SearchableDropdown<int>(
                      fieldKey: ValueKey('consulta_botiga_$_consultaBotigaId'),
                      value: _consultaBotigaId,
                      decoration: const InputDecoration(
                        labelText: 'Selecciona una botiga',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: botigaRepo.botigues.map(
                        (b) => SearchableDropdownItem<int>(
                          value: b.id,
                          label: b.nom,
                        ),
                      ).toList(),
                      onChanged: (value) {
                        setState(() {
                          _consultaBotigaId = value;
                        });
                      },
                    ),
                  ),
                if (_consultaTipus == 'producte') ...[                  SizedBox(
                    width: 300,
                    child: SearchableDropdown<int>(
                      fieldKey: ValueKey('consulta_producte_$_consultaProducteId'),
                      value: _consultaProducteId,
                      decoration: const InputDecoration(
                        labelText: 'Selecciona un producte',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: producteRepo.productes.map(
                        (p) => SearchableDropdownItem<int>(
                          value: p.id,
                          label: p.nom,
                        ),
                      ).toList(),
                      onChanged: (value) {
                        setState(() {
                          _consultaProducteId = value;
                          _consultaEstat = null;
                        });
                      },
                    ),
                  ),
                  // Filtre per estat del producte
                  if (_consultaProducteId != null) ...[                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        ChoiceChip(
                          label: const Text('Tots'),
                          selected: _consultaEstat == null,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _consultaEstat = null);
                            }
                          },
                        ),
                        ...Comanda.estatsDisponibles.map(
                          (estat) => ChoiceChip(
                            label: Text(estat),
                            selected: _consultaEstat == estat,
                            onSelected: (selected) {
                              setState(() {
                                _consultaEstat = selected ? estat : null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
        // Resultats
        Expanded(
          child: _buildConsultesResultats(
            comandaRepo,
            botigaRepo,
            producteRepo,
          ),
        ),
      ],
    );
  }

  /// Genera els resultats de les consultes d'estoc.
  Widget _buildConsultesResultats(
    ComandaRepository comandaRepo,
    BotigaRepository botigaRepo,
    ProducteRepository producteRepo,
  ) {
    if (_consultaTipus == 'botiga' && _consultaBotigaId != null) {
      // Consulta per botiga: total quantitat per producte (com consultaBotigaSQL)
      final comandes = comandaRepo.getByBotigaId(_consultaBotigaId!);
      final botiga = botigaRepo.getById(_consultaBotigaId!);
      final Map<int, int> totalPerProducte = {};
      for (final c in comandes) {
        totalPerProducte[c.producteId] =
            (totalPerProducte[c.producteId] ?? 0) + c.quantitat;
      }

      if (totalPerProducte.isEmpty) {
        return Center(
          child: Text(
            'No hi ha comandes per a ${botiga?.nom ?? "aquesta botiga"}',
            style: const TextStyle(color: Colors.grey),
          ),
        );
      }

      final entries = totalPerProducte.entries.toList()
        ..sort((a, b) {
          final nomA = producteRepo.getById(a.key)?.nom ?? '';
          final nomB = producteRepo.getById(b.key)?.nom ?? '';
          return nomA.compareTo(nomB);
        });

      return SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Estoc de: ${botiga?.nom ?? ""}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  ExportButton(
                    title: 'Consulta botiga - ${botiga?.nom ?? ""}',
                    headers: const ['Producte', 'Total quantitat'],
                    rows: entries.map((e) {
                      final producte = producteRepo.getById(e.key);
                      return [
                        producte?.nom ?? 'Desconegut',
                        e.value.toString(),
                      ];
                    }).toList(),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: DataTable(
                columnSpacing: 24,
                columns: const [
                  DataColumn(label: Text('Producte')),
                  DataColumn(label: Text('Total quantitat'), numeric: true),
                ],
                rows: entries.map((e) {
                    final producte = producteRepo.getById(e.key);
                    return DataRow(cells: [
                      DataCell(Text(producte?.nom ?? 'Desconegut')),
                      DataCell(Text(
                        e.value.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: e.value < 0 ? Colors.red : Colors.green[700],
                        ),
                      )),
                    ]);
                  }).toList(),
              ),
            ),
          ],
        ),
      );
    } else if (_consultaTipus == 'producte' && _consultaProducteId != null) {
      // Consulta per producte: total quantitat per botiga, amb filtre d'estat opcional
      final totesComandes = comandaRepo.getByProducteId(_consultaProducteId!);
      final comandes = _consultaEstat != null
          ? totesComandes.where((c) => c.estat == _consultaEstat).toList()
          : totesComandes;
      final producte = producteRepo.getById(_consultaProducteId!);
      final Map<int, int> totalPerBotiga = {};
      for (final c in comandes) {
        totalPerBotiga[c.botigaId] =
            (totalPerBotiga[c.botigaId] ?? 0) + c.quantitat;
      }

      // Per 'La Musca magatzem' (ID 25) amb estat 'Tots':
      // Calcular MAGATZEM IN (del magatzem) - sumatori de TOTS els ENTREGAT (de totes les botigues)
      if (_consultaEstat == null) {
        final magatzemIn = totesComandes
            .where((c) => c.botigaId == _magatzemId && c.estat == 'MAGATZEM IN')
            .fold<int>(0, (sum, c) => sum + c.quantitat);
        final totalEntregat = totesComandes
            .where((c) => c.estat == 'ENTREGAT')
            .fold<int>(0, (sum, c) => sum + c.quantitat);
        totalPerBotiga[_magatzemId] = magatzemIn - totalEntregat;
      }

      if (totalPerBotiga.isEmpty) {
        return Center(
          child: Text(
            'No hi ha comandes per a ${producte?.nom ?? "aquest producte"}',
            style: const TextStyle(color: Colors.grey),
          ),
        );
      }

      final entries = totalPerBotiga.entries.toList()
        ..sort((a, b) {
          // Magatzem (id=25) sempre primer, després ordre alfabètic
          if (a.key == _magatzemId) return -1;
          if (b.key == _magatzemId) return 1;
          final nomA = botigaRepo.getById(a.key)?.nom ?? '';
          final nomB = botigaRepo.getById(b.key)?.nom ?? '';
          return nomA.compareTo(nomB);
        });

      return SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Estoc de: ${producte?.nom ?? ""}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  ExportButton(
                    title: 'Consulta producte - ${producte?.nom ?? ""}',
                    headers: const ['Botiga', 'Total quantitat'],
                    rows: entries.map((e) {
                      final botiga = botigaRepo.getById(e.key);
                      return [
                        botiga?.nom ?? 'Desconeguda',
                        e.value.toString(),
                      ];
                    }).toList(),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: DataTable(
                columnSpacing: 24,
                columns: const [
                  DataColumn(label: Text('Botiga')),
                  DataColumn(label: Text('Total quantitat'), numeric: true),
                ],
                rows: [
                  // Fila TOTAL sempre primera
                  DataRow(
                    color: WidgetStateProperty.all(
                      Colors.grey.withValues(alpha: 0.1),
                    ),
                    cells: [
                      const DataCell(Text(
                        'TOTAL',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                      DataCell(Text(
                        entries
                            .fold<int>(0, (sum, e) => sum + e.value)
                            .toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )),
                    ],
                  ),
                  // Magatzem (id=25) segon, després la resta alfabèticament
                  ...entries.map((e) {
                    final botiga = botigaRepo.getById(e.key);
                    return DataRow(
                      color: botiga?.id == _magatzemId
                          ? WidgetStateProperty.all(
                              Theme.of(context).colorScheme.secondaryContainer,
                            )
                          : null,
                      cells: [
                      DataCell(Text(botiga?.nom ?? 'Desconeguda')),
                      DataCell(Text(
                        e.value.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: e.value < 0 ? Colors.red : Colors.green[700],
                        ),
                      )),
                    ]);
                  }),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Estat inicial: cap filtre seleccionat
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Selecciona una botiga o un producte per consultar l\'estoc',
            style: TextStyle(color: Colors.grey, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchBotiguesController.dispose();
    _searchProductesController.dispose();
    super.dispose();
  }
}
