import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ohmyshelly/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';

/// Represents a user's date range selection
class DateRangeSelection {
  final DateRangeType type;
  final DateTime selectedDate;

  DateRangeSelection({
    required this.type,
    required this.selectedDate,
  });

  /// Get the actual date range for API calls
  ({DateTime from, DateTime to}) getDateRange() {
    switch (type) {
      case DateRangeType.day:
        // Full day
        final start = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0);
        final end = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);
        return (from: start, to: end);

      case DateRangeType.week:
        // Week containing the selected date (Monday to Sunday)
        final daysFromMonday = selectedDate.weekday - 1;
        final monday = DateTime(selectedDate.year, selectedDate.month, selectedDate.day - daysFromMonday, 0, 0, 0);
        final sunday = DateTime(monday.year, monday.month, monday.day + 6, 23, 59, 59);
        return (from: monday, to: sunday);

      case DateRangeType.month:
        // Full month
        final firstOfMonth = DateTime(selectedDate.year, selectedDate.month, 1, 0, 0, 0);
        final lastOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0, 23, 59, 59);
        return (from: firstOfMonth, to: lastOfMonth);

      case DateRangeType.year:
        // Full year
        final firstOfYear = DateTime(selectedDate.year, 1, 1, 0, 0, 0);
        final lastOfYear = DateTime(selectedDate.year, 12, 31, 23, 59, 59);
        return (from: firstOfYear, to: lastOfYear);
    }
  }

  /// Get display string for the selection
  String getDisplayString(AppLocalizations l10n) {
    switch (type) {
      case DateRangeType.day:
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final selected = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

        if (selected == today) {
          return l10n.day;
        } else if (selected == today.subtract(const Duration(days: 1))) {
          return DateFormat('EEE, MMM d').format(selectedDate);
        }
        return DateFormat('EEE, MMM d').format(selectedDate);

      case DateRangeType.week:
        final range = getDateRange();
        final now = DateTime.now();
        final currentWeekMonday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
        final selectedWeekMonday = DateTime(range.from.year, range.from.month, range.from.day);

        if (selectedWeekMonday == currentWeekMonday) {
          return l10n.thisWeek;
        } else if (selectedWeekMonday == currentWeekMonday.subtract(const Duration(days: 7))) {
          return l10n.lastWeek;
        }
        return '${DateFormat('MMM d').format(range.from)} - ${DateFormat('MMM d').format(range.to)}';

      case DateRangeType.month:
        final now = DateTime.now();
        if (selectedDate.year == now.year && selectedDate.month == now.month) {
          return l10n.thisMonth;
        } else if ((selectedDate.year == now.year && selectedDate.month == now.month - 1) ||
            (selectedDate.year == now.year - 1 && now.month == 1 && selectedDate.month == 12)) {
          return l10n.lastMonth;
        }
        return DateFormat('MMMM yyyy').format(selectedDate);

      case DateRangeType.year:
        final now = DateTime.now();
        if (selectedDate.year == now.year) {
          return l10n.year;
        }
        return selectedDate.year.toString();
    }
  }

  /// API interval string
  String get interval {
    switch (type) {
      case DateRangeType.day:
        return 'hour';
      case DateRangeType.week:
      case DateRangeType.month:
        return 'day';
      case DateRangeType.year:
        return 'month';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateRangeSelection &&
        other.type == type &&
        other.selectedDate.year == selectedDate.year &&
        other.selectedDate.month == selectedDate.month &&
        other.selectedDate.day == selectedDate.day;
  }

  @override
  int get hashCode => type.hashCode ^ selectedDate.hashCode;
}

enum DateRangeType {
  day,
  week,
  month,
  year,
}

extension DateRangeTypeExtension on DateRangeType {
  String getLabel(AppLocalizations l10n) {
    switch (this) {
      case DateRangeType.day:
        return l10n.day;
      case DateRangeType.week:
        return l10n.week;
      case DateRangeType.month:
        return l10n.month;
      case DateRangeType.year:
        return l10n.year;
    }
  }
}

/// User-friendly date range picker widget
class DateRangePicker extends StatelessWidget {
  final DateRangeSelection selection;
  final ValueChanged<DateRangeSelection> onChanged;

