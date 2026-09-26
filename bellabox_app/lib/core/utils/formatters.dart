import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String price(num amount, {String locale = 'ar', bool compact = false}) {
    final formatter = NumberFormat.currency(
      locale: locale == 'ar' ? 'ar_SA' : 'en_SA',
      symbol: locale == 'ar' ? 'ر.س' : 'SAR',
      decimalDigits: amount.truncateToDouble() == amount ? 0 : 2,
    );
    return formatter.format(amount);
  }

  static String priceCompact(num amount, {String locale = 'ar'}) {
    return price(amount, locale: locale);
  }

  static String discountPercentage(num original, num sale) {
    if (original <= 0) return '';
    final pct = ((original - sale) / original * 100).round();
    return '$pct%';
  }

  static String phone(String input) {
    // Basic SA formatting: +966 5X XXX XXXX
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 9 && digits.startsWith('5')) {
      return '+966 ${digits.substring(0, 2)} ${digits.substring(2, 5)} ${digits.substring(5)}';
    }
    if (digits.length == 12 && digits.startsWith('966')) {
      return '+966 ${digits.substring(3, 5)} ${digits.substring(5, 8)} ${digits.substring(8)}';
    }
    return input;
  }

  /// Normalize to E.164 SA format: +9665XXXXXXXX
  static String normalizeSaudiPhone(String input) {
    var digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('00966')) digits = digits.substring(5);
    if (digits.startsWith('966')) digits = digits.substring(3);
    if (digits.startsWith('0')) digits = digits.substring(1);
    return '+966$digits';
  }

  static String date(DateTime dt, {String locale = 'ar'}) {
    return DateFormat.yMMMd(locale == 'ar' ? 'ar' : 'en').format(dt);
  }

  static String dateTime(DateTime dt, {String locale = 'ar'}) {
    return DateFormat.yMMMd(locale == 'ar' ? 'ar' : 'en')
        .add_jm()
        .format(dt);
  }

  static String timeAgo(DateTime dt, {String locale = 'ar'}) {
    final diff = DateTime.now().difference(dt);
    if (locale == 'ar') {
      if (diff.inMinutes < 1) return 'الآن';
      if (diff.inHours < 1) return 'قبل ${diff.inMinutes} دقيقة';
      if (diff.inDays < 1) return 'قبل ${diff.inHours} ساعة';
      if (diff.inDays < 30) return 'قبل ${diff.inDays} يوم';
      return date(dt, locale: locale);
    } else {
      if (diff.inMinutes < 1) return 'just now';
      if (diff.inHours < 1) return '${diff.inMinutes}m ago';
      if (diff.inDays < 1) return '${diff.inHours}h ago';
      if (diff.inDays < 30) return '${diff.inDays}d ago';
      return date(dt, locale: locale);
    }
  }
}
