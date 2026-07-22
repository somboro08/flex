import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

// Define PDF colors that map to FlexColors
class PdfFlexColors {
  static const PdfColor primary500 = PdfColor.fromInt(0xFFFF6B00); // Orange
  static const PdfColor neutral0 = PdfColor.fromInt(0xFFFFFFFF); // White
  static const PdfColor neutral50 = PdfColor.fromInt(0xFFF9F7F3);
  static const PdfColor neutral100 = PdfColor.fromInt(0xFFF2F0EC);
  static const PdfColor neutral200 = PdfColor.fromInt(0xFFE6E3DF);
  static const PdfColor neutral300 = PdfColor.fromInt(0xFFD3CFCB);
  static const PdfColor neutral400 = PdfColor.fromInt(0xFFBCB9B4);
  static const PdfColor neutral500 = PdfColor.fromInt(0xFFA19E9A); // Grey
  static const PdfColor neutral600 = PdfColor.fromInt(0xFF7A7874);
  static const PdfColor neutral700 = PdfColor.fromInt(0xFF53514F);
  static const PdfColor neutral800 = PdfColor.fromInt(0xFF2C2A28);
  static const PdfColor neutral900 = PdfColor.fromInt(0xFF141312); // Black
}

class PdfService {
  late pw.Font _poppinsRegular;
  late pw.Font _poppinsBold;
  late pw.MemoryImage _appLogo;

  Future<void> _loadAssets() async {
    final fontDataRegular = await rootBundle.load("assets/fonts/Poppins-Regular.ttf");
    _poppinsRegular = pw.Font.ttf(fontDataRegular);

    final fontDataBold = await rootBundle.load("assets/fonts/Poppins-Bold.ttf");
    _poppinsBold = pw.Font.ttf(fontDataBold);

    final ByteData imageData = await rootBundle.load('assets/icons/flex.png');
    _appLogo = pw.MemoryImage(imageData.buffer.asUint8List());
  }

  Future<Uint8List> generateReceipt({
    required String listingTitle,
    required String hostName,
    required DateTime startDate,
    required DateTime endDate,
    required int guests,
    required double nightlyPrice,
    required double serviceFee,
    required String paymentMethod,
    required Map<String, dynamic> paymentDetails,
  }) async {
    await _loadAssets(); // Load assets when generating the PDF

    final pdf = pw.Document();

    final dateFormat = DateFormat('dd MMMM yyyy', 'fr');

    final int nights = endDate.difference(startDate).inDays;
    final double subtotal = nightlyPrice * nights;
    final double total = subtotal + serviceFee;

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          buildBackground: (pw.Context context) {
            return pw.FullPage(
              ignoreMargins: true,
              child: pw.Stack(
                children: [
                  pw.Opacity(
                    opacity: 0.05,
                    child: pw.Center(
                      child: pw.Image(_appLogo, width: 300, height: 300),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 20),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Reçu de Réservation',
                            style: pw.TextStyle(
                                font: _poppinsBold, fontSize: 24, color: PdfFlexColors.primary500)),
                        pw.Text('Flex',
                            style: pw.TextStyle(
                                font: _poppinsRegular, fontSize: 18, color: PdfFlexColors.neutral800)),
                      ],
                    ),
                    pw.Image(_appLogo, width: 50, height: 50),
                  ],
                ),
              ),
              pw.Divider(color: PdfFlexColors.neutral200),
              pw.SizedBox(height: 20),

              _buildInfoRow('Référence de Réservation', '#FLEX-${DateTime.now().millisecondsSinceEpoch}', _poppinsRegular, _poppinsBold),
              _buildInfoRow('Date du Reçu', dateFormat.format(DateTime.now()), _poppinsRegular, _poppinsBold),
              pw.SizedBox(height: 20),

              pw.Text('Détails du Logement',
                  style: pw.TextStyle(font: _poppinsBold, fontSize: 18, color: PdfFlexColors.neutral800)),
              pw.SizedBox(height: 10),
              _buildInfoRow('Titre', listingTitle, _poppinsRegular, _poppinsBold),
              _buildInfoRow('Hôte', hostName, _poppinsRegular, _poppinsBold),
              pw.SizedBox(height: 20),

