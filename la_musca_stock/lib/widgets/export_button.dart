import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:csv/csv.dart';

/// Widget reutilitzable per exportar dades en PDF, CSV o imprimir.
class ExportButton extends StatelessWidget {
  final String title;
  final List<String> headers;
  final List<List<String>> rows;

  const ExportButton({
    super.key,
    required this.title,
    required this.headers,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.download),
      tooltip: 'Exportar / Imprimir',
      onSelected: (value) {
        switch (value) {
          case 'copy':
            _copyToClipboard(context);
            break;
          case 'print':
            _printPdf();
            break;
          case 'pdf':
            _downloadPdf();
            break;
          case 'csv':
            _downloadCsv();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'copy',
          child: ListTile(
            leading: Icon(Icons.copy),
            title: Text('Copiar al porta-retalls'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'print',
          child: ListTile(
            leading: Icon(Icons.print),
            title: Text('Imprimir'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'pdf',
          child: ListTile(
            leading: Icon(Icons.picture_as_pdf),
            title: Text('Exportar a PDF'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'csv',
          child: ListTile(
            leading: Icon(Icons.table_chart),
            title: Text('Exportar a CSV (Excel)'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  /// Copia les dades al porta-retalls en format tabulat.
  void _copyToClipboard(BuildContext context) {
    final buffer = StringBuffer();
    buffer.writeln(headers.join('\t'));
    for (final row in rows) {
      buffer.writeln(row.join('\t'));
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${rows.length} registres copiats al porta-retalls'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Genera el document PDF amb les dades.
  pw.Document _buildPdfDocument() {
    final pdf = pw.Document();

    // Dividir files en pàgines de 30 registres
    const rowsPerPage = 30;
    for (var i = 0; i < rows.length; i += rowsPerPage) {
      final pageRows = rows.sublist(
        i,
        i + rowsPerPage > rows.length ? rows.length : i + rowsPerPage,
      );

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Data: ${DateTime.now().day.toString().padLeft(2, '0')}/'
                  '${DateTime.now().month.toString().padLeft(2, '0')}/'
                  '${DateTime.now().year} — '
                  '${rows.length} registres',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 12),
                pw.TableHelper.fromTextArray(
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 9,
                  ),
                  cellStyle: const pw.TextStyle(fontSize: 8),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  cellAlignments: {
                    for (var j = 0; j < headers.length; j++)
                      j: j == 0
                          ? pw.Alignment.centerLeft
                          : pw.Alignment.centerLeft,
                  },
                  headers: headers,
                  data: pageRows,
                ),
              ],
            );
          },
        ),
      );
    }

    return pdf;
  }

  /// Imprimeix el document PDF.
  Future<void> _printPdf() async {
    final pdf = _buildPdfDocument();
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: title,
    );
  }

  /// Descarrega el document PDF.
  Future<void> _downloadPdf() async {
    final pdf = _buildPdfDocument();
    final bytes = await pdf.save();
    _downloadBytes(bytes, '${_sanitizeFilename(title)}.pdf', 'application/pdf');
  }

  /// Descarrega les dades en format CSV.
  void _downloadCsv() {
    final csvData = [headers, ...rows];
    final csvString = const ListToCsvConverter().convert(csvData);
    final bytes = utf8.encode(csvString);
    _downloadBytes(
      bytes,
      '${_sanitizeFilename(title)}.csv',
      'text/csv;charset=utf-8',
    );
  }

  /// Descarrega bytes com a fitxer al navegador.
  void _downloadBytes(List<int> bytes, String filename, String mimeType) {
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  /// Neteja el nom del fitxer per evitar caràcters no vàlids.
  String _sanitizeFilename(String name) {
    return name
        .replaceAll(RegExp(r'[^\w\s\-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }
}
