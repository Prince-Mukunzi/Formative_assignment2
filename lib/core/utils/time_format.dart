import 'package:timeago/timeago.dart' as timeago;

String shortTimeAgo(DateTime time) {
  if (DateTime.now().difference(time).inMinutes < 1) return 'Just now';
  return '${timeago.format(time, locale: 'en_short')} ago';
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String postedLabel(DateTime posted, DateTime now) {
  final elapsed = now.difference(posted);
  if (elapsed.inMinutes < 1) return 'Just now';
  if (elapsed.inMinutes < 60) return '${elapsed.inMinutes}m ago';
  final days = DateTime(
    now.year,
    now.month,
    now.day,
  ).difference(DateTime(posted.year, posted.month, posted.day)).inDays;
  if (days == 0) return 'Today';
  if (days == 1) return 'Yesterday';
  if (days < 7) return '$days days ago';
  final date = '${posted.day} ${_months[posted.month - 1]}';
  return posted.year == now.year ? date : '$date ${posted.year}';
}
