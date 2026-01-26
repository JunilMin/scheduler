import 'package:flutter/material.dart';

import '../utils/dt.dart';

class AddScheduleResult {
  final String title;
  final DateTime startAt;
  final DateTime endAt;
  final String? memo;

  AddScheduleResult({
    required this.title,
    required this.startAt,
    required this.endAt,
    this.memo,
  });
}

Future<AddScheduleResult?> showAddScheduleDialog(
  BuildContext context, {
  required DateTime initialStart,
  required DateTime initialEnd,
}) async {
  final titleCtrl = TextEditingController();
  final memoCtrl = TextEditingController();
  DateTime startAt = initialStart;
  DateTime endAt = initialEnd;

  return showDialog<AddScheduleResult>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text("Add schedule"),
        content: StatefulBuilder(
          builder: (ctx2, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: "Title"),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: memoCtrl,
                    decoration: const InputDecoration(labelText: "Memo (optional)"),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text("Start"),
                      const Spacer(),
                      Text(Dt.ymdHm.format(startAt)),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: ctx2,
                            initialDate: startAt,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate == null) return;

                          final pickedTime = await showTimePicker(
                            context: ctx2,
                            initialTime: TimeOfDay.fromDateTime(startAt),
                          );
                          if (pickedTime == null) return;

                          setState(() {
                            startAt = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                            if (!endAt.isAfter(startAt)) {
                              endAt = startAt.add(const Duration(hours: 1));
                            }
                          });
                        },
                        child: const Text("Edit"),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text("End"),
                      const Spacer(),
                      Text(Dt.ymdHm.format(endAt)),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: ctx2,
                            initialDate: endAt,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate == null) return;

                          final pickedTime = await showTimePicker(
                            context: ctx2,
                            initialTime: TimeOfDay.fromDateTime(endAt),
                          );
                          if (pickedTime == null) return;

                          setState(() {
                            endAt = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                            if (!endAt.isAfter(startAt)) {
                              endAt = startAt.add(const Duration(hours: 1));
                            }
                          });
                        },
                        child: const Text("Edit"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              final title = titleCtrl.text.trim();
              if (title.isEmpty) return;

              Navigator.of(ctx).pop(
                AddScheduleResult(
                  title: title,
                  startAt: startAt,
                  endAt: endAt,
                  memo: memoCtrl.text.trim().isEmpty ? null : memoCtrl.text.trim(),
                ),
              );
            },
            child: const Text("Save"),
          ),
        ],
      );
    },
  );
}
