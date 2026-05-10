import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/cinema/index.dart';
import '../components/movie/index.dart';
import '../components/ui/index.dart';
import '../design_system/tokens/index.dart';
import '../layouts/app_shell/index.dart';
import '../models/cinema.dart';
import '../models/movie.dart';
import '../models/showtime.dart';
import '../utils/app_notifier.dart';
import '../data/services/movie_service.dart';
import '../utils/image_helper.dart';
import 'seat_selection_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  final MoviePublicDto movie;
  final String heroTag;

  const MovieDetailScreen({super.key, required this.movie, required this.heroTag});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final MovieService _movieService = MovieService();
  final List<DateTime> _dates = List.generate(7, (i) => DateTime.now().add(Duration(days: i)));

  late MoviePublicDto _currentMovie;
  bool _loadingCinemas = true;
  bool _loadingDetail = true;

  List<Cinema> _cinemas = [];
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

  DateTime? _safeParseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr).toLocal();
    } catch (_) {
      try {
        return DateFormat("yyyy-MM-dd HH:mm:ss").parse(dateStr).toLocal();
      } catch (e) {
        return null;
      }
    }
  }

  Future<void> _loadAllData() async {
    setState(() { _loadingCinemas = true; _loadingDetail = true; });
    await Future.wait([_fetchServerMovieDetail(), _fetchCinemasAndShowtimes()]);
  }

  Future<void> _fetchServerMovieDetail() async {
    try {
      final response = await _movieService.getMovieDetail(_currentMovie.id);
      if (mounted && response?.data != null) {
        setState(() { _currentMovie = response!.data!; _loadingDetail = false; });
      }
    } catch (_) { if (mounted) setState(() => _loadingDetail = false); }
  }

  Future<void> _fetchCinemasAndShowtimes() async {
    try {
      final response = await _movieService.getCinemasWithShowtimes(_currentMovie.id);
      if (!mounted) return;

      final rawDataList = response?.data ?? [];
      final List<Cinema> tempCinemas = [];
      final Map<String, List<Showtime>> tempShowtimesMap = {};

      for (var cinemaDto in rawDataList) {
        final cinemaIdStr = cinemaDto.cinemaId.toString();

        tempCinemas.add(Cinema(
          id: cinemaIdStr,
          name: cinemaDto.cinemaName,
          address: cinemaDto.address ?? 'Địa chỉ đang cập nhật',
          // Lấy ảnh rạp từ API
          imageUrl: ImageHelper.getCorrectImageUrl(cinemaDto.cinemaImageUrl),
          status: 'Đang mở cửa',
          distance: '0.0 km',
          halls: 5,
          phone: '1900 6017',
          landmark: 'Khu vực gần đó',
          operatingHours: '08:00 - 23:00',
          accentValue: 0xFFE12636,
          facilities: const ['Wifi', 'Parking', 'Food & Drinks'],
        ));

        final List<Showtime> showtimesForThisCinema = [];
        for (var showtimeDto in cinemaDto.showtimes) {
          final dt = _safeParseDate(showtimeDto.showTime);
          if (dt == null) continue;

          showtimesForThisCinema.add(Showtime(
            id: showtimeDto.id.toString(),
            time: DateFormat('HH:mm').format(dt),
            screen: showtimeDto.roomName ?? 'Phòng chiếu',
            price: showtimeDto.price != null ? '${showtimeDto.price!.toStringAsFixed(0)}đ' : '0đ',
            availability: 'Còn chỗ',
            format: showtimeDto.format ?? '2D',
            language: showtimeDto.language ?? 'Phụ đề',
            dateLabel: DateFormat('yyyy-MM-dd').format(dt),
          ));
        }
        tempShowtimesMap[cinemaIdStr] = showtimesForThisCinema;
      }

      setState(() {
        _cinemas = tempCinemas;
        _cinemaShowtimes = tempShowtimesMap;
        _autoSelectFirstAvailableDate(tempCinemas, tempShowtimesMap);
        _loadingCinemas = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loadingCinemas = false);
    }
  }

  void _autoSelectFirstAvailableDate(List<Cinema> cinemas, Map<String, List<Showtime>> showtimesMap) {
    for (int i = 0; i < _dates.length; i++) {
      final key = DateFormat('yyyy-MM-dd').format(_dates[i]);
      if (cinemas.any((c) => (showtimesMap[c.id] ?? []).any((s) => s.dateLabel == key))) {
        _selectedDateIndex = i; _selectDate(i); return;
      }
    }
    _selectedDateIndex = 0;
  }

  void _selectDate(int index) {
    setState(() => _selectedDateIndex = index);
    final key = DateFormat('yyyy-MM-dd').format(_dates[index]);
    Cinema? nextC; Showtime? nextS;
    for (var c in _cinemas) {
      final list = (_cinemaShowtimes[c.id] ?? []).where((s) => s.dateLabel == key).toList();
      if (list.isNotEmpty) { nextC = c; nextS = list.first; break; }
    }
    setState(() { _selectedCinema = nextC; _selectedShowtime = nextS; });
  }

  void _openSeatSelection() {
    if (_selectedShowtime == null) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => SeatSelectionScreen(
      movie: _currentMovie, showtime: _selectedShowtime!, cinema: _selectedCinema!,
    )));
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
                slivers: [
                  SliverToBoxAdapter(child: _CinematicHeader(movie: _currentMovie, heroTag: widget.heroTag)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_currentMovie.title, style: AppTypography.title.copyWith(fontSize: 28)),
                          const SizedBox(height: AppSpacing.sm),
                          Row(children: [
                            AppBadge(label: _currentMovie.ageRating ?? 'P', backgroundColor: Colors.transparent, foregroundColor: AppColors.brandPrimary, borderColor: AppColors.brandPrimary),
                            const SizedBox(width: AppSpacing.sm),
                            AppBadge(label: _currentMovie.status ?? 'Đang chiếu', backgroundColor: AppColors.brandPrimarySoft, foregroundColor: AppColors.textPrimary, borderColor: AppColors.brandPrimary),
                          ]),
                          const SizedBox(height: AppSpacing.xl),
                          const _SectionLabel(label: 'Nội dung'),
                          const SizedBox(height: AppSpacing.sm),
                          _loadingDetail ? const AppSkeletonBox(height: 80) : Text(_currentMovie.description ?? 'Nội dung đang cập nhật...', style: AppTypography.body.copyWith(color: AppColors.textSecondary, height: 1.5)),
                          const SizedBox(height: AppSpacing.xl),
                          _MovieMetadataSection(movie: _currentMovie),
                          const SizedBox(height: AppSpacing.xxl),
                          const _SectionLabel(label: 'Lịch Chiếu'),
                          Text('Chọn ngày để xem suất chiếu theo rạp.', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                          const SizedBox(height: AppSpacing.md),
                          _DateSelector(dates: _dates, selectedIndex: _selectedDateIndex, cinemaShowtimes: _cinemaShowtimes, onChanged: _selectDate),
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
      bottomNavigationBar: _StickyCta(selectedShowtime: _selectedShowtime, selectedCinema: _selectedCinema, onPressed: _openSeatSelection),
    );
  }

  Widget _buildCinemaShowtimes() {
    if (_loadingCinemas) return const AppSkeletonList(itemCount: 2);
    final key = DateFormat('yyyy-MM-dd').format(_dates[_selectedDateIndex]);
    final cinemas = _cinemas.where((c) => (_cinemaShowtimes[c.id] ?? []).any((s) => s.dateLabel == key)).toList();

    if (cinemas.isEmpty) return const AppEmptyState(title: 'Chưa có suất chiếu', message: 'Không có suất chiếu phù hợp cho ngày này.');

    return Column(children: cinemas.map((cinema) {
      final list = (_cinemaShowtimes[cinema.id] ?? []).where((s) => s.dateLabel == key).toList();
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: CinemaCard(
          cinema: cinema,
          showtimes: list,
          selectedShowtime: _selectedCinema?.id == cinema.id ? _selectedShowtime : null,
          onShowtimeSelected: (s) => setState(() { _selectedCinema = cinema; _selectedShowtime = s; }),
        ),
      );
    }).toList());
  }
}

