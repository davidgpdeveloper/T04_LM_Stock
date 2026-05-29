// Widget reutilitzable per seleccionar i previsualitzar imatges.
// Comprimeix a 200x200 JPEG qualitat 70 abans de codificar en base64.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatelessWidget {
  final String? currentImageBase64;
  final ValueChanged<String?> onImageChanged;
  final String label;

  const ImagePickerWidget({
    super.key,
    this.currentImageBase64,
    required this.onImageChanged,
    this.label = 'Imatge',
  });

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 200,
      maxHeight: 200,
      imageQuality: 70,
    );
    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();
    final base64String = base64Encode(bytes);

    // Validar que la imatge no sigui massa gran (max ~100KB en base64)
    if (base64String.length > 150000 && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La imatge és massa gran. Seleccioneu-ne una de més petita.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    onImageChanged(base64String);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Column(
            children: [
              // Previsualització de la imatge
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: currentImageBase64 != null &&
                          currentImageBase64!.isNotEmpty
                      ? Image.memory(
                          base64Decode(currentImageBase64!),
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.broken_image,
                            size: 48,
                            color: Colors.grey,
                          ),
                        )
                      : const Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                ),
              ),
              const SizedBox(height: 8),
              // Botons d'acció
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    onPressed: () => _pickImage(context),
                    icon: const Icon(Icons.photo_library),
                    label: Text(
                      currentImageBase64 != null ? 'Canviar' : 'Seleccionar',
                    ),
                  ),
                  if (currentImageBase64 != null) ...[
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => onImageChanged(null),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text(
                        'Eliminar',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
