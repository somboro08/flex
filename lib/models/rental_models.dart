enum RentalPeriodStatus { active, noticeGiven, terminated, expired }
enum PaymentStatus { onTime, late, advance, unpaid, refunded }

class RentalPayment {
  final String id;
  final String rentalId;
  final String periodLabel;
  final double amount;
  final DateTime dueDate;
  final DateTime? paidAt;
  final PaymentStatus status;
  final String? transactionRef;

  const RentalPayment({
    required this.id,
    required this.rentalId,
    required this.periodLabel,
    required this.amount,
    required this.dueDate,
    this.paidAt,
    this.status = PaymentStatus.unpaid,
    this.transactionRef,
  });

  bool get isSettled => status == PaymentStatus.onTime || status == PaymentStatus.advance;
  bool get isProblem => status == PaymentStatus.late || status == PaymentStatus.unpaid;

  factory RentalPayment.fromMap(Map<String, dynamic> map) {
    return RentalPayment(
      id: map['id'] ?? '',
      rentalId: map['rentalId'] ?? '',
      periodLabel: map['periodLabel'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      dueDate: DateTime.tryParse(map['dueDate'] ?? '') ?? DateTime.now(),
      paidAt: map['paidAt'] != null ? DateTime.tryParse(map['paidAt']) : null,
      status: PaymentStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => PaymentStatus.unpaid,
      ),
      transactionRef: map['transactionRef'],
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'rentalId': rentalId,
    'periodLabel': periodLabel,
    'amount': amount,
    'dueDate': dueDate.toIso8601String(),
    'paidAt': paidAt?.toIso8601String(),
    'status': status.name,
    'transactionRef': transactionRef,
  };
}

class MonthlyRental {
  final String id;
  final String listingId;
  final String listingTitle;
  final String listingVille;
  final String listingPhoto;
  final String hoteId;
  final String hoteNom;
  final String voyageurId;
  final String voyageurNom;
  final String voyageurTelephone;
  final String voyageurPhoto;
  final DateTime startDate;
  final DateTime? endDate;
  final double monthlyRent;
  final double caution;
  final int billingDay;
  final RentalPeriodStatus periodStatus;
  final List<RentalPayment> payments;
  final DateTime createdAt;

  const MonthlyRental({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.listingVille,
    required this.listingPhoto,
    required this.hoteId,
    required this.hoteNom,
    required this.voyageurId,
    required this.voyageurNom,
    required this.voyageurTelephone,
    this.voyageurPhoto = '',
    required this.startDate,
    this.endDate,
    required this.monthlyRent,
    this.caution = 0,
    this.billingDay = 5,
    this.periodStatus = RentalPeriodStatus.active,
    this.payments = const [],
    required this.createdAt,
  });

  bool get isActive => periodStatus == RentalPeriodStatus.active || periodStatus == RentalPeriodStatus.noticeGiven;

  int get monthsSinceStart {
    final now = DateTime.now();
    return ((now.year - startDate.year) * 12 + now.month - startDate.month).clamp(0, 999);
  }

  DateTime nextPaymentDue() {
    final now = DateTime.now();
    var next = DateTime(now.year, now.month, billingDay);
    if (next.isBefore(now) || next.isSameDate(now)) {
      next = DateTime(now.year, now.month + 1, billingDay);
    }
    return next;
  }

  DateTime lastPaymentDue() {
    final now = DateTime.now();
    var last = DateTime(now.year, now.month, billingDay);
    if (last.isAfter(now) || last.isSameDate(now)) {
      last = DateTime(now.year, now.month - 1, billingDay);
    }
    return last;
  }

  DateTime get effectiveEndDate => endDate ?? DateTime(startDate.year + 10, startDate.month, startDate.day);

  double get totalDurationDays => effectiveEndDate.difference(startDate).inDays.toDouble();
  double get elapsedDays => DateTime.now().difference(startDate).inDays.toDouble().clamp(0, totalDurationDays);
  double get remainingDays => (totalDurationDays - elapsedDays).clamp(0, totalDurationDays);
  double get timeProgress => totalDurationDays > 0 ? (elapsedDays / totalDurationDays).clamp(0.0, 1.0) : 0.0;

