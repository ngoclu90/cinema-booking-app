class ProfileUser {
  final int id;
  final String name;
  final String email;
  final String phone;
  final int roleId;
  final int? cinemaId;
  final String? position;
  final bool isActive;
  final String? avatarUrl;
  
  // Các trường bổ sung cho UI
  final String membership;
  final int points;
  final String memberSince;

  const ProfileUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.roleId,
    this.cinemaId,
    this.position,
    required this.isActive,
    this.avatarUrl,
    this.membership = 'Thành viên',
    this.points = 0,
    this.memberSince = '2024',
  });

  factory ProfileUser.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ProfileUser.empty();
    
    return ProfileUser(
      id: json['id'] as int? ?? 0,
      name: (json['fullName'] ?? json['name'] ?? 'Người dùng').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      roleId: json['roleId'] as int? ?? 0,
      cinemaId: json['cinemaId'] as int?,
      position: json['position']?.toString(),
      // Backend có thể trả về isActive kiểu int (1/0) hoặc bool
      isActive: json['isActive'] == 1 || json['isActive'] == true,
      avatarUrl: json['avatarUrl']?.toString(),
      // roleName từ UserDTO hoặc position từ UserResponseDTO
      membership: (json['roleName'] ?? json['position'] ?? 'Thành viên').toString(),
      // createdAt từ UserDTO
      memberSince: (json['createdAt'] ?? '2024').toString(),
      points: (json['points'] as num?)?.toInt() ?? 0,
    );
  }

  static ProfileUser empty() => const ProfileUser(
    id: 0,
    name: 'Người dùng',
    email: '',
    phone: '',
    roleId: 0,
    isActive: false,
  );

  Map<String, dynamic> toJson() {
    return {
      'fullName': name,
      'email': email,
      'phone': phone,
    };
  }
}
