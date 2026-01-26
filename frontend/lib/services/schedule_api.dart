import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/schedule.dart';

class ScheduleApi {
  // NOTE:
  // - Desktop (Windows/Mac): localhost works if backend runs on same machine.
  // - Android emulator: use http://10.0.2.2:8080/api instead of localhost.
  static const String baseUrl = String.fromEnvironment("API_BASE_URL", defaultValue: "http://localhost:8080/api");

  final http.Client _client;

  ScheduleApi({http.Client? client}) : _client = client ?? http.Client();

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse("$baseUrl$path").replace(queryParameters: query);
  }

  Future<List<Schedule>> list({
    required DateTime from,
    required DateTime to,
  }) async {
    final res = await _client.get(
      _uri("/schedules", {
        "from": from.toUtc().toIso8601String(),
        "to": to.toUtc().toIso8601String(),
      }),
      headers: {"Accept": "application/json"},
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Failed to load schedules (${res.statusCode}): ${res.body}");
    }

    final decoded = jsonDecode(res.body);
    if (decoded is List) {
      return decoded
          .map((e) => Schedule.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (decoded is Map && decoded["items"] is List) {
      final items = decoded["items"] as List;
      return items
          .map((e) => Schedule.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception("Unexpected response shape: ${res.body}");
  }

  Future<Schedule> create({
    required String title,
    required DateTime startAt,
    required DateTime endAt,
    String? memo,
  }) async {
    final payload = {
      "title": title,
      "startAt": startAt.toUtc().toIso8601String(),
      "endAt": endAt.toUtc().toIso8601String(),
      "memo": memo,
    };

    final res = await _client.post(
      _uri("/schedules"),
      headers: {"Content-Type": "application/json", "Accept": "application/json"},
      body: jsonEncode(payload),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Failed to create schedule (${res.statusCode}): ${res.body}");
    }

    return Schedule.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<Schedule> update(Schedule schedule) async {
    final res = await _client.put(
      _uri("/schedules/${schedule.id}"),
      headers: {"Content-Type": "application/json", "Accept": "application/json"},
      body: jsonEncode(schedule.toJson()),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Failed to update schedule (${res.statusCode}): ${res.body}");
    }

    return Schedule.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    final res = await _client.delete(
      _uri("/schedules/$id"),
      headers: {"Accept": "application/json"},
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Failed to delete schedule (${res.statusCode}): ${res.body}");
    }
  }

  void dispose() => _client.close();
}
