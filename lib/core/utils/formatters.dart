import 'package:intl/intl.dart';

class AppFormatters {
  static final _currencyCOP = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    decimalDigits: 0,
  );

  static final _percent = NumberFormat.percentPattern('es_CO');
  static final _dateFormat = DateFormat('dd/MM/yyyy', 'es_CO');
  static final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm', 'es_CO');

  static String currency(double value) => _currencyCOP.format(value);
  
  static String percent(double value) => '${(value * 100).toStringAsFixed(1)}%';
  
  static String date(DateTime dt) => _dateFormat.format(dt);
  
  static String dateTime(DateTime dt) => _dateTimeFormat.format(dt);

  static String compactCurrency(double value) {
    if (value >= 1000000000) return '\$${(value / 1000000000).toStringAsFixed(1)}B';
    if (value >= 1000000) return '\$${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '\$${(value / 1000).toStringAsFixed(0)}K';
    return currency(value);
  }

  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'hace ${diff.inDays} días';
    return date(dt);
  }
}
