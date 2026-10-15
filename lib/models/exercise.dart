/// تنسيق الثواني كساعة مؤقت: 01:30
String formatClock(int seconds) {
  final int total = seconds < 0 ? 0 : seconds;
  final int m = total ~/ 60;
  final int s = total % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

/// تنسيق الثواني كنص عربي مختصر: 45 ث / 2 د / 1 د 30 ث
String formatDurationText(int seconds) {
  if (seconds <= 0) return '0 ث';
  final int m = seconds ~/ 60;
  final int s = seconds % 60;
  if (m == 0) return '$s ث';
  if (s == 0) return '$m د';
  return '$m د $s ث';
}

int _asInt(dynamic value, int fallback) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

/// تمرين واحد: اسمه، وعدّاته، وجولاته، ومدة الجولة، والراحة بين الجولات.
///
/// - إذا كانت [durationSeconds] أكبر من صفر فالجولة تُنفَّذ بمؤقت (مثل الثبات).
/// - وإذا كانت صفراً فالجولة تُنفَّذ بالعدّات ([reps]).
class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    this.reps = 10,
    this.sets = 3,
    this.durationSeconds = 0,
    this.restSeconds = 60,
    this.note = '',
  });

  final String id;
  final String name;
  final int reps;
  final int sets;
  final int durationSeconds;
  final int restSeconds;
  final String note;

  static int _seq = 0;

  /// معرّف فريد للتمرين الجديد.
  static String newId() {
    _seq++;
    return '${DateTime.now().microsecondsSinceEpoch}_$_seq';
  }

  /// هل الجولة تُنفَّذ بمؤقت؟
  bool get isTimed => durationSeconds > 0;

  /// وصف مختصر مثل: 3 جولات • 10 عدّات • 30 ث للجولة
  String get summary {
    final List<String> parts = <String>[];
    parts.add('$sets جولات');
    if (reps > 0) parts.add('$reps عدّات');
    if (durationSeconds > 0) {
      parts.add('${formatDurationText(durationSeconds)} للجولة');
    }
    return parts.join(' • ');
  }

  /// وصف الراحة بين الجولات.
  String get restLabel {
    if (restSeconds <= 0) return 'بدون راحة';
    return 'راحة ${formatDurationText(restSeconds)}';
  }

  /// تقدير المدة الكلية بالثواني (الجولات المؤقتة + الراحة).
  int get estimatedSeconds {
    final int safeSets = sets < 1 ? 1 : sets;
    final int work = isTimed ? durationSeconds * safeSets : 0;
    final int rest = restSeconds * (safeSets - 1);
    return work + rest;
  }

  Exercise copyWith({
    String? id,
    String? name,
    int? reps,
    int? sets,
    int? durationSeconds,
    int? restSeconds,
    String? note,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      reps: reps ?? this.reps,
      sets: sets ?? this.sets,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'reps': reps,
      'sets': sets,
      'durationSeconds': durationSeconds,
      'restSeconds': restSeconds,
      'note': note,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    final String rawId = (json['id'] ?? '').toString();
    return Exercise(
      id: rawId.isEmpty ? newId() : rawId,
      name: (json['name'] ?? '').toString(),
      reps: _asInt(json['reps'], 10),
      sets: _asInt(json['sets'], 3),
      durationSeconds: _asInt(json['durationSeconds'], 0),
      restSeconds: _asInt(json['restSeconds'], 60),
      note: (json['note'] ?? '').toString(),
    );
  }
}
