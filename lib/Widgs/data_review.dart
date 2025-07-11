import 'package:flutter/cupertino.dart';
import 'package:melzers_symptom_tracker/services/database_helper.dart';

int monthNameToNumber(String monthName) {
  const months = {
    'January': 1,
    'February': 2,
    'March': 3,
    'April': 4,
    'May': 5,
    'June': 6,
    'July': 7,
    'August': 8,
    'September': 9,
    'October': 10,
    'November': 11,
    'December': 12
  };
  return months[monthName] ?? 0; //fallback in case month is invalid
}

Future<List<Map<String, dynamic>>> getEntriesForDate(
    {required int day, required int year, required String monthName}) async {
  final db = await DatabaseHelper.instance.database;

  final int month = monthNameToNumber(monthName);
  final String formattedDate =
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  final results = await db.query(
    'entries',
    where: "strftime('%Y-%m-%d')', timestamp) =?",
    whereArgs: ['2025-07-08'],
  );
  return results;
}
