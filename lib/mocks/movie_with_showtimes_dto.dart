import '../models/showtime_item.dart';

List<MovieWithShowtimesDto> getMockMovieWithShowtimes() {
  final now = DateTime.now();
  final tomorrow = now.add(const Duration(days: 1));

  String formatIso(DateTime date, int hour, int minute) {
    return DateTime(date.year, date.month, date.day, hour, minute).toIso8601String();
  }

  return [
    MovieWithShowtimesDto(
      cinemaId: 1,
      cinemaName: 'Beta Sài Gòn Center',
      address: '65 Lê Lợi, Quận 1, TP.HCM',
      cinemaImageUrl: 'assets/images/beta-sg.png',
      posterUrl: '',
      durationMinutes: 120,
      showtimes: [
        ShowtimeItemDto(
          id: 101,
          showTime: formatIso(now, 10, 10),
          roomName: 'Phòng 01',
          price: 120000,
          format: '2D',
          language: 'Phụ đề',
        ),
        ShowtimeItemDto(
          id: 102,
          showTime: formatIso(now, 13, 40),
          roomName: 'Phòng 03',
          price: 150000,
          format: 'IMAX',
          language: 'Lồng tiếng',
        ),
        ShowtimeItemDto(
          id: 103,
          showTime: formatIso(tomorrow, 18, 20),
          roomName: 'Phòng 05',
          price: 170000,
          format: '4DX',
          language: 'Phụ đề',
        ),
      ],
    ),
    MovieWithShowtimesDto(
      cinemaId: 2,
      cinemaName: 'Beta East Hub',
      address: '12 Nguyễn Thị Minh Khai, Quận 3, TP.HCM',
      cinemaImageUrl: 'assets/images/beta-east.png',
      posterUrl: '',
      durationMinutes: 120,
      showtimes: [
        ShowtimeItemDto(
          id: 201,
          showTime: formatIso(now, 15, 0),
          roomName: 'Phòng 02',
          price: 130000,
          format: '2D',
          language: 'Phụ đề',
        ),
        ShowtimeItemDto(
          id: 202,
          showTime: formatIso(tomorrow, 20, 45),
          roomName: 'Phòng 02',
          price: 190000,
          format: 'Premium',
          language: 'Phụ đề',
        ),
      ],
    ),
  ];
}