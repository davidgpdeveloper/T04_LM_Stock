import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/comanda.dart';
import '../repositories/botiga_repository.dart';
import '../repositories/producte_repository.dart';
import '../repositories/comanda_repository.dart';
import '../widgets/delete_confirmation_dialog.dart';
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
  String? _filtreAlbara;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
              ],
            )
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: _dataLoaded
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
    if (_filtreAlbara != null && _filtreAlbara!.isNotEmpty) {
      comandes = comandes
          .where(
            (c) => c.albara.toLowerCase().contains(_filtreAlbara!.toLowerCase()),
          )
          .toList();
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
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<int?>(
                    initialValue: _filtreBotigaId,
                    isExpanded: true,
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
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Totes les botigues'),
                      ),
                      ...botigaRepo.botigues.map(
                        (b) => DropdownMenuItem<int?>(
                          value: b.id,
                          child: Text(
                            b.nom,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filtreBotigaId = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<int?>(
                    initialValue: _filtreProducteId,
                    isExpanded: true,
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
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Tots els productes'),
                      ),
                      ...producteRepo.productes.map(
                        (p) => DropdownMenuItem<int?>(
                          value: p.id,
                          child: Text(
                            p.nom,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filtreProducteId = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Albarà',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      prefixIcon: Icon(Icons.search, size: 20),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _filtreAlbara = value.isEmpty ? null : value;
                      });
                    },
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _filtreBotigaId = null;
                      _filtreProducteId = null;
                      _filtreAlbara = null;
                    });
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Netejar filtres'),
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
                      child: ListTile(
                        leading: _buildEstatIcon(comanda.estat),
                        title: Text(
                          '${comanda.albara} — ${botiga?.nom ?? "Desconeguda"}',
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
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
    }
    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.15),
      child: Icon(icon, color: color, size: 20),
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
    final botigues = botigaRepo.botigues.toList()
      ..sort((a, b) => a.nom.compareTo(b.nom));

    return botigues.isEmpty
        ? const Center(
            child: Text(
              'No hi ha botigues',
              style: TextStyle(color: Colors.grey),
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
                child: ExpansionTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.store),
                  ),
                  title: Text(botiga.nom),
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
                          if (botiga.nomComplet.isNotEmpty)
                            _detailRow('Nom complet', botiga.nomComplet),
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
    final productes = producteRepo.productes.toList()
      ..sort((a, b) => a.nom.compareTo(b.nom));

    return productes.isEmpty
        ? const Center(
            child: Text(
              'No hi ha productes',
              style: TextStyle(color: Colors.grey),
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
                    child: const Icon(Icons.inventory),
                  ),
                  title: Text(producte.nom),
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
