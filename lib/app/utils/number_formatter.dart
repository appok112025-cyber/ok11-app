class NumberFormatter {
  static String formatCount(int? count) {
    if (count == null || count <= 0) return '0';

    if (count < 1000) {
      return count.toString();
    }

    final thousands = count / 1000.0;

    if (thousands % 1 == 0) {
      return '${thousands.toInt()}K';
    }

    final formatted = thousands.toStringAsFixed(1);
    return formatted.endsWith('.0') ? '${thousands.toInt()}K' : '${formatted}K';
  }
}
