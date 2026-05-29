import 'package:flutter/material.dart';

class DeleteConfirmationDialog extends StatefulWidget {
  final String entityName;

  const DeleteConfirmationDialog({super.key, required this.entityName});

  static Future<bool> show(BuildContext context, String entityName) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DeleteConfirmationDialog(entityName: entityName),
    );
    return result ?? false;
  }

  @override
  State<DeleteConfirmationDialog> createState() =>
      _DeleteConfirmationDialogState();
}

class _DeleteConfirmationDialogState extends State<DeleteConfirmationDialog> {
  final _codeController = TextEditingController();
  bool _isCodeCorrect = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
          const SizedBox(width: 8),
          const Text('Atenció!'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Esteu a punt d'eliminar ${widget.entityName}."),
          const SizedBox(height: 8),
          const Text(
            'Aquesta acció no es pot desfer.',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 16),
          const Text('Per confirmar, introduïu el codi: 1234'),
          const SizedBox(height: 8),
          TextField(
            controller: _codeController,
            decoration: const InputDecoration(
              labelText: 'Codi de confirmació',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock_outline),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _isCodeCorrect = value.trim() == '1234';
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel·lar"),
        ),
        FilledButton(
          onPressed: _isCodeCorrect ? () => Navigator.pop(context, true) : null,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text("Confirmar eliminació"),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
