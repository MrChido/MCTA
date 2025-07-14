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

  // final int month = monthNameToNumber(monthName);
  // final String formattedDate =
  //     '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  final results = await db.query(
    'entries',
    where: "strftime('%Y-%m-%d')', timestamp) =?",
    whereArgs: ['2025-07-08'],
  );
  return results;
}

//sleep hour tracker
int calculatedSleepHours(int sleepTime, int wakeTime) {
  int sleepHour =
      sleepTime ~/ 100; //the ~/ pulls the whole hours from a 24 hour cycle
  int sleepMinute =
      sleepTime % 100; // this one stores the rest of the provided time
  int wakeHour = wakeTime ~/ 100;
  int wakeMinute = wakeTime % 100;

  int sleepTotalM = (sleepHour * 60) + sleepMinute;
  int wakeTotalM = (wakeHour * 60) + wakeMinute;

  int durationMinutes;
  if (wakeTotalM < sleepTotalM) {
    //wrap-around logic for weird overnight spans
    durationMinutes = (1440 - sleepTotalM) + wakeTotalM;
  } else {
    durationMinutes = wakeTotalM - sleepTotalM;
  }
  return durationMinutes ~/ 60;
}

Future<int> sleepHoursFromEntry(String timestamp) async {
  final db = await DatabaseHelper.instance.database;
  final entry = await db.query(
    'entries',
    where: 'timestamp =?',
    whereArgs: [timestamp],
  );

  if (entry.isEmpty) {
    print('No entry found for $timestamp');
  }

  if (entry.isNotEmpty) {
    final sleepTime = entry.first['sleep'] as int;
    final wakeTime = entry.first['wake'] as int;
    print('Raw entry: ${entry.first}');
    print('SleepTime : $wakeTime');
    print('SleepHours : ${calculatedSleepHours(sleepTime, wakeTime)}');

    return calculatedSleepHours(sleepTime, wakeTime);
  }

  throw Exception('Entry not found for timestamp :$timestamp');
}
