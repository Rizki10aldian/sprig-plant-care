const List<String> _shortMonths = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

/// "Selamat pagi", "Selamat siang", dst. sesuai jam.
String greeting(DateTime now) {
  final hour = now.hour;
  if (hour < 11) return 'Selamat pagi';
  if (hour < 15) return 'Selamat siang';
  if (hour < 18) return 'Selamat sore';
  return 'Selamat malam';
}

/// Contoh: "4 Nov".
String shortDate(DateTime date) => '${date.day} ${_shortMonths[date.month - 1]}';

/// Label sisa hari penyiraman, contoh: "Terlambat 2 hari", "Hari ini".
String dueLabel(int daysLeft) {
  if (daysLeft < 0) return 'Terlambat ${-daysLeft} hari';
  if (daysLeft == 0) return 'Siram hari ini';
  if (daysLeft == 1) return 'Besok';
  return '$daysLeft hari lagi';
}
