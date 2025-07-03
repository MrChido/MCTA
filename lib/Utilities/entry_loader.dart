import 'package:melzers_symptom_tracker/services/database_helper.dart';

Future<List<int>> loadReviewedDays(DateTime currentMonth) async {
  final dbHelper = DatabaseHelper();
  final int selectedYear = currentMonth.year;
  final int selectedMonth = currentMonth.month;
  List<int> entryDays = await dbHelper.getDaysWithEntries(
      selectedYear, selectedMonth); // new helper function

  return entryDays;
}
