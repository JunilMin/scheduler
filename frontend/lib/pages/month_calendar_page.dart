import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/schedule.dart';
import '../services/schedule_api.dart';
import '../utils/dt.dart';
import '../widgets/add_schedule_dialog.dart';
import 'week_planner_page.dart';

class MonthCalendarPage extends StatefulWidget {
  static const String routeName = '/';

  const MonthCalendarPage({super.key});

  @override
  State<MonthCalendarPage> createState() => _MonthCalendarPageState();
}

class _MonthCalendarPageState extends State<MonthCalendarPage> {
  final ScheduleApi _api = ScheduleApi();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, List<Schedule>> _byDay = {};

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day);
    _loadMonth(_focusedDay);
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  DateTime _key(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  Future<void> _loadMonth(DateTime anyDayInMonth) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final first = DateTime(anyDayInMonth.year, anyDayInMonth.month, 1);
    final nextMonth = DateTime(anyDayInMonth.year, anyDayInMonth.month + 1, 1);
    final last = nextMonth.subtract(const Duration(milliseconds: 1));

    try {
      final items = await _api.list(
        from: Dt.startOfDay(first),
        to: Dt.endOfDay(last),
      );

      final map = <DateTime, List<Schedule>>{};
      for (final s in items) {
        final dayKey = _key(s.startAt);
        map.putIfAbsent(dayKey, () => []).add(s);
      }

      setState(() {
        _byDay
          ..clear()
          ..addAll(map);
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  List<Schedule> _eventsForDay(DateTime day) => _byDay[_key(day)] ?? const [];

  Future<void> _addForSelectedDay() async {
    final day = _selectedDay ?? DateTime.now();
    final start = DateTime(day.year, day.month, day.day, 9);
    final end = start.add(const Duration(hours: 1));

    final result = await showAddScheduleDialog(
      context,
      initialStart: start,
      initialEnd: end,
    );
    if (result == null) return;

    try {
      final created = await _api.create(
        title: result.title,
        startAt: result.startAt,
        endAt: result.endAt,
        memo: result.memo,
      );

      setState(() {
        final k = _key(created.startAt);
        _byDay.putIfAbsent(k, () => []).add(created);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Create failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedDay ?? DateTime.now();
    final dayEvents = _eventsForDay(selected);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Month"),
        actions: [
          IconButton(
            tooltip: "Week view",
            onPressed: () {
              Navigator.of(context).pushNamed(
                WeekPlannerPage.routeName,
                arguments: WeekPlannerArgs(anchorDay: selected),
              );
            },
            icon: const Icon(Icons.view_week),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addForSelectedDay,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          TableCalendar<Schedule>(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) =>
                _selectedDay != null && isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
              _loadMonth(focusedDay);
            },
            eventLoader: _eventsForDay,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: CalendarStyle(
              markersMaxCount: 3,
              outsideDaysVisible: true,
            ),
          ),
          const Divider(height: 1),
          if (_loading)
            const LinearProgressIndicator(minHeight: 2)
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: dayEvents.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final s = dayEvents[i];
                return ListTile(
                  title: Text(s.title),
                  subtitle:
                      Text("${Dt.hm.format(s.startAt)} - ${Dt.hm.format(s.endAt)}"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
