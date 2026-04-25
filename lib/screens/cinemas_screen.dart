import 'package:flutter/material.dart';

import '../api/services/cinema_api.dart';
import '../components/cinema/index.dart';
import '../components/ui/index.dart';
import '../design_system/tokens/index.dart';
import '../layouts/app_shell/index.dart';
import '../models/cinema.dart';

class CinemasScreen extends StatefulWidget {
  const CinemasScreen({super.key});

  @override
  State<CinemasScreen> createState() => _CinemasScreenState();
}

class _CinemasScreenState extends State<CinemasScreen> {
  final CinemaApi _cinemaApi = const CinemaApi();
  final TextEditingController _searchController = TextEditingController();

  bool _loading = true;
  Object? _error;
  String _query = '';
  List<Cinema> _cinemas = const <Cinema>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await _cinemaApi.getCinemas();
      if (!mounted) return;
      setState(() {
        _cinemas = response.data;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  List<Cinema> get _filteredCinemas {
    final normalized = _query.trim().toLowerCase();
    if (normalized.isEmpty) return _cinemas;
    return _cinemas
        .where(
          (cinema) =>
              cinema.name.toLowerCase().contains(normalized) ||
              cinema.address.toLowerCase().contains(normalized) ||
              cinema.landmark.toLowerCase().contains(normalized),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SafeArea(
        bottom: false,
        child: ScreenContainer(
          title: 'Rạp',
          subtitle: 'Tìm rạp và xem suất chiếu',
          onRefresh: _load,
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const AppSkeletonList(itemCount: 5);
    }

    if (_error != null) {
      return AppErrorState(
        title: 'Không tải được rạp',
        message: 'Hãy thử lại để cập nhật cụm rạp gần bạn.',
        onRetry: _load,
      );
    }

    final items = _filteredCinemas;

    return Column(
      children: [
        AppInput(
          controller: _searchController,
          placeholder: 'Tìm rạp theo tên, địa chỉ...',
          leftIcon: const Icon(Icons.search),
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: AppSpacing.md),
        if (items.isEmpty)
          const AppEmptyState(
            title: 'Không tìm thấy rạp',
            message: 'Thử đổi từ khóa hoặc kiểm tra lại sau.',
          )
        else
          ...items.map(
            (cinema) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: CinemaCard(cinema: cinema),
            ),
          ),
      ],
    );
  }
}
