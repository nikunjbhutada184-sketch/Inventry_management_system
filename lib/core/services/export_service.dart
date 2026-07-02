import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../../features/sales/domain/models/sale.dart';
import '../../features/products/domain/models/product.dart';

class ExportService {
  static Future<void> exportSalesInvoice(Sale sale) async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(symbol: 'Rs. ');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('INVOICE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Inventory Pro'),
                      pw.Text('Demo Address'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Invoice #: ${sale.invoiceNumber ?? sale.id.substring(0, 8)}'),
                      pw.Text('Date: ${DateFormat('yyyy-MM-dd').format(sale.date)}'),
                      if (sale.customer != null) pw.Text('Customer: ${sale.customer!.name}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.TableHelper.fromTextArray(
                context: context,
                headers: ['Item', 'Qty', 'Price', 'Total'],
                data: sale.items?.map((item) => [
                      item.product?.name ?? 'Unknown',
                      item.qty.toString(),
                      currencyFormat.format(item.price),
                      currencyFormat.format(item.total),
                    ]).toList() ?? [],
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Discount: ${currencyFormat.format(sale.discount)}'),
                    pw.Text('Tax: ${currencyFormat.format(sale.tax)}'),
                    pw.Text('Grand Total: ${currencyFormat.format(sale.total)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/Invoice_${sale.invoiceNumber ?? 'Export'}.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'Invoice from Inventory Pro');
  }

  static Future<void> exportInventoryToExcel(List<Product> products) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Inventory'];
    excel.setDefaultSheet('Inventory');
    
    // Headers
    sheetObject.appendRow([
      TextCellValue('Product Name'),
      TextCellValue('SKU'),
      TextCellValue('Barcode'),
      TextCellValue('Purchase Price'),
      TextCellValue('Selling Price'),
      TextCellValue('Stock'),
      TextCellValue('Min Stock'),
    ]);

    // Data
    for (var product in products) {
      sheetObject.appendRow([
        TextCellValue(product.name),
        TextCellValue(product.sku ?? ''),
        TextCellValue(product.barcode ?? ''),
        DoubleCellValue(product.purchasePrice),
        DoubleCellValue(product.sellingPrice),
        DoubleCellValue(product.currentStock),
        DoubleCellValue(product.minStock),
      ]);
    }

    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/Inventory_Export_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx');
    final bytes = excel.save();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)], text: 'Inventory Export');
    }
  }
}
