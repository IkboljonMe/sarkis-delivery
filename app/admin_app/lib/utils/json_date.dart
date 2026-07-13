/// Parses API dates (ISO-8601 strings) leniently; returns local time.
DateTime? parseDate(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String && v.isNotEmpty) return DateTime.tryParse(v)?.toLocal();
  if (v is num) return DateTime.fromMillisecondsSinceEpoch(v.toInt());
  return null;
}
