// lib/core/utils/format_syp.dart
String formatSyp(num amount) {
  if (amount >= 1000000) {
    return '${_trim(amount / 1000000)} مليون ل.س';
  } else if (amount >= 1000) {
    return '${_trim(amount / 1000)} ألف ل.س';
  }
  return '${amount.toStringAsFixed(0)} ل.س';
}

String _trim(double value) =>
    value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
