import 'package:flutter/material.dart';

/// Widget desplegable amb cercador integrat.
/// Si el nombre d'elements és <= [searchThreshold], mostra un DropdownButtonFormField normal.
/// Si supera el llindar, mostra un camp de text que obre un diàleg amb cercador en temps real.
class SearchableDropdown<T> extends StatelessWidget {
  final T? value;
  final List<SearchableDropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final InputDecoration? decoration;
  final String? Function(T?)? validator;
  final bool isExpanded;
  final int searchThreshold;
  final String searchHint;
  final Key? fieldKey;

  const SearchableDropdown({
    super.key,
    this.fieldKey,
    required this.items,
    this.value,
    this.onChanged,
    this.decoration,
    this.validator,
    this.isExpanded = true,
    this.searchThreshold = 20,
    this.searchHint = 'Cercar...',
  });

  @override
  Widget build(BuildContext context) {
    if (items.length <= searchThreshold) {
      return DropdownButtonFormField<T>(
        key: fieldKey,
        value: value,
        isExpanded: isExpanded,
        decoration: decoration ?? const InputDecoration(),
        items: items
            .map((item) => DropdownMenuItem<T>(
                  value: item.value,
                  child: Text(
                    item.label,
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
            .toList(),
        onChanged: onChanged,
        validator: validator,
      );
    }

    // Mode amb cercador: camp de text que obre un diàleg
    final selectedItem = items.where((i) => i.value == value).firstOrNull;
    return TextFormField(
      key: fieldKey,
      readOnly: true,
      controller: TextEditingController(text: selectedItem?.label ?? ''),
      decoration: (decoration ?? const InputDecoration()).copyWith(
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value != null)
              IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () => onChanged?.call(null),
                tooltip: 'Esborrar selecció',
              ),
            const Icon(Icons.arrow_drop_down),
            const SizedBox(width: 8),
          ],
        ),
      ),
      onTap: () async {
        final result = await showDialog<T>(
          context: context,
          builder: (context) => _SearchDialog<T>(
            items: items,
            currentValue: value,
            searchHint: searchHint,
            title: decoration?.labelText ?? '',
          ),
        );
        if (result != null) {
          onChanged?.call(result);
        }
      },
      validator: validator != null ? (_) => validator!(value) : null,
    );
  }
}

class SearchableDropdownItem<T> {
  final T value;
  final String label;

  const SearchableDropdownItem({
    required this.value,
    required this.label,
  });
}

class _SearchDialog<T> extends StatefulWidget {
  final List<SearchableDropdownItem<T>> items;
  final T? currentValue;
  final String searchHint;
  final String title;

  const _SearchDialog({
    required this.items,
    this.currentValue,
    required this.searchHint,
    required this.title,
  });

  @override
  State<_SearchDialog<T>> createState() => _SearchDialogState<T>();
}

class _SearchDialogState<T> extends State<_SearchDialog<T>> {
  late TextEditingController _searchController;
  late List<SearchableDropdownItem<T>> _filteredItems;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredItems = widget.items
            .where((item) => item.label.toLowerCase().contains(lowerQuery))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.title.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  isDense: true,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _filterItems('');
                          },
                        )
                      : null,
                ),
                onChanged: _filterItems,
              ),
              const SizedBox(height: 8),
              Flexible(
                child: _filteredItems.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Cap resultat trobat',
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
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          final isSelected = item.value == widget.currentValue;
                          return ListTile(
                            title: Text(item.label),
                            selected: isSelected,
                            dense: true,
                            leading: isSelected
                                ? const Icon(Icons.check, size: 18)
                                : null,
                            onTap: () => Navigator.of(context).pop(item.value),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
