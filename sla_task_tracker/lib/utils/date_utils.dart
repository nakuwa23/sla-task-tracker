
class AppDateUtils {
  AppDateUtils._();

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  
  static String formatDate(DateTime date) {
    return '${_months[date.month - 1]} ${date.day}, ${date.year}';
  }

  
  static String formatDateShort(DateTime date) {
    return '${_months[date.month - 1]} ${date.day}';
  }

  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return '$m min${m == 1 ? '' : 's'} ago';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h hour${h == 1 ? '' : 's'} ago';
    }
    final d = diff.inDays;
    return '$d day${d == 1 ? '' : 's'} ago';
  }

  
  static String formatDuration(Duration d) {
    final isNegative = d.isNegative;
    final abs = d.abs();
    final days = abs.inDays;
    final hours = abs.inHours % 24;
    final minutes = abs.inMinutes % 60;
    String result;
    if (days > 0) {
      result = '${days}d ${hours}h';
    } else if (hours > 0) {
      result = '${hours}h ${minutes}m';
    } else {
      result = '${minutes}m';
    }
    return isNegative ? '-$result' : result;
  }
}
