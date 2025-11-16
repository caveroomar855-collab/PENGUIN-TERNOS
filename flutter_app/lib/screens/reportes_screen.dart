import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../providers/alquileres_provider.dart';
import '../providers/ventas_provider.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({Key? key}) : super(key: key);

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  DateTime _fechaInicio = DateTime.now().subtract(const Duration(days: 30));
  DateTime _fechaFin = DateTime.now();
  final _dateFormat = DateFormat('dd/MM/yyyy');
  final _currencyFormat =
      NumberFormat.currency(symbol: 'S/ ', decimalDigits: 2);

  Future<void> _seleccionarFecha(bool esInicio) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: esInicio ? _fechaInicio : _fechaFin,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (fecha != null) {
      setState(() {
        if (esInicio) {
          _fechaInicio = fecha;
        } else {
          _fechaFin = fecha;
        }
      });
    }
  }

  Future<void> _generarPDFAlquileres() async {
    try {
      final alquileresProvider = context.read<AlquileresProvider>();
      await alquileresProvider.loadAlquileres();
      final alquileres = alquileresProvider.alquileres.where((a) {
        return a.fechaAlquiler
                .isAfter(_fechaInicio.subtract(const Duration(days: 1))) &&
            a.fechaAlquiler.isBefore(_fechaFin.add(const Duration(days: 1)));
      }).toList();

      if (alquileres.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No hay alquileres en este rango de fechas')),
          );
        }
        return;
      }

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            // Encabezado
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'PENGUIN TERNOS',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Reporte de Alquileres',
                    style: pw.TextStyle(fontSize: 18),
                  ),
                  pw.Text(
                    'Período: ${_dateFormat.format(_fechaInicio)} - ${_dateFormat.format(_fechaFin)}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            // Tabla de alquileres
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.5),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(1.5),
                4: const pw.FlexColumnWidth(1),
              },
              children: [
                // Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    _buildTableCell('DNI', isHeader: true),
                    _buildTableCell('Cliente', isHeader: true),
                    _buildTableCell('F. Alquiler', isHeader: true),
                    _buildTableCell('F. Devolución', isHeader: true),
                    _buildTableCell('Monto', isHeader: true),
                  ],
                ),
                // Datos
                ...alquileres.map((alquiler) {
                  return pw.TableRow(
                    children: [
                      _buildTableCell(alquiler.cliente?.dni ?? 'N/A'),
                      _buildTableCell(
                          alquiler.cliente?.nombreCompleto ?? 'N/A'),
                      _buildTableCell(
                          _dateFormat.format(alquiler.fechaAlquiler)),
                      _buildTableCell(
                          _dateFormat.format(alquiler.fechaDevolucion)),
                      _buildTableCell(
                          _currencyFormat.format(alquiler.montoAlquiler)),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 20),
            // Resumen
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'RESUMEN',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total de Alquileres:',
                          style: const pw.TextStyle(fontSize: 14)),
                      pw.Text(
                        '${alquileres.length}',
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Ingresos Totales:',
                          style: const pw.TextStyle(fontSize: 14)),
                      pw.Text(
                        _currencyFormat.format(
                          alquileres.fold<double>(
                              0, (sum, a) => sum + a.montoAlquiler),
                        ),
                        style: pw.TextStyle(
                            fontSize: 16, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            // Pie de página
            pw.Footer(
              title: pw.Text(
                'Generado el ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generarPDFVentas() async {
    try {
      final ventasProvider = context.read<VentasProvider>();
      await ventasProvider.loadVentas();
      final ventas = ventasProvider.ventas.where((v) {
        return v.fechaVenta
                .isAfter(_fechaInicio.subtract(const Duration(days: 1))) &&
            v.fechaVenta.isBefore(_fechaFin.add(const Duration(days: 1)));
      }).toList();

      if (ventas.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No hay ventas en este rango de fechas')),
          );
        }
        return;
      }

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            // Encabezado
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'PENGUIN TERNOS',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Reporte de Ventas',
                    style: pw.TextStyle(fontSize: 18),
                  ),
                  pw.Text(
                    'Período: ${_dateFormat.format(_fechaInicio)} - ${_dateFormat.format(_fechaFin)}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            // Tabla de ventas
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.5),
                1: const pw.FlexColumnWidth(2.5),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(1.5),
                4: const pw.FlexColumnWidth(1),
              },
              children: [
                // Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    _buildTableCell('DNI', isHeader: true),
                    _buildTableCell('Cliente', isHeader: true),
                    _buildTableCell('Teléfono', isHeader: true),
                    _buildTableCell('Fecha', isHeader: true),
                    _buildTableCell('Monto', isHeader: true),
                  ],
                ),
                // Datos
                ...ventas.map((venta) {
                  return pw.TableRow(
                    children: [
                      _buildTableCell(venta.cliente?.dni ?? 'N/A'),
                      _buildTableCell(venta.cliente?.nombreCompleto ?? 'N/A'),
                      _buildTableCell(venta.cliente?.telefono ?? 'N/A'),
                      _buildTableCell(_dateFormat.format(venta.fechaVenta)),
                      _buildTableCell(_currencyFormat.format(venta.montoTotal)),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 20),
            // Resumen
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'RESUMEN',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total de Ventas:',
                          style: const pw.TextStyle(fontSize: 14)),
                      pw.Text(
                        '${ventas.length}',
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Ingresos Totales:',
                          style: const pw.TextStyle(fontSize: 14)),
                      pw.Text(
                        _currencyFormat.format(
                          ventas.fold<double>(
                              0, (sum, v) => sum + v.montoTotal),
                        ),
                        style: pw.TextStyle(
                            fontSize: 16, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            // Pie de página
            pw.Footer(
              title: pw.Text(
                'Generado el ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Selector de rango de fechas
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rango de Fechas',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _seleccionarFecha(true),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Fecha Inicio',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(_dateFormat.format(_fechaInicio)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _seleccionarFecha(false),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Fecha Fin',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(_dateFormat.format(_fechaFin)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Botón para reporte de alquileres
          Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.card_travel,
                    color: Colors.blue.shade700, size: 32),
              ),
              title: const Text(
                'Reporte de Alquileres',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: const Text(
                  'Generar PDF con los alquileres del período seleccionado'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _generarPDFAlquileres,
            ),
          ),
          const SizedBox(height: 12),
          // Botón para reporte de ventas
          Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.shopping_bag,
                    color: Colors.green.shade700, size: 32),
              ),
              title: const Text(
                'Reporte de Ventas',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: const Text(
                  'Generar PDF con las ventas del período seleccionado'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _generarPDFVentas,
            ),
          ),
          const SizedBox(height: 24),
          // Información adicional
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Los reportes incluyen DNI, nombre, teléfono del cliente y montos totales.',
                    style: TextStyle(fontSize: 13, color: Colors.blue.shade900),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
