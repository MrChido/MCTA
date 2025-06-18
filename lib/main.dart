import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:convert';
import 'entry_screen.dart';

void main() {
  databaseFactory = databaseFactoryFfi;
  runApp((SymptomTrackerApp()));
}

typedef DayTapCallback = void Function(int day);

class SymptomTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Symptom Tracker',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: CalendarScreen(),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late int year;
  late int month;
  late int firstWeekday;
  late int daysInMonth;
  Map<int, int> entriesPerDay = {};
  bool isReviewMode = false;
  List<int> reviewedDays = [];

  @override
  void initState() {
    super.initState();
    year = DateTime.now().year;
    month = DateTime.now().month;
    firstWeekday = DateTime(year, month, 1).weekday;
    daysInMonth = DateTime(year, month + 1, 0).day;
    loadEntries();
    loadReviewedDays();
  }

  void loadReviewedDays() async {
    final dbHelper = DatabaseHelper();
    List<int> entryDays =
        await dbHelper.getDaysWithEntries(); // new helper function

    setState(() {
      reviewedDays = entryDays;
    });
  }

  void loadEntries() async {
    final dbHelper = DatabaseHelper();
    for (int day = 1; day <= 30; day++) {
      int count = await dbHelper.getEntryCountForDay(day);
      setState(() {
        entriesPerDay[day] = count;
      });
      print("day $day has $count entries"); //debuging
    }
  }

  Future<void> _onDayTapped(int day) async {
    final didAddEntry = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EntryScreen(
          day: day,
          updateEntryCount: (d) => _onDayTapped(d),
        ),
      ),
    );
    if (didAddEntry == true) {
      setState(() {
        entriesPerDay[day] = (entriesPerDay[day] ?? 0) + 1;
      });
    }
  }

  @override // this is what the user opens up to
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daily Journal')),
      body: Column(
        children: [
          CalendarWidget(
            year: year,
            month: month,
            firstWeekday: firstWeekday,
            daysInMonth: daysInMonth,
            entriesPerDay: entriesPerDay,
            reviewedDays: reviewedDays,
            isReviewMode: isReviewMode,
            onDayTapped: _onDayTapped,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text('Tap a day to log symptoms'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                isReviewMode = !isReviewMode;
                if (isReviewMode) {
                  loadReviewedDays();
                } else {
                  reviewedDays.clear();
                }
              });
            },
            child: Text("Review Entries"),
          ),
        ],
      ),
    );
  }
}

class CalendarWidget extends StatelessWidget {
  final int year;
  final int month;
  final int firstWeekday; // 1=Mon … 7=Sun
  final int daysInMonth;
  final Map<int, int> entriesPerDay;
  final List<int> reviewedDays;
  final bool isReviewMode;
  final ValueChanged<int> onDayTapped;

  const CalendarWidget({
    Key? key,
    required this.year,
    required this.month,
    required this.firstWeekday,
    required this.daysInMonth,
    required this.entriesPerDay,
    required this.reviewedDays,
    required this.isReviewMode,
    required this.onDayTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // How many table rows we need
    final rowCount = ((daysInMonth + (firstWeekday - 1)) / 7).ceil();
    //sunday first labels:
    final labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final offset = firstWeekday % 7;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Weekday headers
          Row(
            children: labels
                .map((d) => Expanded(
                    child: Center(
                        child: Text(d,
                            style: TextStyle(fontWeight: FontWeight.bold)))))
                .toList(),
          ),
          SizedBox(height: 8),
          // Calendar grid
          Table(
            children: List.generate(rowCount, (weekIdx) {
              return TableRow(
                children: List.generate(7, (wdayIdx) {
                  // slotIndex 0 maps to Mon slot if firstWeekday==1
                  final slot = weekIdx * 7 + wdayIdx;
                  final day = slot - offset + 1;

                  // blank cell if outside 1…daysInMonth
                  if (day < 1 || day > daysInMonth) {
                    return SizedBox(height: 40);
                  }

                  // determine background & text colors
                  final entryCount = entriesPerDay[day] ?? 0;
                  final bgColor = _getColor(entryCount, day);
                  final textColor = (isReviewMode && reviewedDays.contains(day))
                      ? Colors.white
                      : Colors.black;

                  return GestureDetector(
                    onTap: () => onDayTapped(day),
                    child: Container(
                      height: 40,
                      margin: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: entryCount >= 10
                            ? Icon(Icons.whatshot,
                                color: Colors.white, size: 16)
                            : Text(
                                '$day',
                                style:
                                    TextStyle(color: textColor, fontSize: 14),
                              ),
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
        ],
      ),
    );
  }

  Color _getColor(
    int entryCount,
    int day,
  ) {
    if (isReviewMode && reviewedDays.contains(day)) {
      return Color(0xFF4B0082); //indigo color
    }
    if (entryCount == 0) return Colors.grey;
    if (entryCount >= 1 && entryCount <= 5) return Colors.green;
    if (entryCount >= 6 && entryCount <= 9) return Colors.yellow;
    if (entryCount >= 10) return Colors.red;
    return Colors.red.shade900;
  }
}
