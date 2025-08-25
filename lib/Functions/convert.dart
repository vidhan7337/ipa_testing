String formatIndianShort(num value) {
  if (value >= 10000000) {
    // Crores
    return "₹${(value / 10000000).toStringAsFixed(1)} Cr";
  } else if (value >= 100000) {
    // Lakhs
    return "₹${(value / 100000).toStringAsFixed(1)} Lakh";
  } else if (value >= 1000) {
    // Thousands
    return "₹${(value / 1000).toStringAsFixed(1)} K";
  } else {
    return "₹${value.toString()}";
  }
}

String formatDate(DateTime? date) {
  if (date == null) return '';
  return "${date.day.toString().padLeft(2, '0')}-"
      "${date.month.toString().padLeft(2, '0')}-"
      "${date.year}";
}
