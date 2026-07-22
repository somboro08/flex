import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/flex_theme.dart';
import '../../models/models.dart';
import '../payment/payment_screen.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final Listing listing;
  const BookingConfirmationScreen({super.key, required this.listing});

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  DateTime? _dateArrivee;
  DateTime? _dateDepart;
  int _nombreVoyageurs = 1;

  int get _nombreNuits {
    if (_dateArrivee == null || _dateDepart == null) return 0;
    return _dateDepart!.difference(_dateArrivee!).inDays;
  }

  double get _sousTotal => widget.listing.prixParNuit * _nombreNuits;
  double get _fraisService => _sousTotal * 0.08;
  double get _total => _sousTotal + _fraisService;

  Future<void> _pickDates() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: FlexColors.primary500),
        ),
        child: child!,
      ),
    );
    if (range != null) setState(() { _dateArrivee = range.start; _dateDepart = range.end; });
  }

  Future<Uint8List> _generatePdf() async {
    final fontRegular = await rootBundle.load("assets/fonts/Poppins-Regular.ttf");
    final fontBold = await rootBundle.load("assets/fonts/Poppins-Bold.ttf");
    final poppins = pw.Font.ttf(fontRegular);
    final poppinsBold = pw.Font.ttf(fontBold);

    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMMM yyyy', 'fr');
    final ref = 'FLEX-${DateTime.now().millisecondsSinceEpoch}';

    pdf.addPage(pw.Page(
      pageTheme: pw.PageTheme(pageFormat: PdfPageFormat.a4),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Header(level: 0, child: pw.Text('Flex', style: pw.TextStyle(font: poppinsBold, fontSize: 28, color: PdfColor.fromInt(0xFFFF6B00)))),
          pw.SizedBox(height: 8),
          pw.Text('Reçu de réservation', style: pw.TextStyle(font: poppinsBold, fontSize: 20)),
          pw.Divider(),
          pw.SizedBox(height: 16),
          pw.Text('Réf: $ref', style: pw.TextStyle(font: poppins, fontSize: 10, color: PdfColor.fromInt(0xFF9E9A92))),
          pw.SizedBox(height: 20),
          pw.Text('Logement', style: pw.TextStyle(font: poppinsBold, fontSize: 16)),
          pw.Text(widget.listing.titre, style: pw.TextStyle(font: poppins, fontSize: 12)),
          pw.Text('${widget.listing.quartier}, ${widget.listing.ville}', style: pw.TextStyle(font: poppins, fontSize: 10, color: PdfColor.fromInt(0xFF9E9A92))),
          pw.SizedBox(height: 16),
          pw.Text('Séjour', style: pw.TextStyle(font: poppinsBold, fontSize: 16)),
          pw.Text('Arrivée: ${dateFormat.format(_dateArrivee!)}', style: pw.TextStyle(font: poppins, fontSize: 12)),
          pw.Text('Départ: ${dateFormat.format(_dateDepart!)}', style: pw.TextStyle(font: poppins, fontSize: 12)),
          pw.Text('$_nombreNuits nuits · $_nombreVoyageurs voyageur(s)', style: pw.TextStyle(font: poppins, fontSize: 12)),
          pw.SizedBox(height: 16),
          pw.Text('Paiement', style: pw.TextStyle(font: poppinsBold, fontSize: 16)),
          pw.Text('Sous-total: ${_sousTotal.toInt()} FCFA', style: pw.TextStyle(font: poppins, fontSize: 12)),
          pw.Text('Frais de service: ${_fraisService.toInt()} FCFA', style: pw.TextStyle(font: poppins, fontSize: 12)),
          pw.Divider(),
          pw.Text('Total: ${_total.toInt()} FCFA', style: pw.TextStyle(font: poppinsBold, fontSize: 16, color: PdfColor.fromInt(0xFFFF6B00))),
          pw.SizedBox(height: 40),
          pw.Center(child: pw.Text('Merci d\'avoir choisi Flex !', style: pw.TextStyle(font: poppins, fontSize: 12, fontStyle: pw.FontStyle.italic))),
        ],
      ),
    ));
    return pdf.save();
  }

  Future<void> _sharePdf() async {
    final pdfBytes = await _generatePdf();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/recu-flex.pdf');
    await file.writeAsBytes(pdfBytes);
    await Share.shareXFiles([XFile(file.path)], text: 'Reçu Flex');
  }

  void _goToPayment() {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => PaymentScreen(
        booking: Booking(
          id: '', voyageurId: '', listingId: widget.listing.id,
          hoteId: widget.listing.hoteId,
          dateArrivee: _dateArrivee!, dateDepart: _dateDepart!,
          nombreNuits: _nombreNuits, montantTotal: _total,
          createdAt: DateTime.now(),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmation'),
        leading: const BackButton(),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: _sharePdf),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FlexSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(FlexSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? FlexColors.neutral800 : Colors.white,
                borderRadius: BorderRadius.circular(FlexRadius.lg),
                border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200),
              ),
              child: Column(
                children: [
                  Row(children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: FlexColors.primary100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.home_rounded, color: FlexColors.primary500),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(widget.listing.titre, style: FlexTextStyles.h3)),
                  ]),
                  const Divider(height: 24),
                  _buildDateSelector(isDark),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 18, color: FlexColors.neutral400),
                      const SizedBox(width: 8),
                      Text('Voyageurs', style: FlexTextStyles.body.copyWith(color: FlexColors.neutral500)),
                      const Spacer(),
                      _QtyBtn(label: '-', onTap: _nombreVoyageurs > 1 ? () => setState(() => _nombreVoyageurs--) : null),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('$_nombreVoyageurs', style: FlexTextStyles.h3),
                      ),
                      _QtyBtn(label: '+', onTap: _nombreVoyageurs < 10 ? () => setState(() => _nombreVoyageurs++) : null),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(FlexSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? FlexColors.neutral800 : Colors.white,
                borderRadius: BorderRadius.circular(FlexRadius.lg),
                border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200),
              ),
              child: Column(
                children: [
                  _PriceRow(label: '${widget.listing.prixParNuit.toInt()} FCFA x $_nombreNuits nuits', value: '${_sousTotal.toInt()} FCFA'),
                  const SizedBox(height: 8),
                  _PriceRow(label: 'Frais de service (8%)', value: '${_fraisService.toInt()} FCFA'),
                  const Divider(height: 16),
                  _PriceRow(label: 'Total', value: '${_total.toInt()} FCFA', isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _nombreNuits > 0 ? _goToPayment : null,
                icon: const Icon(Icons.payment_rounded),
                label: Text(_nombreNuits > 0 ? 'Payer ${_total.toInt()} FCFA' : 'Choisir les dates'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _nombreNuits > 0 ? _sharePdf : null,
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: const Text('Télécharger le reçu PDF'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(bool isDark) {
    return GestureDetector(
      onTap: _pickDates,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? FlexColors.neutral700 : FlexColors.neutral100,
          borderRadius: BorderRadius.circular(FlexRadius.md),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Arrivée', style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral400)),
                  Text(_dateArrivee != null ? DateFormat('dd/MM/yyyy').format(_dateArrivee!) : 'Choisir',
                    style: FlexTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Container(width: 0.5, height: 36, color: FlexColors.neutral400),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Départ', style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral400)),
                    Text(_dateDepart != null ? DateFormat('dd/MM/yyyy').format(_dateDepart!) : 'Choisir',
                      style: FlexTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            const Icon(Icons.calendar_today_rounded, color: FlexColors.primary500, size: 20),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label; final String value; final bool isTotal;
  const _PriceRow({required this.label, required this.value, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(
          fontFamily: 'Poppins', fontSize: isTotal ? 14 : 13,
          fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
          color: isTotal ? FlexColors.neutral800 : FlexColors.neutral500,
        )),
        Text(value, style: TextStyle(
          fontFamily: 'Poppins', fontSize: isTotal ? 16 : 13,
          fontWeight: FontWeight.w600,
          color: isTotal ? FlexColors.primary500 : FlexColors.neutral700,
        )),
      ],
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final String label; final VoidCallback? onTap;
  const _QtyBtn({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: onTap != null ? FlexColors.primary500 : FlexColors.neutral200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
      ),
    );
  }
}
