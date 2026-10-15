import 'package:intl/intl.dart';

class ThaiFormatters {
  static final NumberFormat _currencyFormat = NumberFormat('#,##0.00', 'th_TH');

  static String formatCurrency(double amount, {bool showSymbol = true}) {
    final formatted = _currencyFormat.format(amount);
    return showSymbol ? '฿$formatted' : formatted;
  }

  static String formatAmountCompact(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M ฿';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}k ฿';
    }
    return formatCurrency(amount);
  }

  static const List<String> _thaiMonths = [
    'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
    'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
  ];

  static const List<String> _thaiMonthsFull = [
    'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
    'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
  ];

  static String formatThaiDate(DateTime date, {bool includeTime = false, bool shortMonth = true}) {
    final day = date.day;
    final month = shortMonth ? _thaiMonths[date.month - 1] : _thaiMonthsFull[date.month - 1];
    final year = date.year + 543; // Buddhist Era

    if (includeTime) {
      final time = DateFormat('HH:mm').format(date);
      return '$day $month $year • $time น.';
    }
    return '$day $month $year';
  }

  static String formatMonthYear(DateTime date) {
    final month = _thaiMonthsFull[date.month - 1];
    final year = date.year + 543;
    return '$month $year';
  }

  static String formatDayHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) {
      return 'วันนี้ (${formatThaiDate(date)})';
    } else if (checkDate == yesterday) {
      return 'เมื่อวาน (${formatThaiDate(date)})';
    } else {
      return formatThaiDate(date);
    }
  }
}
