import 'package:flutter/material.dart';
import 'pages/month_calendar_page.dart';
import 'pages/week_planner_page.dart';

void main() {
  runApp(const SchedulerApp());
}

class SchedulerApp extends StatelessWidget {
  const SchedulerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scheduler',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: MonthCalendarPage.routeName,
      routes: {
        MonthCalendarPage.routeName: (_) => const MonthCalendarPage(),
        WeekPlannerPage.routeName: (_) => const WeekPlannerPage(),
      },
    );
  }
}
