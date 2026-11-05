import 'package:timeago/timeago.dart' as timeago;

String shortTimeAgo(DateTime time) {
  if (DateTime.now().difference(time).inMinutes < 1) return 'Just now';
  return '${timeago.format(time, locale: 'en_short')} ago';
}
