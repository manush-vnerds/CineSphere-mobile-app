import 'package:cine_sphere/models/Movie.dart';
import 'package:cine_sphere/models/show.dart';
import 'package:cine_sphere/services/movie_api.dart';
import 'package:flutter/material.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.movie});

  final Movie movie;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late final Future<List<Show>> _showsFuture;
  DateTime? _selectedDate;
  Show? _selectedShow;
  final Set<String> _selectedSeats = {};

  static const _rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];
  static const _seatCountPerRow = 12;

  @override
  void initState() {
    super.initState();
    _showsFuture = MovieApi.fetchShowtimes(widget.movie.id);
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedShow = null;
      _selectedSeats.clear();
    });
  }

  void _selectShow(Show show) {
    setState(() {
      _selectedShow = show;
      _selectedSeats.clear();
    });
  }

  void _toggleSeat(String seatId) {
    if (_selectedShow == null || _selectedShow!.bookedSeats.contains(seatId)) {
      return;
    }

    setState(() {
      if (_selectedSeats.contains(seatId)) {
        _selectedSeats.remove(seatId);
      } else {
        _selectedSeats.add(seatId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1424),
      appBar: AppBar(
        title: const Text('Select Show & Seats'),
        backgroundColor: const Color(0xFF0A1424),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Show>>(
        future: _showsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final now = DateTime.now();
          final upcomingShows =
              (snapshot.data ?? const [])
                  .where((show) => show.isActive && show.startTime.isAfter(now))
                  .toList()
                ..sort(
                  (first, second) =>
                      first.startTime.compareTo(second.startTime),
                );

          if (upcomingShows.isEmpty) {
            return const Center(
              child: Text(
                'No upcoming shows are available.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final dates = _uniqueDates(upcomingShows);
          final displayedDate = _selectedDate ?? dates.first;
          final showsForDate = upcomingShows
              .where(
                (show) => _isSameDate(show.startTime.toLocal(), displayedDate),
              )
              .toList();

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 106),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _SectionHeading('Select Date'),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 76,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: dates.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final date = dates[index];
                          final isSelected = _isSameDate(date, displayedDate);
                          return _DateButton(
                            date: date,
                            isSelected: isSelected,
                            onTap: () => _selectDate(date),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 22),
                    const _SectionHeading('Available Showtimes'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: showsForDate
                          .map(
                            (show) => OutlinedButton(
                              onPressed: () => _selectShow(show),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: _selectedShow?.id == show.id
                                    ? Colors.blueAccent
                                    : const Color(0xFF15243A),
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Color(0xFF38536F),
                                ),
                              ),
                              child: Text(
                                _formatTime(show.startTime.toLocal()),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    if (_selectedShow != null) ...[
                      const SizedBox(height: 28),
                      _SectionHeading(
                        'Select Seats · ${_formatTime(_selectedShow!.startTime.toLocal())}',
                      ),
                      const SizedBox(height: 10),
                      const _SeatLegend(),
                      const SizedBox(height: 18),
                      const Center(
                        child: Text(
                          'SCREEN',
                          style: TextStyle(
                            color: Color.fromARGB(255, 200, 170, 170),
                            letterSpacing: 4,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: Color(0xFF75A7D8), thickness: 2),
                      const SizedBox(height: 14),
                      ..._rows.map(_buildSeatRow),
                    ],
                  ],
                ),
              ),
              _BookingFooter(
                selectedSeats: _selectedSeats,
                onProceed: _selectedSeats.isEmpty
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Seat selection saved. Add your booking API to continue.',
                            ),
                          ),
                        );
                      },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSeatRow(String row) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text(row, style: const TextStyle(color: Color(0xFFAAB7C8))),
          ),
          Expanded(
            child: Row(
              children: List.generate(_seatCountPerRow, (index) {
                final seatId = '$row${index + 1}';
                final isBooked = _selectedShow!.bookedSeats.contains(seatId);
                final isSelected = _selectedSeats.contains(seatId);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: GestureDetector(
                      onTap: isBooked ? null : () => _toggleSeat(seatId),
                      child: Container(
                        height: 28,
                        decoration: BoxDecoration(
                          color: isBooked
                              ? const Color(0xFF748196)
                              : isSelected
                              ? Colors.blueAccent
                              : const Color(0xFF70D4BE),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  List<DateTime> _uniqueDates(List<Show> shows) {
    final uniqueDates = <DateTime>[];
    for (final show in shows) {
      final start = show.startTime.toLocal();
      final date = DateTime(start.year, start.month, start.day);
      if (!uniqueDates.any((item) => _isSameDate(item, date))) {
        uniqueDates.add(date);
      }
    }
    return uniqueDates;
  }

  static bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  static String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w700,
    ),
  );
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return SizedBox(
      width: 70,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected
              ? Colors.blueAccent
              : const Color(0xFF15243A),
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFF38536F)),
          padding: EdgeInsets.zero,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(weekdays[date.weekday - 1]),
            Text('${date.day} ${months[date.month - 1]}'),
          ],
        ),
      ),
    );
  }
}

class _SeatLegend extends StatelessWidget {
  const _SeatLegend();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 16,
      children: [
        _LegendItem(color: Color(0xFF70D4BE), label: 'Available'),
        _LegendItem(color: Colors.blueAccent, label: 'Selected'),
        _LegendItem(color: Color(0xFF748196), label: 'Unavailable'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 13,
          height: 13,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(color: Color(0xFFD2DCE9))),
      ],
    );
  }
}

class _BookingFooter extends StatelessWidget {
  const _BookingFooter({required this.selectedSeats, required this.onProceed});

  final Set<String> selectedSeats;
  final VoidCallback? onProceed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF15243A),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selectedSeats.isEmpty
                      ? 'Select seats'
                      : '${selectedSeats.length} ticket${selectedSeats.length == 1 ? '' : 's'} selected',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              FilledButton(onPressed: onProceed, child: const Text('Proceed')),
            ],
          ),
        ),
      ),
    );
  }
}
