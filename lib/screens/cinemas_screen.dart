import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../mocks/mock_data.dart';
import '../models/cinema.dart';
import '../widgets/cinema_card.dart';
import '../theme/design_tokens.dart';

class CinemasScreen extends StatefulWidget {
  const CinemasScreen({super.key});

  @override
  State<CinemasScreen> createState() => _CinemasScreenState();
}

class _CinemasScreenState extends State<CinemasScreen> {
  String _query = '';

  List<Cinema> get _filteredCinemas {
    if (_query.trim().isEmpty) return cinemas;
    final normalizedQuery = _query.toLowerCase();
    return cinemas
        .where(
          (cinema) =>
              cinema.name.toLowerCase().contains(normalizedQuery) ||
              cinema.address.toLowerCase().contains(normalizedQuery) ||
              cinema.landmark.toLowerCase().contains(normalizedQuery),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Tìm rạp theo tên, địa chỉ...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 18, right: 12),
                    child: FaIcon(FontAwesomeIcons.magnifyingGlass, size: 16),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _query = value;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '${_filteredCinemas.length} rạp',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withAlphaPercent(0.64),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: _filteredCinemas.isEmpty
                    ? Center(
                        child: Text(
                          'Không tìm thấy rạp phù hợp.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _filteredCinemas.length,
                        itemBuilder: (_, index) {
                          return CinemaCard(cinema: _filteredCinemas[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
