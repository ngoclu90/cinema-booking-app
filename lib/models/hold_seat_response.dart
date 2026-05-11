class HoldSeatResponse {
  final bool success;
  final String message;
  final DateTime? expiresAt;
  final List<int> failedSeatIds;
  final List<int> heldSeatIds;
  final String? holdToken;

  const HoldSeatResponse({
    required this.success,
    required this.message,
    required this.expiresAt,
    required this.failedSeatIds,
    required this.heldSeatIds,
    required this.holdToken,
  });

  factory HoldSeatResponse.fromJson(Map<String, dynamic> json) {
    return HoldSeatResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())
          : null,
      failedSeatIds: (json['failedSeatIds'] as List<dynamic>? ?? const [])
          .map((item) => (item as num).toInt())
          .toList(growable: false),
      heldSeatIds: (json['heldSeatIds'] as List<dynamic>? ?? const [])
          .map((item) => (item as num).toInt())
          .toList(growable: false),
      holdToken: json['holdToken']?.toString(),
    );
  }
}