  double get paymentCycleProgress {
    final lastDue = lastPaymentDue();
    final nextDue = nextPaymentDue();
    final cycleDays = nextDue.difference(lastDue).inDays.toDouble();
    final elapsedInCycle = DateTime.now().difference(lastDue).inDays.toDouble();
    return cycleDays > 0 ? (elapsedInCycle / cycleDays).clamp(0.0, 1.0) : 0.0;
  }

  int get daysUntilNextPayment => DateTime.now().difference(nextPaymentDue()).inDays.abs();

  int get lateDays {
    final now = DateTime.now();
    final due = DateTime(now.year, now.month, billingDay);
    if (now.isAfter(due)) return now.difference(due).inDays;
    return 0;
  }

  PaymentStatus get currentPaymentStatus {
    final currentPeriod = _periodLabelFor(DateTime.now());
    final payment = payments.where((p) => p.periodLabel == currentPeriod).firstOrNull;
    if (payment != null) return payment.status;
    if (lateDays > 0) return PaymentStatus.late;
    return PaymentStatus.unpaid;
  }

  RentalPayment? get lastPayment => payments.isNotEmpty ? payments.last : null;

  Map<String, int> get paymentStats {
    int onTime = 0, late = 0, advance = 0, unpaid = 0, refunded = 0;
    for (final p in payments) {
      switch (p.status) {
        case PaymentStatus.onTime: onTime++;
        case PaymentStatus.late: late++;
        case PaymentStatus.advance: advance++;
        case PaymentStatus.unpaid: unpaid++;
        case PaymentStatus.refunded: refunded++;
      }
    }
    return {'onTime': onTime, 'late': late, 'advance': advance, 'unpaid': unpaid, 'refunded': refunded, 'total': payments.length};
  }

  String _periodLabelFor(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}';

  factory MonthlyRental.fromMap(Map<String, dynamic> map) {
    return MonthlyRental(
      id: map['id'] ?? '',
      listingId: map['listingId'] ?? '',
      listingTitle: map['listingTitle'] ?? '',
      listingVille: map['listingVille'] ?? '',
      listingPhoto: map['listingPhoto'] ?? '',
      hoteId: map['hoteId'] ?? '',
      hoteNom: map['hoteNom'] ?? '',
      voyageurId: map['voyageurId'] ?? '',
      voyageurNom: map['voyageurNom'] ?? '',
      voyageurTelephone: map['voyageurTelephone'] ?? '',
      voyageurPhoto: map['voyageurPhoto'],
      startDate: DateTime.tryParse(map['startDate'] ?? '') ?? DateTime.now(),
      endDate: map['endDate'] != null ? DateTime.tryParse(map['endDate']) : null,
      monthlyRent: (map['monthlyRent'] ?? 0).toDouble(),
      caution: (map['caution'] ?? 0).toDouble(),
      billingDay: map['billingDay'] ?? 5,
      periodStatus: RentalPeriodStatus.values.firstWhere(
        (s) => s.name == map['periodStatus'],
        orElse: () => RentalPeriodStatus.active,
      ),
      payments: (map['payments'] as List<dynamic>?)?.map((e) => RentalPayment.fromMap(e)).toList() ?? [],
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'listingId': listingId,
    'listingTitle': listingTitle,
    'listingVille': listingVille,
    'listingPhoto': listingPhoto,
    'hoteId': hoteId,
    'hoteNom': hoteNom,
    'voyageurId': voyageurId,
    'voyageurNom': voyageurNom,
    'voyageurTelephone': voyageurTelephone,
    'voyageurPhoto': voyageurPhoto,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'monthlyRent': monthlyRent,
    'caution': caution,
    'billingDay': billingDay,
    'periodStatus': periodStatus.name,
    'payments': payments.map((p) => p.toMap()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };
}

extension _DateCompare on DateTime {
  bool isSameDate(DateTime other) => year == other.year && month == other.month && day == other.day;
}
