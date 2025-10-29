import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CustomDateRangePicker extends StatefulWidget {
  final DateTimeRange? initialRange;
  final Function(DateTimeRange) onConfirm;

  const CustomDateRangePicker({
    super.key,
    this.initialRange,
    required this.onConfirm,
  });

  @override
  State<CustomDateRangePicker> createState() => _CustomDateRangePickerState();
}

class _CustomDateRangePickerState extends State<CustomDateRangePicker> {
  late DateTime _currentMonth;
  late DateTimeRange _selectedRange;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.initialRange?.start ?? DateTime.now();
    _selectedRange =
        widget.initialRange ??
        DateTimeRange(start: DateTime.now(), end: DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(theme),
          _buildCalendar(theme),
          _buildActionButtons(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
          Text(
            'Seleccionar Rango de Fechas',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 48), // Spacer
        ],
      ),
    );
  }

  Widget _buildCalendar(ThemeData theme) {
    return Column(
      children: [_buildMonthNavigator(theme), _buildCalendarGrid(theme)],
    );
  }

  Widget _buildMonthNavigator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _previousMonth,
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            DateFormat('MMMM yyyy', 'es_ES').format(_currentMonth),
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          IconButton(
            onPressed: _nextMonth,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(ThemeData theme) {
    final daysInMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ).day;
    final firstWeekday = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    ).weekday;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildWeekdayHeaders(theme),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
            ),
            itemCount: firstWeekday - 1 + daysInMonth,
            itemBuilder: (context, index) {
              if (index < firstWeekday - 1) {
                return const SizedBox.shrink();
              }
              final day = index - (firstWeekday - 1) + 1;
              final date = DateTime(
                _currentMonth.year,
                _currentMonth.month,
                day,
              );
              final isSelected = _isDateSelected(date);
              final isInRange = _isDateInRange(date);
              final isToday = _isSameDay(date, DateTime.now());

              return _buildDayCell(theme, date, isSelected, isInRange, isToday);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders(ThemeData theme) {
    const weekdays = ['D', 'L', 'M', 'X', 'J', 'V', 'S'];
    return Row(
      children: weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDayCell(
    ThemeData theme,
    DateTime date,
    bool isSelected,
    bool isInRange,
    bool isToday,
  ) {
    Color backgroundColor = Colors.transparent;
    Color textColor = theme.colorScheme.onSurface;

    if (isSelected) {
      backgroundColor = theme.colorScheme.primary;
      textColor = Colors.white;
    } else if (isInRange) {
      backgroundColor = theme.colorScheme.primary.withValues(alpha: 0.2);
    } else if (isToday) {
      backgroundColor = theme.colorScheme.primary.withValues(alpha: 0.1);
    }

    return GestureDetector(
      onTap: () => _onDateTapped(date),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: GoogleFonts.inter(
              color: textColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                widget.onConfirm(_selectedRange);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Confirmar'),
            ),
          ),
        ],
      ),
    );
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _onDateTapped(DateTime date) {
    setState(() {
      if (_selectedRange.start.isAfter(date)) {
        _selectedRange = DateTimeRange(start: date, end: _selectedRange.start);
      } else if (_selectedRange.end.isBefore(date)) {
        _selectedRange = DateTimeRange(start: _selectedRange.end, end: date);
      } else {
        _selectedRange = DateTimeRange(start: date, end: date);
      }
    });
  }

  bool _isDateSelected(DateTime date) {
    return (_isSameDay(date, _selectedRange.start) ||
        _isSameDay(date, _selectedRange.end));
  }

  bool _isDateInRange(DateTime date) {
    return (date.isAfter(_selectedRange.start) &&
        date.isBefore(_selectedRange.end));
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
