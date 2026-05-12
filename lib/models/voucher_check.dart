class VoucherCheckResult {
  final int discountAmount;
  final String discountType;
  final int discountValue;
  final int finalPrice;
  final String voucherCode;
  final int voucherId;

  const VoucherCheckResult({
    required this.discountAmount,
    required this.discountType,
    required this.discountValue,
    required this.finalPrice,
    required this.voucherCode,
    required this.voucherId,
  });

  factory VoucherCheckResult.fromJson(Map<String, dynamic> json) {
    return VoucherCheckResult(
      discountAmount: (json['discountAmount'] as num?)?.toInt() ?? 0,
      discountType: json['discountType']?.toString() ?? '',
      discountValue: (json['discountValue'] as num?)?.toInt() ?? 0,
      finalPrice: (json['finalPrice'] as num?)?.toInt() ?? 0,
      voucherCode: json['voucherCode']?.toString() ?? '',
      voucherId: (json['voucherId'] as num?)?.toInt() ?? 0,
    );
  }
}
