class ProfileUser {
  final String name;
  final String email;
  final String membership;
  final String phone;
  final int points;
  final double tierProgress;
  final String favoriteGenre;
  final String memberSince;

  const ProfileUser({
    required this.name,
    required this.email,
    required this.membership,
    required this.phone,
    required this.points,
    required this.tierProgress,
    required this.favoriteGenre,
    required this.memberSince,
  });

  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      membership: json['membership']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      points: (json['points'] as num?)?.toInt() ?? 0,
      tierProgress: (json['tierProgress'] as num?)?.toDouble() ?? 0,
      favoriteGenre: json['favoriteGenre']?.toString() ?? '',
      memberSince: json['memberSince']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'membership': membership,
      'phone': phone,
      'points': points,
      'tierProgress': tierProgress,
      'favoriteGenre': favoriteGenre,
      'memberSince': memberSince,
    };
  }
}