              pw.Text('Détails du Séjour',
                  style: pw.TextStyle(font: _poppinsBold, fontSize: 18, color: PdfFlexColors.neutral800)),
              pw.SizedBox(height: 10),
              _buildInfoRow('Arrivée', dateFormat.format(startDate), _poppinsRegular, _poppinsBold, icon: '🗓️'),
              _buildInfoRow('Départ', dateFormat.format(endDate), _poppinsRegular, _poppinsBold, icon: '🗓️'),
              _buildInfoRow('Nuits', nights.toString(), _poppinsRegular, _poppinsBold, icon: '🌙'),
              _buildInfoRow('Voyageurs', guests.toString(), _poppinsRegular, _poppinsBold, icon: '👥'),
              pw.SizedBox(height: 20),

              pw.Text('Détails du Paiement',
                  style: pw.TextStyle(font: _poppinsBold, fontSize: 18, color: PdfFlexColors.neutral800)),
              pw.SizedBox(height: 10),
              _buildInfoRow('Prix par nuit', '${nightlyPrice.toInt()} FCFA', _poppinsRegular, _poppinsBold),
              _buildInfoRow('Sous-total (${nights} nuits)', '${subtotal.toInt()} FCFA', _poppinsRegular, _poppinsBold),
              _buildInfoRow('Frais de service Flex', '${serviceFee.toInt()} FCFA', _poppinsRegular, _poppinsBold),
              pw.Divider(color: PdfFlexColors.neutral200),
              _buildInfoRow('Total Payé', '${total.toInt()} FCFA', _poppinsRegular, _poppinsBold, isTotal: true, icon: '💰'),
              pw.SizedBox(height: 10),
              _buildInfoRow('Méthode de Paiement', paymentMethod, _poppinsRegular, _poppinsBold, icon: '💳'),
              if (paymentDetails.isNotEmpty)
                _buildPaymentDetails(paymentDetails, _poppinsRegular, _poppinsBold),
              pw.SizedBox(height: 40),

              pw.Center(
                child: pw.Text("Merci d'avoir choisi Flex !",
                    style: pw.TextStyle(font: _poppinsRegular, fontSize: 16, fontStyle: pw.FontStyle.italic, color: PdfFlexColors.neutral500)),
              ),
              pw.Spacer(),
              pw.Center(
                child: pw.Text('Document généré par Flex App le ${dateFormat.format(DateTime.now())}',
                    style: pw.TextStyle(font: _poppinsRegular, fontSize: 8, color: PdfFlexColors.neutral400)),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildInfoRow(String label, String value, pw.Font poppinsRegular, pw.Font poppinsBold, {bool isTotal = false, String? icon}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              if (icon != null) ...[
                pw.Text(icon, style: pw.TextStyle(font: poppinsRegular, fontSize: isTotal ? 14 : 12)),
                pw.SizedBox(width: 5),
              ],
              pw.Text(label,
                  style: pw.TextStyle(
                    font: isTotal ? poppinsBold : poppinsRegular,
                    fontSize: isTotal ? 14 : 12,
                    color: isTotal ? PdfFlexColors.neutral800 : PdfFlexColors.neutral600,
                  )),
            ],
          ),
          pw.Text(value,
              style: pw.TextStyle(
                font: poppinsBold,
                fontSize: isTotal ? 16 : 12,
                color: isTotal ? PdfFlexColors.primary500 : PdfFlexColors.neutral800,
              )),
        ],
      ),
    );
  }

  pw.Widget _buildPaymentDetails(Map<String, dynamic> details, pw.Font poppinsRegular, pw.Font poppinsBold) {
    List<pw.Widget> widgets = [];
    details.forEach((key, value) {
      String label = '';
      String formattedValue = value.toString();

      switch(key) {
        case 'phoneNumber':
          label = 'Numéro de Téléphone';
          break;
        case 'cardNumber':
          label = 'Numéro de Carte';
          formattedValue = '**** **** **** ${value.toString().substring(value.toString().length - 4)}'; // Masquer la plupart des chiffres
          break;
        case 'cardHolder':
          label = 'Titulaire de la Carte';
          break;
        case 'expiryDate':
          label = "Date d'Expiration";
          break;
        case 'cvv':
          label = 'CVV';
          formattedValue = '***'; // Masquer le CVV
          break;
        default:
          label = key;
          break;
      }
      widgets.add(_buildInfoRow(label, formattedValue, poppinsRegular, poppinsBold));
    });
    return pw.Column(children: widgets);
  }
}
