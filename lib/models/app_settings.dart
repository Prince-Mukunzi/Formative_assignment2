import 'session.dart';

enum NotificationTopic {
  reportUpdates('Report updates'),
  upvotes('Upvotes on my reports'),
  prizes('XP and prizes'),
  newReports('New reports'),
  deadlines('Deadline reminders'),
  boardChanges('Board changes'),
  overdueReports('Overdue reports'),
  unownedReports('Reports with no team'),
  dailySummary('Daily summary');

  const NotificationTopic(this.label);
  final String label;

  static List<NotificationTopic> forSession(Session? session) =>
      switch (session) {
        FacultySession() => const [newReports, deadlines, boardChanges],
        AdminSession() => const [overdueReports, unownedReports, dailySummary],
        _ => const [reportUpdates, upvotes, prizes],
      };
}

class AppSettings {
  final Set<NotificationTopic> muted;
  final bool haptics;
  final bool reduceMotion;
  final bool celebrations;

  const AppSettings({
    this.muted = const {},
    this.haptics = true,
    this.reduceMotion = false,
    this.celebrations = true,
  });

  AppSettings copyWith({
    Set<NotificationTopic>? muted,
    bool? haptics,
    bool? reduceMotion,
    bool? celebrations,
  }) => AppSettings(
    muted: muted ?? this.muted,
    haptics: haptics ?? this.haptics,
    reduceMotion: reduceMotion ?? this.reduceMotion,
    celebrations: celebrations ?? this.celebrations,
  );

  Map<String, Object> toJson() => {
    'muted': [for (final topic in muted) topic.name],
    'haptics': haptics,
    'reduceMotion': reduceMotion,
    'celebrations': celebrations,
  };

  static AppSettings fromJson(Object? json) {
    if (json is! Map) return const AppSettings();
    final muted = json['muted'];
    return AppSettings(
      muted: {
        if (muted is List)
          for (final topic in NotificationTopic.values)
            if (muted.contains(topic.name)) topic,
      },
      haptics: json['haptics'] != false,
      reduceMotion: json['reduceMotion'] == true,
      celebrations: json['celebrations'] != false,
    );
  }
}
