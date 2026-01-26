class Schedule {
  final String id;
  final String title;
  final DateTime startAt;
  final DateTime endAt;
  final String? memo;

  const Schedule({
    required this.id,
    required this.title,
    required this.startAt,
    required this.endAt,
    this.memo,
  });

  Schedule copyWith({
    String? id,
    String? title,
    DateTime? startAt,
    DateTime? endAt,
    String? memo,
  }) {
    return Schedule(
      id: id ?? this.id,
      title: title ?? this.title,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      memo: memo ?? this.memo,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "startAt": startAt.toUtc().toIso8601String(),
        "endAt": endAt.toUtc().toIso8601String(),
        "memo": memo,
      };

  static Schedule fromJson(Map<String, dynamic> json) {
    final rawId = json["id"];
    final id = rawId == null ? "" : rawId.toString();

    return Schedule(
      id: id,
      title: (json["title"] ?? "") as String,
      startAt: DateTime.parse(json["startAt"] as String).toLocal(),
      endAt: DateTime.parse(json["endAt"] as String).toLocal(),
      memo: json["memo"] as String?,
    );
  }
}