  const DateRangePicker({
    super.key,
    required this.selection,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Range type selector
        _buildTypeSelector(context, l10n),
        const SizedBox(height: 12),
        // Date selector based on type
        _buildDateSelector(context, l10n),
      ],
    );
  }

  Widget _buildTypeSelector(BuildContext context, AppLocalizations l10n) {
    return SegmentedButton<DateRangeType>(
      showSelectedIcon: false,
      segments: DateRangeType.values.map((type) {
        return ButtonSegment<DateRangeType>(
          value: type,
          label: Text(type.getLabel(l10n)),
        );
      }).toList(),
      selected: {selection.type},
      onSelectionChanged: (selected) {
        final newType = selected.first;
        // When changing type, reset to current period
        onChanged(DateRangeSelection(
          type: newType,
          selectedDate: DateTime.now(),
        ));
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.surfaceVariant;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return AppColors.textPrimary;
        }),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: _canGoPrevious ? () => _goToPrevious() : null,
            tooltip: selection.type.getLabel(l10n),
          ),
          // Current selection - tappable to show picker
          Expanded(
            child: InkWell(
              onTap: () => _showPicker(context),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      selection.getDisplayString(l10n),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_drop_down_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Next button
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: _canGoNext ? () => _goToNext() : null,
            tooltip: selection.type.getLabel(l10n),
          ),
        ],
      ),
    );
  }

  bool get _canGoPrevious {
    // Allow going back up to 2 years
    final twoYearsAgo = DateTime.now().subtract(const Duration(days: 730));
    return selection.selectedDate.isAfter(twoYearsAgo);
  }

  bool get _canGoNext {
    // Can't go beyond today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(selection.selectedDate.year, selection.selectedDate.month, selection.selectedDate.day);
    return selected.isBefore(today);
  }

  void _goToPrevious() {
    DateTime newDate;
    switch (selection.type) {
      case DateRangeType.day:
        newDate = selection.selectedDate.subtract(const Duration(days: 1));
        break;
      case DateRangeType.week:
        newDate = selection.selectedDate.subtract(const Duration(days: 7));
        break;
      case DateRangeType.month:
        newDate = DateTime(selection.selectedDate.year, selection.selectedDate.month - 1, 1);
        break;
      case DateRangeType.year:
        newDate = DateTime(selection.selectedDate.year - 1, 1, 1);
        break;
    }
    onChanged(DateRangeSelection(type: selection.type, selectedDate: newDate));
  }

  void _goToNext() {
    DateTime newDate;
    final now = DateTime.now();

    switch (selection.type) {
      case DateRangeType.day:
        newDate = selection.selectedDate.add(const Duration(days: 1));
        break;
      case DateRangeType.week:
        newDate = selection.selectedDate.add(const Duration(days: 7));
        break;
      case DateRangeType.month:
        newDate = DateTime(selection.selectedDate.year, selection.selectedDate.month + 1, 1);
        break;
      case DateRangeType.year:
        newDate = DateTime(selection.selectedDate.year + 1, 1, 1);
        break;
    }

    // Don't go beyond today
    if (newDate.isAfter(now)) {
      newDate = now;
    }

    onChanged(DateRangeSelection(type: selection.type, selectedDate: newDate));
  }

  Future<void> _showPicker(BuildContext context) async {
    switch (selection.type) {
      case DateRangeType.day:
        await _showDayPicker(context);
        break;
      case DateRangeType.week:
        await _showWeekPicker(context);
        break;
      case DateRangeType.month:
        await _showMonthPicker(context);
        break;
      case DateRangeType.year:
        await _showYearPicker(context);
        break;
    }
  }

  Future<void> _showDayPicker(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selection.selectedDate,
      firstDate: now.subtract(const Duration(days: 730)),
      lastDate: now,
      helpText: 'Select a day',
    );

    if (picked != null) {
      onChanged(DateRangeSelection(type: DateRangeType.day, selectedDate: picked));
    }
  }

  Future<void> _showWeekPicker(BuildContext context) async {
    final now = DateTime.now();

    // Show a custom week picker
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _WeekPickerSheet(
        selectedDate: selection.selectedDate,
        onSelected: (date) {
          onChanged(DateRangeSelection(type: DateRangeType.week, selectedDate: date));
          Navigator.pop(context);
        },
        maxDate: now,
      ),
    );
  }

  Future<void> _showMonthPicker(BuildContext context) async {
    final now = DateTime.now();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MonthPickerSheet(
        selectedDate: selection.selectedDate,
        onSelected: (date) {
          onChanged(DateRangeSelection(type: DateRangeType.month, selectedDate: date));
          Navigator.pop(context);
        },
        maxDate: now,
      ),
    );
  }

  Future<void> _showYearPicker(BuildContext context) async {
    final now = DateTime.now();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _YearPickerSheet(
        selectedYear: selection.selectedDate.year,
        onSelected: (year) {
          onChanged(DateRangeSelection(
            type: DateRangeType.year,
            selectedDate: DateTime(year, 1, 1),
          ));
          Navigator.pop(context);
        },
        maxYear: now.year,
      ),
    );
  }
}

/// Week picker bottom sheet
class _WeekPickerSheet extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelected;
  final DateTime maxDate;

  const _WeekPickerSheet({
    required this.selectedDate,
    required this.onSelected,
    required this.maxDate,
  });

  @override
  State<_WeekPickerSheet> createState() => _WeekPickerSheetState();
}

