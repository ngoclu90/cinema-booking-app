import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../api/services/user_api.dart';
import '../core/api_client.dart';
import '../components/ui/index.dart';
import '../design_system/tokens/index.dart';
import '../models/profile.dart';
import '../state/app_controller.dart';
import '../utils/app_notifier.dart';

class EditProfileScreen extends StatefulWidget {
  final AppController controller;

  const EditProfileScreen({super.key, required this.controller});

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

  // Dùng timestamp để làm mới URL ảnh, tránh cache của Flutter
  int _imageVersion = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    final profile = widget.controller.currentAccount?.profile ?? ProfileUser.empty();
    _nameController = TextEditingController(text: profile.name);
    _phoneController = TextEditingController(text: profile.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Hàm helper để lấy URL ảnh đầy đủ kèm Cache Buster
  String? _getFullImageUrl(String? path, {int? version}) {
    if (path == null || path.isEmpty) return null;
    String url = path.startsWith('http') ? path : '${ApiClient.imgBaseUrl}$path';
    return '$url?v=${version ?? _imageVersion}';
  }

  void _handlePickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70,
      );

      if (image == null) return;

      setState(() => _isUploadingAvatar = true);

      // 1. Gọi API upload ảnh
      await _userApi.updateAvatar(image);

      if (mounted) {
        // 2. Cập nhật dữ liệu từ Server vào Controller ngay lập tức
        await widget.controller.reloadAccount();

        final updatedProfile = widget.controller.currentAccount?.profile;
        final newVersion = DateTime.now().millisecondsSinceEpoch;

        // 3. Tải trước ảnh mới vào RAM để tránh hiện tượng "nền đen" khi cập nhật UI
        if (updatedProfile?.avatarUrl != null && updatedProfile!.avatarUrl!.isNotEmpty) {
          final nextFullUrl = _getFullImageUrl(updatedProfile.avatarUrl, version: newVersion);
          if (nextFullUrl != null) {
            try {
              await precacheImage(NetworkImage(nextFullUrl), context);
            } catch (e) {
              debugPrint('--- [PRECACHE ERROR] $e ---');
            }
          }
        }

        // 4. Chỉ cập nhật UI khi mọi thứ đã sẵn sàng
        setState(() {
          _imageVersion = newVersion;
          _isUploadingAvatar = false;
        });

        AppNotifier.success(context, title: 'Thành công', description: 'Đã cập nhật ảnh đại diện');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
        AppNotifier.error(context,
            title: 'Lỗi upload',
            description: e.toString().replaceAll('Exception: ', '')
        );
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
      await widget.controller.reloadAccount();

      if (mounted) {
        AppNotifier.success(context, title: 'Thành công', description: 'Thông tin cá nhân đã được cập nhật.');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        AppNotifier.error(context, title: 'Lỗi', description: e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin mới nhất từ Controller
    final profile = widget.controller.currentAccount?.profile ?? ProfileUser.empty();
    final displayAvatar = _getFullImageUrl(profile.avatarUrl);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Avatar Section
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface2,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.brandPrimary, width: 2),
                    ),
                    child: ClipOval(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Ảnh đại diện
                          if (displayAvatar != null)
                            Image.network(
                              displayAvatar,
                              fit: BoxFit.cover,
                              gaplessPlayback: true, // GIỮ ẢNH CŨ CHO ĐẾN KHI ẢNH MỚI TẢI XONG
                              errorBuilder: (_, __, ___) => _buildPlaceholder(),
                            )
                          else
                            _buildPlaceholder(),

                          // Lớp phủ loading
                          if (_isUploadingAvatar)
                            Container(
                              color: Colors.black.withOpacity(0.4),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Material(
                      color: AppColors.brandPrimary,
                      shape: const CircleBorder(),
                      elevation: 4,
                      child: InkWell(
                        onTap: _isUploadingAvatar ? null : _handlePickImage,
                        customBorder: const CircleBorder(),
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(Icons.camera_alt_rounded, size: 22, color: Colors.white),
                        ),
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
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: AppSpacing.lg),

            _buildField(
              label: 'Email',
              controller: TextEditingController(text: widget.controller.currentAccount?.email ?? ''),
              icon: Icons.email_outlined,
              enabled: false,
            ),
            const SizedBox(height: AppSpacing.lg),

            _buildField(
              label: 'Số điện thoại',
              controller: _phoneController,
              icon: Icons.phone_android_rounded,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.huge),

            AppButton(
              title: 'Lưu thay đổi',
              loading: _isSaving,
              disabled: _isUploadingAvatar,
              onPressed: _handleSave,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    String initial = _nameController.text.isNotEmpty
        ? _nameController.text[0].toUpperCase()
        : 'U';
    return Center(
      child: Text(
        initial,
        style: AppTypography.display.copyWith(
          color: AppColors.brandPrimary,
          fontSize: 48,
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