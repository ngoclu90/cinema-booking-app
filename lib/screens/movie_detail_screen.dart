import 'package:flutter/material.dart';
import '../components/cinema/index.dart';
import '../components/movie/index.dart';
import '../components/ui/index.dart';
import '../design_system/tokens/index.dart';
import '../layouts/app_shell/index.dart';
import '../mocks/movie_with_showtimes_dto.dart';
import '../models/cinema.dart';
import '../models/movie.dart';
import '../models/showtime.dart';
import '../models/showtime_item.dart';
import '../utils/app_notifier.dart';
import '../data/services/movie_service.dart';
import 'seat_selection_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  final MoviePublicDto movie;
  final String heroTag;

  const MovieDetailScreen({
    super.key,
    required this.movie,
    required this.heroTag,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final MovieService _movieService = MovieService();
  final List<String> _dateLabels = const ['Hôm nay', 'Ngày mai'];

  late MoviePublicDto _currentMovie;
  bool _loadingCinemas = true;
  bool _loadingDetail = true;

  List<Cinema> _cinemas = const <Cinema>[];
  Map<String, List<Showtime>> _cinemaShowtimes = {};

  int _selectedDateIndex = 0;
  Showtime? _selectedShowtime;
  Cinema? _selectedCinema;

  @override
  void initState() {
    super.initState();
    _currentMovie = widget.movie;
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _loadingCinemas = true;
      _loadingDetail = true;
    });

    await Future.wait([
      _fetchServerMovieDetail(),
      _fetchCinemasAndShowtimes(),
    ]);
  }

  Future<void> _fetchServerMovieDetail() async {
    try {
      final response = await _movieService.getMovieDetail(_currentMovie.id);
      if (!mounted) return;
      if (response != null && response.data != null) {
        setState(() {
          _currentMovie = response.data!;
          _loadingDetail = false;
        });
      } else {
        setState(() => _loadingDetail = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingDetail = false);
    }
  }

  Future<void> _fetchCinemasAndShowtimes() async {
    try {
      final response = await _movieService.getCinemasWithShowtimes(_currentMovie.id);
      if (!mounted) return;

      List<MovieWithShowtimesDto> rawDataList = [];

      if (response != null && response.data != null && response.data!.isNotEmpty) {
        rawDataList = response.data!;
      } else {
        rawDataList = getMockMovieWithShowtimes();
      }

      final List<Cinema> tempCinemas = [];
      final Map<String, List<Showtime>> tempShowtimesMap = {};

      for (var cinemaDto in rawDataList) {
        final cinemaIdStr = cinemaDto.cinemaId.toString();

        /* Ép kiểu và bổ sung đầy đủ tham số required cho class Cinema */
        tempCinemas.add(Cinema(
          id: cinemaIdStr,
          name: cinemaDto.cinemaName,
          address: cinemaDto.address ?? '',
          status: 'Đang mở cửa',
          distance: '0.0 km',
          halls: cinemaDto.durationMinutes != null ? 3 : 5,
          phone: '1900 6017',
          landmark: 'Khu vực trung tâm',
          operatingHours: '08:00 - 23:00',
          accentValue: 0xFFE12636,
          facilities: const ['Wifi', 'Parking', 'Food & Drinks'],
        ));

        final List<Showtime> showtimesForThisCinema = [];
        for (var showtimeDto in cinemaDto.showtimes) {
          showtimesForThisCinema.add(Showtime(
            id: showtimeDto.id.toString(),
            time: _formatTime(showtimeDto.showTime),
            screen: showtimeDto.roomName ?? 'Phòng chiếu',
            price: showtimeDto.price != null
                ? '${showtimeDto.price!.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}đ'
                : '0đ',
            availability: 'Còn chỗ',
            format: showtimeDto.format ?? '2D',
            language: showtimeDto.language ?? 'Phụ đề',
            dateLabel: _getDateLabel(showtimeDto.showTime),
          ));
        }
        tempShowtimesMap[cinemaIdStr] = showtimesForThisCinema;
      }

      setState(() {
        _cinemas = tempCinemas;
        _cinemaShowtimes = tempShowtimesMap;
        _selectedCinema = tempCinemas.firstOrNull;
        _selectedShowtime = _getInitialShowtime(tempCinemas, tempShowtimesMap);
        _loadingCinemas = false;
      });
    } catch (e) {
      print('Fetch API Error, falling back to mock: $e');
      if (!mounted) return;

      final mockData = getMockMovieWithShowtimes();
      final List<Cinema> tempCinemas = [];
      final Map<String, List<Showtime>> tempShowtimesMap = {};

      for (var cinemaDto in mockData) {
        final cinemaIdStr = cinemaDto.cinemaId.toString();

        /* Bổ sung đầy đủ tham số required ở luồng Fallback để tránh lỗi */
        tempCinemas.add(Cinema(
          id: cinemaIdStr,
          name: cinemaDto.cinemaName,
          address: cinemaDto.address ?? '',
          status: 'Đang mở cửa',
          distance: '0.0 km',
          halls: 5,
          phone: '1900 6017',
          landmark: 'Khu vực trung tâm',
          operatingHours: '08:00 - 23:00',
          accentValue: 0xFFE12636,
          facilities: const ['Wifi', 'Parking', 'Food & Drinks'],
        ));

        final List<Showtime> showtimesForThisCinema = [];
        for (var showtimeDto in cinemaDto.showtimes) {
          showtimesForThisCinema.add(Showtime(
            id: showtimeDto.id.toString(),
            time: _formatTime(showtimeDto.showTime),
            screen: showtimeDto.roomName ?? 'Phòng chiếu',
            price: showtimeDto.price != null
                ? '${showtimeDto.price!.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}đ'
                : '0đ',
            availability: 'Còn chỗ',
            format: showtimeDto.format ?? '2D',
            language: showtimeDto.language ?? 'Phụ đề',
            dateLabel: _getDateLabel(showtimeDto.showTime),
          ));
        }
        tempShowtimesMap[cinemaIdStr] = showtimesForThisCinema;
      }

      setState(() {
        _cinemas = tempCinemas;
        _cinemaShowtimes = tempShowtimesMap;
        _selectedCinema = tempCinemas.firstOrNull;
        _selectedShowtime = _getInitialShowtime(tempCinemas, tempShowtimesMap);
        _loadingCinemas = false;
      });
    }
  }

  Showtime? _getInitialShowtime(List<Cinema> cinemas, Map<String, List<Showtime>> showtimesMap) {
    if (cinemas.isEmpty) return null;
    final firstCinemaId = cinemas.first.id;
    final showtimes = showtimesMap[firstCinemaId] ?? [];
    final currentLabel = _dateLabels[_selectedDateIndex];
    return showtimes.where((s) => s.dateLabel == currentLabel).firstOrNull;
  }

  void _selectDate(int index) {
    setState(() {
      _selectedDateIndex = index;
    });

    final currentLabel = _dateLabels[index];
    Showtime? nextSelectedShowtime;
    Cinema? nextSelectedCinema;

    for (var cinema in _cinemas) {
      final showtimes = (_cinemaShowtimes[cinema.id] ?? [])
          .where((s) => s.dateLabel == currentLabel)
          .toList();
      if (showtimes.isNotEmpty) {
        nextSelectedCinema = cinema;
        nextSelectedShowtime = showtimes.first;
        break;
      }
    }

    setState(() {
      _selectedCinema = nextSelectedCinema;
      _selectedShowtime = nextSelectedShowtime;
    });
  }

  void _openSeatSelection() {
    if (_selectedShowtime == null || _selectedCinema == null) {
      AppNotifier.warning(context, title: 'Chưa chọn suất', description: 'Hãy chọn rạp và suất chiếu.');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SeatSelectionScreen(
          movie: _currentMovie,
          showtime: _selectedShowtime!,
          cinema: _selectedCinema!,
        ),
      ),
    );
  }

  String _formatTime(String showTimeStr) {
    try {
      final dateTime = DateTime.parse(showTimeStr);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return showTimeStr;
    }
  }

  String _getDateLabel(String showTimeStr) {
    try {
      final dateTime = DateTime.parse(showTimeStr);
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));

      if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day) {
        return 'Hôm nay';
      } else if (dateTime.year == tomorrow.year && dateTime.month == tomorrow.month && dateTime.day == tomorrow.day) {
        return 'Ngày mai';
      }
      return 'Hôm nay';
    } catch (_) {
      return 'Hôm nay';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadAllData,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _CinematicHeader(
                      movie: _currentMovie,
                      heroTag: widget.heroTag,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentMovie.title,
                            style: AppTypography.title.copyWith(fontSize: 28),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              AppBadge(
                                label: _currentMovie.ageRating ?? 'P',
                                backgroundColor: Colors.transparent,
                                foregroundColor: AppColors.brandPrimary,
                                borderColor: AppColors.brandPrimary,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              AppBadge(
                                label: _currentMovie.status ?? 'Đang chiếu',
                                backgroundColor: AppColors.brandPrimarySoft,
                                foregroundColor: AppColors.textPrimary,
                                borderColor: AppColors.brandPrimary,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          _buildSectionHeader('Nội dung'),
                          const SizedBox(height: AppSpacing.sm),
                          _loadingDetail
                              ? const AppSkeletonBox(height: 80)
                              : Text(
                            _currentMovie.description ?? 'Nội dung đang được cập nhật...',
                            style: AppTypography.body.copyWith(color: AppColors.textSecondary, height: 1.5),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          _MovieMetadataSection(movie: _currentMovie),
                          const SizedBox(height: AppSpacing.xxl),
                          _buildSectionHeader('Chọn suất chiếu'),
                          const SizedBox(height: AppSpacing.md),
                          _DateSelector(
                            labels: _dateLabels,
                            selectedIndex: _selectedDateIndex,
                            onChanged: _selectDate,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _buildCinemaShowtimes(),
                          const SizedBox(height: 140),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _StickyCta(
        selectedShowtime: _selectedShowtime,
        selectedCinema: _selectedCinema,
        onPressed: _openSeatSelection,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.bold));
  }

  Widget _buildCinemaShowtimes() {
    if (_loadingCinemas) return const AppSkeletonList(itemCount: 2);
    final currentLabel = _dateLabels[_selectedDateIndex];

    final cinemasWithShowtimesForDate = _cinemas.where((cinema) {
      final showtimes = _cinemaShowtimes[cinema.id] ?? [];
      return showtimes.any((s) => s.dateLabel == currentLabel);
    }).toList();

    if (cinemasWithShowtimesForDate.isEmpty) {
      return const AppEmptyState(
        title: 'Chưa có suất chiếu',
        message: 'Không có suất chiếu nào phù hợp cho ngày này.',
      );
    }

    return Column(
      children: cinemasWithShowtimesForDate.map((cinema) {
        final showtimes = (_cinemaShowtimes[cinema.id] ?? [])
            .where((s) => s.dateLabel == currentLabel)
            .toList();

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: CinemaCard(
            cinema: cinema,
            showtimes: showtimes,
            selectedShowtime: _selectedCinema?.id == cinema.id ? _selectedShowtime : null,
            onShowtimeSelected: (s) => setState(() {
              _selectedCinema = cinema;
              _selectedShowtime = s;
            }),
          ),
        );
      }).toList(),
    );
  }
}

class _CinematicHeader extends StatelessWidget {
  final MoviePublicDto movie;
  final String heroTag;

  const _CinematicHeader({required this.movie, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Stack(
        children: [
          Container(
            height: 260,
            width: double.infinity,
            decoration: const BoxDecoration(color: AppColors.bgSurface3),
            child: movie.bannerUrl != null
                ? Image.network(movie.bannerUrl!, fit: BoxFit.cover)
                : const Center(child: Icon(Icons.movie_creation_outlined, size: 48)),
          ),
          Positioned.fill(
            bottom: 60,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: AppHeaderIconButton(
              icon: Icons.arrow_back,
              label: 'Quay lại',
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            bottom: 0,
            left: AppSpacing.lg,
            child: Container(
              height: 160,
              width: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 5)
                  )
                ],
                border: Border.all(color: AppColors.bgApp, width: 3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Hero(
                  tag: heroTag,
                  child: MoviePoster(movie: movie),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MovieMetadataSection extends StatelessWidget {
  final MoviePublicDto movie;
  const _MovieMetadataSection({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgSurface2,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: _buildMetaItem('Đạo diễn', movie.director ?? 'N/A', Icons.person_outline)),
          _buildDivider(),
          Expanded(child: _buildMetaItem('Thời lượng', movie.durationFormatted, Icons.timer_outlined)),
          _buildDivider(),
          Expanded(child: _buildMetaItem('Độ tuổi', movie.ageRating ?? 'P', Icons.verified_user_outlined)),
        ],
      ),
    );
  }

  Widget _buildDivider() => Container(height: 30, width: 1, color: AppColors.borderDefault);

  Widget _buildMetaItem(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: AppColors.brandPrimary),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: AppColors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          value,
          style: AppTypography.captionStrong,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _DateSelector extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _DateSelector({
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(labels.length, (index) {
        final selected = selectedIndex == index;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == labels.length - 1 ? 0 : AppSpacing.sm,
            ),
            child: SizedBox(
              height: 44,
              child: OutlinedButton(
                onPressed: () => onChanged(index),
                style: OutlinedButton.styleFrom(
                  backgroundColor: selected
                      ? AppColors.brandPrimary
                      : AppColors.bgSurface2,
                  side: BorderSide(
                    color: selected
                        ? AppColors.brandPrimary
                        : AppColors.borderDefault,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                child: Text(
                  labels[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.captionStrong.copyWith(
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _StickyCta extends StatelessWidget {
  final Showtime? selectedShowtime;
  final Cinema? selectedCinema;
  final VoidCallback onPressed;

  const _StickyCta({this.selectedShowtime, this.selectedCinema, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final ready = selectedShowtime != null && selectedCinema != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 30),
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        border: Border(top: BorderSide(color: AppColors.borderDefault)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Suất đã chọn', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                Text(ready ? '${selectedShowtime!.time} • ${selectedCinema!.name}' : 'Vui lòng chọn suất',
                    style: AppTypography.bodyStrong, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: 140,
            height: 48,
            child: AppButton(
              title: 'Chọn ghế',
              disabled: !ready,
              onPressed: onPressed,
            ),
          ),
        ],
      ),
    );
  }
}