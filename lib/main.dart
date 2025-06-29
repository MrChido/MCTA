import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'entry_screen.dart';
import 'package:intl/intl.dart';
import 'Utilities/date_util.dart';

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
  DateTime currentMonth = DateTime.now(); //asking the device the year and month
  Map<int, int> entriesPerDay = {};
  bool isReviewMode = false;
  List<int> reviewedDays = [];

  @override
  void initState() {
    super.initState();
    loadEntries();
    loadReviewedDays();
    _syncToCurrentMonthIfNeeded();
  }

  //setting up automatic advance of the calendar.
  void _syncToCurrentMonthIfNeeded() {
    final now = DateUtilHelper.getCurrentMonth();
    if (!DateUtilHelper.isSameMonth(currentMonth, now)) {
      setState(() {
        currentMonth = DateTime(now.year, now.month);
        entriesPerDay.clear();
        loadEntries();
        if (isReviewMode) loadReviewedDays();
      });
    }
  }

  void loadReviewedDays() async {
    final dbHelper = DatabaseHelper();
    final int selectedYear = currentMonth.year;
    final int selectedMonth = currentMonth.month;
    List<int> entryDays = await dbHelper.getDaysWithEntries(
        selectedYear, selectedMonth); // new helper function

    setState(() {
      reviewedDays = entryDays;
    });
  }

  void loadEntries() async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    final String yearStr = currentMonth.year.toString();
    final String monthStr = currentMonth.month.toString().padLeft(2, '0');

    final result = await db.rawQuery(
      '''SELECT timestamp FROM entries WHERE strftime('%Y', timestamp) = ? AND strftime('%m', timestamp) = ?''',
      [yearStr, monthStr],
    );

    final Map<int, int> tempMap = {};
    for (final row in result) {
      final ts = DateTime.parse(
          row['timestamp'] as String); //defining the 'timestamp' as a string
      final day = ts.day;
      tempMap[day] = (tempMap[day] ?? 0) + 1;
    }
    setState(() {
      entriesPerDay = tempMap;
    });
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  icon: Icon(Icons.arrow_left),
                  onPressed: () async {
                    setState(() {
                      currentMonth =
                          DateTime(currentMonth.year, currentMonth.month - 1);
                      entriesPerDay.clear();
                      reviewedDays.clear();
                      isReviewMode = false;
                    });
                    loadEntries();

                    if (isReviewMode) {
                      loadReviewedDays();
                    }
                  }),
              //changed the Month and Year declaration to a clickable, this way the user can jump between months and years
              //at a greater distance than one month at a time.
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: currentMonth,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(Duration(days: 365 * 5)),
                    initialDatePickerMode: DatePickerMode.year,
                  );

                  if (picked != null) {
                    setState(() {
                      currentMonth = DateTime(picked.year, picked.month);
                      entriesPerDay.clear();
                      reviewedDays.clear();
                      isReviewMode = false;
                    });
                    loadEntries();
                  }
                },
                child: Text(
                  DateFormat.yMMMM().format(currentMonth),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_right),
                onPressed: () async {
                  setState(() {
                    currentMonth =
                        DateTime(currentMonth.year, currentMonth.month + 1);
                    entriesPerDay.clear();
                    reviewedDays.clear();
                    isReviewMode = false;
                    loadEntries();
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 8),
          CalendarWidget(
            currentMonth: currentMonth,
            firstWeekday:
                DateTime(currentMonth.year, currentMonth.month, 1).weekday,
            daysInMonth:
                DateTime(currentMonth.year, currentMonth.month + 1, 0).day,
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
  final DateTime currentMonth;
  final int firstWeekday; // 1=Mon … 7=Sun
  final int daysInMonth;
  final Map<int, int> entriesPerDay;
  final List<int> reviewedDays;
  final bool isReviewMode;
  final ValueChanged<int> onDayTapped;

  const CalendarWidget({
    super.key,
    required this.currentMonth,
    required this.firstWeekday,
    required this.daysInMonth,
    required this.entriesPerDay,
    required this.reviewedDays,
    required this.isReviewMode,
    required this.onDayTapped,
  });

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
                        //This is the controll for the day being at its most extreme point
                        child: entryCount >= 10
                            ? Icon(Icons.whatshot,
                                color: Colors.yellow, size: 30)
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
    //this bit of code, is the gradient from grey to green to yellow to red
    //it will adapt to the number of entries and transition
    const int maxCount =
        10; //the gradient change caps at 10 entries for the transition.
    final normalized = (entryCount / maxCount).clamp(0.0, 1.0);
    if (entryCount <= 5) {
      return Color.lerp(
          Colors.grey, Colors.green, normalized / (5 / maxCount))!;
    } else if (entryCount <= 9) {
      return Color.lerp(Colors.green, Colors.yellow,
          (normalized - (5 / maxCount)) / ((9 - 5) / maxCount))!;
    } else {
      return Color.lerp(Colors.yellow, Colors.red,
          (normalized - (9 / maxCount)) / ((maxCount - 9) / maxCount))!;
    }
  }
}