class _DateSelector extends StatelessWidget {
  final List<DateTime> dates;
  final int selectedIndex;
  final Map<String, List<Showtime>> cinemaShowtimes;
  final ValueChanged<int> onChanged;

  const _DateSelector({required this.dates, required this.selectedIndex, required this.cinemaShowtimes, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final date = dates[index];
          final key = DateFormat('yyyy-MM-dd').format(date);
          final hasData = cinemaShowtimes.values.any((list) => list.any((s) => s.dateLabel == key));
          final isSelected = selectedIndex == index;

          String weekday = DateFormat('E').format(date).toUpperCase();
          if (DateFormat('yyyy-MM-dd').format(DateTime.now()) == key) weekday = "H.NAY";
          if (date.weekday == DateTime.sunday) weekday = "CN";

          return GestureDetector(
            onTap: hasData ? () => onChanged(index) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 65,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.brandPrimary : AppColors.bgSurface2,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: isSelected ? AppColors.brandPrimary : AppColors.borderDefault, width: 1.5),
              ),
              child: Opacity(
                opacity: hasData ? 1.0 : 0.3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(weekday, style: AppTypography.captionStrong.copyWith(color: isSelected ? Colors.white70 : AppColors.textMuted, fontSize: 10)),
                    const SizedBox(height: 4),
                    Text(DateFormat('dd').format(date), style: AppTypography.subtitle.copyWith(color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CinematicHeader extends StatelessWidget {
  final MoviePublicDto movie;
  final String heroTag;
  const _CinematicHeader({required this.movie, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    final bannerUrl = ImageHelper.getCorrectImageUrl((movie.bannerUrl?.isNotEmpty ?? false) ? movie.bannerUrl : movie.posterUrl);
    final posterUrl = ImageHelper.getCorrectImageUrl(movie.posterUrl);
    return SizedBox(
      height: 320,
      child: Stack(
        children: [
          Container(height: 260, width: double.infinity, color: AppColors.bgSurface3, child: bannerUrl.isNotEmpty ? Image.network(bannerUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.movie)) : const SizedBox.shrink()),
          Positioned.fill(bottom: 60, child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.8)])))),
          Positioned(top: 40, left: 20, child: AppHeaderIconButton(icon: Icons.arrow_back, label: 'Quay lại', onPressed: () => Navigator.pop(context))),
          Positioned(bottom: 0, left: AppSpacing.lg, child: Container(height: 160, width: 110, decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: AppColors.bgApp, width: 3)), child: ClipRRect(borderRadius: BorderRadius.circular(AppRadius.sm), child: Hero(tag: heroTag, child: posterUrl.isNotEmpty ? Image.network(posterUrl, fit: BoxFit.cover) : Container(color: AppColors.bgSurface2))))),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(label, style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.bold));
}

class _MovieMetadataSection extends StatelessWidget {
  final MoviePublicDto movie;
  const _MovieMetadataSection({required this.movie});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: AppColors.bgSurface2, borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _buildMetaItem('Đạo diễn', movie.director ?? 'N/A', Icons.person_outline),
        Container(height: 30, width: 1, color: AppColors.borderDefault),
        _buildMetaItem('Thời lượng', movie.durationFormatted, Icons.timer_outlined),
        Container(height: 30, width: 1, color: AppColors.borderDefault),
        _buildMetaItem('Độ tuổi', movie.ageRating ?? 'P', Icons.verified_user_outlined),
      ]),
    );
  }
  Widget _buildMetaItem(String l, String v, IconData i) => Expanded(child: Column(children: [Icon(i, size: 20, color: AppColors.brandPrimary), const SizedBox(height: 4), Text(l, style: AppTypography.caption.copyWith(color: AppColors.textMuted)), Text(v, style: AppTypography.captionStrong, overflow: TextOverflow.ellipsis)]));
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
      decoration: const BoxDecoration(color: AppColors.bgSurface, border: Border(top: BorderSide(color: AppColors.borderDefault))),
      child: Row(children: [
        Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Suất đã chọn', style: AppTypography.caption.copyWith(color: AppColors.textMuted)), Text(ready ? '${selectedShowtime!.time} • ${selectedCinema!.name}' : 'Vui lòng chọn suất', style: AppTypography.bodyStrong, maxLines: 1, overflow: TextOverflow.ellipsis)])),
        const SizedBox(width: AppSpacing.md),
        SizedBox(width: 140, height: 48, child: AppButton(title: 'Chọn ghế', disabled: !ready, onPressed: onPressed)),
      ]),
    );
  }
}