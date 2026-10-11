import 'package:flutter/material.dart';
import '../models/sla_status.dart';
import '../models/team_member.dart';
import '../services/data_store.dart';
import '../services/sla_calculator.dart';
import '../theme/app_colors.dart';

class _SlaHealthCard extends StatelessWidget {
  final DataStore store;
  const _SlaHealthCard({required this.store});

  static const double _maxBarHeight = 110;

 
  List<DateTime> _weekdays() {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    return List.generate(5, (i) => start.add(Duration(days: i)));
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Counts, by SLA status, of the tasks due on [day]. Completed tasks are
  /// left out — the chart (matching the Figma) only tracks the three
  /// "live" statuses.
  _DayCounts _countsForDay(DateTime day) {
    var onTrack = 0, atRisk = 0, overdue = 0;
    for (final t in store.tasks) {
      if (t.isCompleted) continue;
      if (!_isSameDay(t.dueDate, day)) continue;
      switch (SlaCalculator.statusFor(t)) {
        case SlaStatus.onTrack:
          onTrack++;
          break;
        case SlaStatus.atRisk:
          atRisk++;
          break;
        case SlaStatus.overdue:
          overdue++;
          break;
        case SlaStatus.completed:
          break;
      }
    }
    return _DayCounts(onTrack: onTrack, atRisk: atRisk, overdue: overdue);
  }

  @override
  Widget build(BuildContext context) {
        final days = _weekdays();
    const weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayLabels = [for (final d in days) weekdayLabels[d.weekday - 1]];
    final dayCounts = [for (final day in days) _countsForDay(day)];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly SLA Health',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Only the current week is shown in this demo.'),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('This week',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      SizedBox(width: 4),
                      Icon(Icons.expand_more_rounded, size: 14, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                height: _maxBarHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$chartMax',
                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    Text('${(chartMax / 2).round()}',
                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    const Text('0', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < days.length; i++)
                      _WeekdayBar(
                        label: dayLabels[i],
                        counts: dayCounts[i],
                        maxTotal: chartMax,
                        maxBarHeight: _maxBarHeight,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _LegendDot(color: AppColors.onTrack, label: 'On Track'),
              _LegendDot(color: AppColors.atRisk, label: 'At Risk'),
              _LegendDot(color: AppColors.overdue, label: 'Overdue'),
            ],
          ),
        ],
      ),
    );
  }
}

/// Counts of not-yet-completed tasks due on one calendar day, split by
/// current SLA status. Used only to draw one bar of the weekly chart.
class _DayCounts {
  final int onTrack;
  final int atRisk;
  final int overdue;
  const _DayCounts({required this.onTrack, required this.atRisk, required this.overdue});
  int get total => onTrack + atRisk + overdue;
}

/// One stacked bar + weekday label in the "Weekly SLA Health" chart.
class _WeekdayBar extends StatelessWidget {
  final String label;
  final _DayCounts counts;
  final int maxTotal;
  final double maxBarHeight;

  const _WeekdayBar({
    required this.label,
    required this.counts,
    required this.maxTotal,
    required this.maxBarHeight,
  });

  double _segmentHeight(int count) {
    if (maxTotal <= 0 || count <= 0) return 0;
    return (count / maxTotal) * maxBarHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: maxBarHeight,
          width: 22,
          child: counts.total == 0
              ? const Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: 4,
                    width: 22,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: AppColors.border),
                    ),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(height: _segmentHeight(counts.overdue), color: AppColors.overdue),
                    Container(height: _segmentHeight(counts.atRisk), color: AppColors.atRisk),
                    Container(height: _segmentHeight(counts.onTrack), color: AppColors.onTrack),
                  ],
                ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}