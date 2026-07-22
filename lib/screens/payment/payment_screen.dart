import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';
import '../../models/models.dart';

class PaymentScreen extends StatefulWidget {
  final Booking? booking;
  const PaymentScreen({super.key, this.booking});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod? _selected;
  bool _isProcessing = false;

  final List<_PaymentOption> _options = [
    _PaymentOption(
      method: PaymentMethod.mtnMomo,
      label: 'MTN Mobile Money',
      subtitle: 'Paiement instantané via MTN MoMo',
      color: Color(0xFFFFCC00),
      bgColor: Color(0xFFFFFDE7),
      icon: Icons.phone_android_rounded,
    ),
    _PaymentOption(
      method: PaymentMethod.moovMoney,
      label: 'Moov Money',
      subtitle: 'Paiement sécurisé via Moov Money',
      color: Color(0xFF0066CC),
      bgColor: Color(0xFFE3F2FD),
      icon: Icons.phone_android_rounded,
    ),
    _PaymentOption(
      method: PaymentMethod.wave,
      label: 'Wave',
      subtitle: 'Transfert rapide et sans frais',
      color: Color(0xFF1BA8E0),
      bgColor: Color(0xFFE0F7FA),
      icon: Icons.waves_rounded,
    ),
    _PaymentOption(
      method: PaymentMethod.cash,
      label: 'Payer sur place',
      subtitle: 'Règlement en espèces à l\'arrivée',
      color: FlexColors.neutral600,
      bgColor: FlexColors.neutral100,
      icon: Icons.payments_rounded,
    ),
  ];

  Future<void> _pay() async {
    if (_selected == null) return;
    setState(() => _isProcessing = true);
    // TODO: CinetPay / FedaPay integration
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isProcessing = false);
    if (mounted) {
      _showSuccess();
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FlexRadius.xl)),
        child: Padding(
          padding: const EdgeInsets.all(FlexSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: FlexColors.certified.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: FlexColors.certified, size: 48),
              ),
              const SizedBox(height: FlexSpacing.md),
              Text('Réservation confirmée !', style: FlexTextStyles.h2),
              const SizedBox(height: 8),
              Text(
                'Votre réservation a été confirmée. L\'hôte vous contactera prochainement.',
                style: FlexTextStyles.body.copyWith(color: FlexColors.neutral500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: FlexSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
                  },
                  child: const Text('Voir mes réservations'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement'),
        leading: const BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(FlexSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary card
            Container(
              padding: const EdgeInsets.all(FlexSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? FlexColors.neutral800 : FlexColors.neutral0,
                borderRadius: BorderRadius.circular(FlexRadius.lg),
                border: Border.all(
                  color: isDark ? FlexColors.neutral700 : FlexColors.neutral200,
                  width: 0.5,
                ),
              ),
              child: Column(
                children: [
                  _SummaryRow(label: 'Logement', value: 'Chambre chez Madame Akobi'),
                  const SizedBox(height: 8),
                  _SummaryRow(label: 'Dates', value: '15 avr → 17 avr (2 nuits)'),
                  const Divider(height: 24),
                  _SummaryRow(
                    label: 'Total',
                    value: '10 000 FCFA',
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: FlexSpacing.lg),

            Text(
              'Mode de paiement',
              style: FlexTextStyles.h3.copyWith(
                color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
              ),
            ),
            const SizedBox(height: FlexSpacing.md),

            // Payment options
            Expanded(
              child: ListView.separated(
                itemCount: _options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final opt = _options[i];
                  final isSelected = _selected == opt.method;
                  return GestureDetector(
                    onTap: () => setState(() => _selected = opt.method),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(FlexSpacing.md),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? opt.color.withOpacity(0.08)
                            : isDark ? FlexColors.neutral800 : FlexColors.neutral0,
                        borderRadius: BorderRadius.circular(FlexRadius.lg),
                        border: Border.all(
                          color: isSelected ? opt.color : isDark ? FlexColors.neutral700 : FlexColors.neutral200,
                          width: isSelected ? 2 : 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isDark ? opt.color.withOpacity(0.15) : opt.bgColor,
                              borderRadius: BorderRadius.circular(FlexRadius.md),
                            ),
                            child: Icon(opt.icon, color: opt.color),
                          ),
                          const SizedBox(width: FlexSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  opt.label,
                                  style: FlexTextStyles.label.copyWith(
                                    color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  opt.subtitle,
                                  style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral500),
                                ),
                              ],
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? opt.color : FlexColors.neutral300,
                                width: 2,
                              ),
                              color: isSelected ? opt.color : Colors.transparent,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, size: 14, color: Colors.white)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: FlexSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selected != null && !_isProcessing ? _pay : null,
                child: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Confirmer le paiement'),
              ),
            ),
            const SizedBox(height: FlexSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  const _SummaryRow({required this.label, required this.value, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: FlexTextStyles.body.copyWith(color: FlexColors.neutral500)),
        Text(
          value,
          style: isTotal
              ? FlexTextStyles.h3.copyWith(color: FlexColors.primary500)
              : FlexTextStyles.label.copyWith(
                  color: isDark ? FlexColors.neutral0 : FlexColors.neutral700,
                ),
        ),
      ],
    );
  }
}

class _PaymentOption {
  final PaymentMethod method;
  final String label;
  final String subtitle;
  final Color color;
  final Color bgColor;
  final IconData icon;

  _PaymentOption({
    required this.method,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.bgColor,
    required this.icon,
  });
}
