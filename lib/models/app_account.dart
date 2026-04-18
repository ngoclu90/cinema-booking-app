import 'profile.dart';

enum AppUserRole { staff, customer }

class AppAccount {
  final String id;
  final String email;
  final String password;
  final AppUserRole role;
  final String roleLabel;
  final String roleTitle;
  final String leftStatLabel;
  final String leftStatValue;
  final String rightStatLabel;
  final String rightStatValue;
  final ProfileUser profile;

  const AppAccount({
    required this.id,
    required this.email,
    required this.password,
    required this.role,
    required this.roleLabel,
    required this.roleTitle,
    required this.leftStatLabel,
    required this.leftStatValue,
    required this.rightStatLabel,
    required this.rightStatValue,
    required this.profile,
  });

  bool get isStaff => role == AppUserRole.staff;
}
