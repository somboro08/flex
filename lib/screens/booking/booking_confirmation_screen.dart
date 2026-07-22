import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';
import '../../models/models.dart';
import 'package:intl/intl.dart';
import '../payment/payment_bottom_sheet.dart';
import '../../services/pdf_service.dart';
import 'package:printing/printing.dart';


class BookingConfirmationScreen extends StatefulWidget {
  final Listing listing;

  const BookingConfirmationScreen({super.key, required this.listing});

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  int _guests = 1;
  bool _isProcessing = false;
  PaymentMethod? _lastPaymentMethod;
  Map<String, dynamic>? _lastPaymentDetails;

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: FlexColors.primary500,
              onPrimary: Colors.white,
              onSurface: FlexColors.neutral800,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  int get _nights {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays;
  }

  double get _totalPrice => _nights * widget.listing.prixParNuit;

  Future<void> _confirmBooking() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner les dates de séjour.')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentBottomSheet(
        amount: (_totalPrice + 500), // Total à payer
        onPaymentConfirmed: (method, details) {
          // Gérer la confirmation du paiement ici
          debugPrint('Paiement confirmé via $method avec détails: $details');
          _lastPaymentMethod = method; // Stocker la méthode
          _lastPaymentDetails = details; // Stocker les détails
          // _showSuccessDialog(); // This will be called AFTER the bottom sheet closes
        },
      ),
    );

    setState(() => _isProcessing = false);

    // Only show success dialog if payment method was selected and context is still valid
    if (_lastPaymentMethod != null && context.mounted) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FlexRadius.lg)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: FlexColors.success, size: 64),
            const SizedBox(height: FlexSpacing.md),
            const Text('Demande envoyée !', style: FlexTextStyles.h2),
            const SizedBox(height: FlexSpacing.sm),
            Text(
              'Votre demande de réservation a été envoyée à l\'hôte. Vous recevrez une notification dès qu\'elle sera acceptée.',
              textAlign: TextAlign.center,
              style: FlexTextStyles.body.copyWith(color: FlexColors.neutral500),
            ),
            const SizedBox(height: FlexSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  final pdfBytes = await PdfService().generateReceipt(
                    listingTitle: widget.listing.titre,
                    hostName: 'Nom de l\'Hôte', // Placeholder, à remplacer par le vrai nom
                    startDate: _startDate!,
                    endDate: _endDate!,
                    guests: _guests,
                    nightlyPrice: widget.listing.prixParNuit,
                    serviceFee: 500,
                    paymentMethod: _lastPaymentMethod?.name ?? 'Inconnu',
                    paymentDetails: _lastPaymentDetails ?? {},
                  );
                  await Printing.sharePdf(bytes: pdfBytes, filename: 'recu_flex_reservation.pdf');
                },
                child: const Text('Voir le reçu'),
              ),
            ),
            const SizedBox(height: FlexSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final pdfBytes = await PdfService().generateReceipt(
                    listingTitle: widget.listing.titre,
                    hostName: 'Nom de l\'Hôte', // Placeholder, à remplacer par le vrai nom
                    startDate: _startDate!,
                    endDate: _endDate!,
                    guests: _guests,
                    nightlyPrice: widget.listing.prixParNuit,
                    serviceFee: 500,
                    paymentMethod: _lastPaymentMethod?.name ?? 'Inconnu', // Utiliser la dernière méthode de paiement
                    paymentDetails: _lastPaymentDetails ?? {}, // Utiliser les derniers détails de paiement
                  );
                  await Printing.sharePdf(bytes: pdfBytes, filename: 'recu_flex_reservation.pdf');
                  if (context.mounted) {
                    Navigator.of(context).pop(); // dialog
                    Navigator.of(context).pop(); // confirmation screen
                  }
                },
                child: const Text('Télécharger le reçu'),
              ),
            ),
            const SizedBox(height: FlexSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // dialog
                  Navigator.of(context).pop(); // confirmation screen
                },
                child: const Text('Retour à l\'accueil'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('dd MMM yyyy', 'fr');

    return Scaffold(
      backgroundColor: isDark ? FlexColors.neutral900 : FlexColors.neutral50,
      appBar: AppBar(
        title: const Text('Confirmer la réservation', style: FlexTextStyles.h3),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FlexSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Listing Summary
            Container(
              padding: const EdgeInsets.all(FlexSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? FlexColors.neutral800 : Colors.white,
                borderRadius: BorderRadius.circular(FlexRadius.lg),
                border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200, width: 0.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isDark ? FlexColors.neutral700 : FlexColors.neutral100,
                      borderRadius: BorderRadius.circular(FlexRadius.md),
                    ),
                    child: const Icon(Icons.home_rounded, color: FlexColors.primary500),
                  ),
                  const SizedBox(width: FlexSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.listing.titre, style: FlexTextStyles.label.copyWith(fontWeight: FontWeight.bold)),
                        Text('${widget.listing.quartier}, ${widget.listing.ville}', style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral500)),
                        const SizedBox(height: 4),
                        Text('${widget.listing.prixParNuit.toInt()} FCFA / nuit', style: FlexTextStyles.label.copyWith(color: FlexColors.primary500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: FlexSpacing.xl),

            // Date Selection
            Text('Dates du séjour', style: FlexTextStyles.h3),
            const SizedBox(height: FlexSpacing.md),
            GestureDetector(
              onTap: () => _selectDateRange(context),
              child: Container(
                padding: const EdgeInsets.all(FlexSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? FlexColors.neutral800 : Colors.white,
                  borderRadius: BorderRadius.circular(FlexRadius.md),
                  border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 20, color: FlexColors.primary500),
                    const SizedBox(width: FlexSpacing.md),
                    Text(
                      _startDate == null 
                        ? 'Sélectionner les dates' 
                        : '${dateFormat.format(_startDate!)} — ${dateFormat.format(_endDate!)}',
                      style: FlexTextStyles.label,
                    ),
                    const Spacer(),
                    const Icon(Icons.edit_rounded, size: 16, color: FlexColors.neutral400),
                  ],
                ),
              ),
            ),

            const SizedBox(height: FlexSpacing.xl),

            // Guests Selection
            Text('Voyageurs', style: FlexTextStyles.h3),
            const SizedBox(height: FlexSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: FlexSpacing.md, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? FlexColors.neutral800 : Colors.white,
                borderRadius: BorderRadius.circular(FlexRadius.md),
                border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people_outline_rounded, size: 20, color: FlexColors.primary500),
                  const SizedBox(width: FlexSpacing.md),
                  Text('$_guests personne${_guests > 1 ? 's' : ''}', style: FlexTextStyles.label),
                  const Spacer(),
                  IconButton(
                    onPressed: _guests > 1 ? () => setState(() => _guests--) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  IconButton(
                    onPressed: _guests < 4 ? () => setState(() => _guests++) : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ),

            const SizedBox(height: FlexSpacing.xl),

            // Price Summary
            Text('Détails du prix', style: FlexTextStyles.h3),
            const SizedBox(height: FlexSpacing.md),
            _SummaryRow(
              label: '${widget.listing.prixParNuit.toInt()} FCFA x $_nights nuits',
              value: '${_totalPrice.toInt()} FCFA',
              isDark: isDark,
            ),
            _SummaryRow(
              label: 'Frais de service Flex',
              value: '500 FCFA',
              isDark: isDark,
            ),
            const Divider(height: FlexSpacing.lg),
            _SummaryRow(
              label: 'Total',
              value: '${(_totalPrice + 500).toInt()} FCFA',
              isDark: isDark,
              isTotal: true,
            ),

            const SizedBox(height: FlexSpacing.xxl),

            // Bottom Action
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_startDate != null && !_isProcessing) ? _confirmBooking : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: FlexColors.primary500,
                  foregroundColor: Colors.white,
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Confirmer la réservation', style: FlexTextStyles.button),
              ),
            ),
            const SizedBox(height: FlexSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal 
              ? FlexTextStyles.label.copyWith(fontWeight: FontWeight.bold, fontSize: 16)
              : FlexTextStyles.body.copyWith(color: FlexColors.neutral500),
          ),
          Text(
            value,
            style: isTotal
              ? FlexTextStyles.h3.copyWith(color: FlexColors.primary500, fontWeight: FontWeight.bold)
              : FlexTextStyles.label.copyWith(color: isDark ? FlexColors.neutral200 : FlexColors.neutral700),
          ),
        ],
      ),
    );
  }
}
