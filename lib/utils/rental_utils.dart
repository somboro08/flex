import 'package:flutter/material.dart';
import '../models/rental_models.dart';

class RentalUtils {
  static String paymentStatusLabel(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.onTime: return 'À temps';
      case PaymentStatus.late: return 'En retard';
      case PaymentStatus.advance: return 'En avance';
      case PaymentStatus.unpaid: return 'Impayé';
      case PaymentStatus.refunded: return 'Remboursé';
    }
  }

  static Color paymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.onTime: return const Color(0xFF10B981);
      case PaymentStatus.late: return const Color(0xFFF59E0B);
      case PaymentStatus.advance: return const Color(0xFF3B82F6);
      case PaymentStatus.unpaid: return const Color(0xFFEF4444);
      case PaymentStatus.refunded: return const Color(0xFF8B5CF6);
    }
  }

  static String formatFCFA(double amount) {
    final parts = amount.toStringAsFixed(0).split('');
    final buffer = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(parts[i]);
    }
    return '${buffer.toString()} FCFA';
  }

  static String daysLabel(int days) {
    if (days <= 0) return 'Aujourd\'hui';
    if (days == 1) return '1 jour';
    if (days < 30) return '$days jours';
    final months = days ~/ 30;
    final remaining = days % 30;
    if (remaining == 0) return '$months mois';
    return '$months mois $remaining jours';
  }

  static String monthLabel(int year, int month) {
    const months = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
                    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
    return '${months[month - 1]} $year';
  }

  static Map<String, int> globalPaymentStats(List<MonthlyRental> rentals) {
    int onTime = 0, late = 0, advance = 0, unpaid = 0, active = 0;
    for (final r in rentals) {
      if (r.isActive) active++;
      final stats = r.paymentStats;
      onTime += stats['onTime'] ?? 0;
      late += stats['late'] ?? 0;
      advance += stats['advance'] ?? 0;
      unpaid += stats['unpaid'] ?? 0;
    }
    return {'onTime': onTime, 'late': late, 'advance': advance, 'unpaid': unpaid, 'active': active};
  }

  static int tenantCount(List<MonthlyRental> rentals) =>
      rentals.where((r) => r.isActive).length;

  static double totalMonthlyRevenue(List<MonthlyRental> rentals) =>
      rentals.where((r) => r.isActive).fold(0.0, (sum, r) => sum + r.monthlyRent);
}

class GeometricBackgroundPainter extends CustomPainter {
  final Color color;
  final double opacity;

  GeometricBackgroundPainter({required this.color, this.opacity = 0.06});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.lineTo(size.width * 0.3, size.height * 0.3);
    path.lineTo(size.width * 1.2, size.height * 0.5);
    path.lineTo(size.width * 0.8, size.height * 1.1);
    path.close();
    canvas.drawPath(path, paint);

    final path2 = Path();
    paint.color = color.withValues(alpha: opacity * 0.6);
    path2.moveTo(size.width * -0.2, size.height * 0.2);
    path2.lineTo(size.width * 0.5, 0);
    path2.lineTo(size.width * 0.9, size.height * 0.3);
    path2.lineTo(size.width * 0.3, size.height * 0.6);
    path2.close();
    canvas.drawPath(path2, paint);

    final path3 = Path();
    paint.color = color.withValues(alpha: opacity * 0.3);
    path3.addOval(Rect.fromCircle(center: Offset(size.width * 0.85, size.height * 0.15), radius: 60));
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
