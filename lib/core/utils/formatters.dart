import 'package:intl/intl.dart';

abstract final class Formatters {
  static final _priceFormat = NumberFormat.decimalPattern('de_DE')
    ..minimumFractionDigits = 2
    ..maximumFractionDigits = 2;

  static String price(int cents) {
    return '${_priceFormat.format(cents / 100)} €';
  }

  static String distance(double km) {
    if (km < 1) return '<1 km';
    return '${km.round()} km';
  }

  static String relativeTime(DateTime dateTime, {DateTime? now}) {
    final diff = (now ?? DateTime.now()).difference(dateTime);
    if (diff.inMinutes < 60) return 'vor ${diff.inMinutes} Min.';
    if (diff.inHours < 24) return 'vor ${diff.inHours} Std.';
    return 'vor ${diff.inDays} Tagen';
  }

  /// Rein numerisch (kein Monatsname) — braucht deshalb kein
  /// `initializeDateFormatting`, anders als `intl`s `DateFormat`.
  static String date(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }
}
