import 'package:flutter/material.dart';

import '../models/schedule.dart';
import '../services/schedule_api.dart';
import '../utils/dt.dart';
import '../widgets/add_schedule_dialog.dart';

class WeekPlannerArgs {
  final DateTime anchorDay;
  WeekPlannerArgs({required this.anchorDay});
}

class WeekPlannerPage extends StatefulWidget {
  static const routeName = "/week";
  const WeekPlannerPage({super.key});

  @override
  State<WeekPlannerPage> createState() => _WeekPlannerPageState();
}

class _WeekPlannerPageState extends State<WeekPlannerPage> {
  final ScheduleApi _api = ScheduleApi();
  late DateTime _anchorDay;
  late DateTime _weekStart;
  late DateTime _weekEnd;

  bool _loading = false;
  String? _error;

  final List<Schedule> _items = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    _anchorDay = (args is WeekPlannerArgs) ? args.anchorDay : DateTime.now();

    _weekStart = Dt.startOfWeek(_anchorDay);
    _weekEnd = Dt.endOfWeek(_anchorDay);

    _loadWeek();
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  List<DateTime> get _days =>
      List.generate(7, (i) => _weekStart.add(Duration(days: i)));

  Future<void> _loadWeek() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _api.list(
        from: Dt.startOfDay(_weekStart),
        to: Dt.endOfDay(_weekEnd),
      );
      setState(() {
        _items
          ..clear()
          ..addAll(data);
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _addAt(DateTime day, int hour) async {
    final start = DateTime(day.year, day.month, day.day, hour);
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
      setState(() => _items.add(created));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Create failed: $e")),
      );
    }
  }

  List<Schedule> _eventsStartingAt(DateTime day, int hour) {
    return _items.where((s) {
      final sameDay =
          s.startAt.year == day.year && s.startAt.month == day.month && s.startAt.day == day.day;
      return sameDay && s.startAt.hour == hour;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final title = "${Dt.ymd.format(_weekStart)} ~ ${Dt.ymd.format(_weekEnd)}";

    return Scaffold(
      appBar: AppBar(
        title: Text("Week • $title"),
        actions: [
          IconButton(
            tooltip: "Refresh",
            onPressed: _loadWeek,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_loading) const LinearProgressIndicator(minHeight: 2),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          _WeekHeader(days: _days),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: 24,
              itemBuilder: (ctx, hour) {
                return SizedBox(
                  height: 68,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 54,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(hour.toString().padLeft(2, "0")),
                          ),
                        ),
                      ),
                      ..._days.map((day) {
                        final events = _eventsStartingAt(day, hour);
                        final label =
                            events.isEmpty ? "" : events.map((e) => e.title).join(", ");

                        return Expanded(
                          child: InkWell(
                            onTap: () => _addAt(day, hour),
                            child: Container(
                              margin: const EdgeInsets.all(1),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Theme.of(context).dividerColor),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  label,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
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

class _WeekHeader extends StatelessWidget {
  final List<DateTime> days;
  const _WeekHeader({required this.days});

  @override
  Widget build(BuildContext context) {
    const names = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    return Row(
      children: [
        const SizedBox(width: 54),
        ...days.map((d) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  Text(names[d.weekday - 1],
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 2),
                  Text("${d.month}/${d.day}",
                      style: Theme.of(context).textTheme.labelMedium),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
