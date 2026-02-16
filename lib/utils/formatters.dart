import 'package:intl/intl.dart';

/// Format amount to Indonesian Rupiah
String formatRupiah(double amount) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

/// Format amount to compact Rupiah (e.g., "1.5M")
String formatRupiahCompact(double amount) {
  if (amount >= 1000000000) {
    return 'Rp ${(amount / 1000000000).toStringAsFixed(1)}B';
  } else if (amount >= 1000000) {
    return 'Rp ${(amount / 1000000).toStringAsFixed(1)}M';
  } else if (amount >= 1000) {
    return 'Rp ${(amount / 1000).toStringAsFixed(0)}K';
  }
  return formatRupiah(amount);
}

/// Format date string (DD/MM/YYYY to readable format)
String formatDate(String dateStr) {
  try {
    final parts = dateStr.split('/');
    if (parts.length == 3) {
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      final date = DateTime(year, month, day);
      return DateFormat('dd MMM yyyy').format(date);
    }
  } catch (e) {
    // Return original if parsing fails
  }
  return dateStr;
}

/// Format DateTime to DD/MM/YYYY string
String formatDateToString(DateTime date) {
  return DateFormat('dd/MM/yyyy').format(date);
}

/// Format DateTime to relative time (e.g., "2 min ago")
String formatRelativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} min ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
  } else {
    return DateFormat('dd MMM yyyy').format(dateTime);
  }
}

/// Parse date string to DateTime
DateTime? parseDate(String dateStr) {
  try {
    final parts = dateStr.split('/');
    if (parts.length == 3) {
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    }
  } catch (e) {
    // Return null if parsing fails
  }
  return null;
}

/// Format percentage
String formatPercent(double value) {
  return '${value.toStringAsFixed(1)}%';
}
