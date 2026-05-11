import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api/services/user_api.dart';
import '../core/api_client.dart';
import '../components/ui/index.dart';
import '../design_system/tokens/index.dart';
import '../models/profile.dart';
import '../utils/app_notifier.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileUser profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  final _userApi = UserApi();
  final _picker = ImagePicker();
  
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _avatarUrl = widget.profile.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Hàm helper để lấy URL ảnh đầy đủ
  String? _getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    return '${ApiClient.imgBaseUrl}$path';
  }

  void _handlePickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() => _isUploadingAvatar = true);

      // Gọi API POST /api/users/me/avatar
      final response = await _userApi.updateAvatar(image.path);

      if (mounted) {
        setState(() {
          _avatarUrl = response.data; // URL trả về từ BE (thường là đường dẫn tương đối)
          _isUploadingAvatar = false;
        });
        AppNotifier.success(context, title: 'Thành công', description: 'Đã cập nhật ảnh đại diện');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
        AppNotifier.error(context, title: 'Lỗi', description: 'Không thể tải ảnh lên máy chủ.');
      }
    }
  }

  void _handleSave() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      AppNotifier.warning(context, title: 'Thiếu thông tin', description: 'Vui lòng nhập họ và tên.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _userApi.updateProfile(fullName: name, phone: phone);
      if (mounted) {
        AppNotifier.success(context, title: 'Thành công', description: 'Thông tin cá nhân đã được cập nhật.');
        Navigator.pop(context, true); // Trả về true để màn hình hồ sơ reload
      }
    } catch (e) {
      if (mounted) {
        AppNotifier.error(context, title: 'Lỗi', description: 'Không thể lưu thay đổi.');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayAvatar = _getFullImageUrl(_avatarUrl);

    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin cá nhân')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Avatar Section
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.brandPrimarySoft,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.brandPrimary, width: 2),
                      image: displayAvatar != null && !_isUploadingAvatar
                          ? DecorationImage(
                              image: NetworkImage(displayAvatar),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _isUploadingAvatar 
                      ? const Center(child: CircularProgressIndicator(strokeWidth: 3))
                      : (displayAvatar == null
                          ? Center(
                              child: Text(
                                widget.profile.name.isEmpty ? 'U' : widget.profile.name[0].toUpperCase(),
                                style: AppTypography.display.copyWith(
                                  color: AppColors.brandPrimary,
                                  fontSize: 40,
                                ),
                              ),
                            )
                          : null),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.brandPrimary,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        onPressed: _isUploadingAvatar ? null : _handlePickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            
            _buildField(
              label: 'Họ và tên',
              controller: _nameController,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: AppSpacing.lg),
            
            _buildField(
              label: 'Email',
              controller: TextEditingController(text: widget.profile.email),
              icon: Icons.email_outlined,
              enabled: false,
            ),
            const SizedBox(height: AppSpacing.lg),
            
            _buildField(
              label: 'Số điện thoại',
              controller: _phoneController,
              icon: Icons.phone_android,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.huge),
            
            AppButton(
              title: 'Lưu thay đổi',
              loading: _isSaving,
              onPressed: _handleSave,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.captionStrong.copyWith(color: AppColors.textMuted, letterSpacing: 1.2),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          style: AppTypography.body.copyWith(
            color: enabled ? AppColors.textPrimary : AppColors.textMuted,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 22),
            filled: true,
            fillColor: enabled ? AppColors.bgSurface2 : AppColors.bgSurface,
          ),
        ),
      ],
    );
  }
}