class _WeekPickerSheetState extends State<_WeekPickerSheet> {
  late int _selectedYear;
  late DateTime _selectedWeekStart;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.selectedDate.year;
    // Get Monday of the selected week
    final daysFromMonday = widget.selectedDate.weekday - 1;
    _selectedWeekStart = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day - daysFromMonday,
    );
  }

  List<DateTime> _getWeeksInYear(int year) {
    final weeks = <DateTime>[];
    // Start from first Monday of the year (or last Monday of previous year)
    var date = DateTime(year, 1, 1);
    final daysUntilMonday = (8 - date.weekday) % 7;
    if (daysUntilMonday > 0 && date.weekday != 1) {
      date = date.subtract(Duration(days: date.weekday - 1));
    }

    final now = DateTime.now();
    final maxWeekStart = DateTime(now.year, now.month, now.day - (now.weekday - 1));

    while (date.year <= year || (date.year == year + 1 && date.month == 1 && date.day < 7)) {
      if (date.year == year || (date.year == year - 1 && date.month == 12)) {
        if (!date.isAfter(maxWeekStart)) {
          weeks.add(date);
        }
      }
      date = date.add(const Duration(days: 7));
      if (date.year > year + 1) break;
    }

    return weeks;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final weeks = _getWeeksInYear(_selectedYear);
    final currentYear = DateTime.now().year;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textHint,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header with year selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: _selectedYear > currentYear - 2
                      ? () => setState(() => _selectedYear--)
                      : null,
                ),
                Text(
                  _selectedYear.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: _selectedYear < currentYear
                      ? () => setState(() => _selectedYear++)
                      : null,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Week list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: weeks.length,
              itemBuilder: (context, index) {
                final weekStart = weeks[index];
                final weekEnd = weekStart.add(const Duration(days: 6));
                final isSelected = weekStart == _selectedWeekStart;
                final weekNum = _getWeekNumber(weekStart);

                return ListTile(
                  selected: isSelected,
                  selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
                  leading: CircleAvatar(
                    backgroundColor: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                    foregroundColor: isSelected ? Colors.white : AppColors.textSecondary,
                    child: Text('$weekNum'),
                  ),
                  title: Text(
                    '${DateFormat('MMM d').format(weekStart)} - ${DateFormat('MMM d').format(weekEnd)}',
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  subtitle: _getWeekLabel(weekStart, l10n),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                      : null,
                  onTap: () => widget.onSelected(weekStart),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final dayOfYear = date.difference(firstDayOfYear).inDays;
    return ((dayOfYear + firstDayOfYear.weekday - 1) / 7).ceil();
  }

  Widget? _getWeekLabel(DateTime weekStart, AppLocalizations l10n) {
    final now = DateTime.now();
    final currentWeekStart = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final lastWeekStart = currentWeekStart.subtract(const Duration(days: 7));

    if (weekStart == currentWeekStart) {
      return Text(l10n.thisWeek, style: const TextStyle(color: AppColors.primary));
    } else if (weekStart == lastWeekStart) {
      return Text(l10n.lastWeek, style: const TextStyle(color: AppColors.textSecondary));
    }
    return null;
  }
}

/// Month picker bottom sheet
class _MonthPickerSheet extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelected;
  final DateTime maxDate;

  const _MonthPickerSheet({
    required this.selectedDate,
    required this.onSelected,
    required this.maxDate,
  });

  @override
  State<_MonthPickerSheet> createState() => _MonthPickerSheetState();
}

class _MonthPickerSheetState extends State<_MonthPickerSheet> {
  List<String> _getMonthNames(AppLocalizations l10n) => [
    l10n.monthJan, l10n.monthFeb, l10n.monthMar, l10n.monthApr,
    l10n.monthMay, l10n.monthJun, l10n.monthJul, l10n.monthAug,
    l10n.monthSep, l10n.monthOct, l10n.monthNov, l10n.monthDec,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final monthNames = _getMonthNames(l10n);
    final now = DateTime.now();
    // Get last 12 months
    final months = <DateTime>[];
    for (var i = 0; i < 12; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      months.add(date);
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textHint,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.selectMonth,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          // Month grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: months.length,
              itemBuilder: (context, index) {
                final month = months[index];
                final isSelected = month.year == widget.selectedDate.year &&
                    month.month == widget.selectedDate.month;
                final isCurrentMonth = month.year == now.year && month.month == now.month;

                return Material(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => widget.onSelected(month),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            monthNames[month.month - 1],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            month.year.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : AppColors.textSecondary,
                            ),
                          ),
                          if (isCurrentMonth && !isSelected)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Year picker bottom sheet
class _YearPickerSheet extends StatelessWidget {
  final int selectedYear;
  final ValueChanged<int> onSelected;
  final int maxYear;

  const _YearPickerSheet({
    required this.selectedYear,
    required this.onSelected,
    required this.maxYear,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Last 5 years
    final years = List.generate(5, (i) => maxYear - i);

    return Container(
      height: 300,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textHint,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.selectYear,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          // Year list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: years.length,
              itemBuilder: (context, index) {
                final year = years[index];
                final isSelected = year == selectedYear;
                final isCurrentYear = year == maxYear;

                return ListTile(
                  selected: isSelected,
                  selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
                  leading: CircleAvatar(
                    backgroundColor: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                    foregroundColor: isSelected ? Colors.white : AppColors.textSecondary,
                    child: Text('${year % 100}'),
                  ),
                  title: Text(
                    year.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  subtitle: isCurrentYear ? Text(l10n.thisYear) : null,
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                      : null,
                  onTap: () => onSelected(year),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
