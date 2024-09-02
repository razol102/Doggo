import 'package:flutter/material.dart';
import 'package:mobile/services/preferences_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mobile/services/http_service.dart';
import 'package:intl/intl.dart';

import 'package:mobile/utils/app_colors.dart';

class MedicalRecordsScreen extends StatefulWidget {
  static const String routeName = "/MedicalRecordsScreen";

  @override
  _MedicalRecordsScreenState createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, dynamic> _events = {};
  List<dynamic> _dailyRecords = [];

  @override
  void initState() {
    super.initState();
    _loadEventsForMonth(_focusedDay);
  }

  Future<void> _loadEventsForMonth(DateTime date) async {
    final dogId = await PreferencesService.getDogId();
    final Map<String, dynamic> events = await HttpService.getMonthlyMedicalRecords(dogId!, date.year, date.month);
    setState(() {
      _events = events;
    });
  }

  Future<void> _loadDailyRecords(DateTime date) async {
    final dogId = await PreferencesService.getDogId();
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final List dailyRecords = await HttpService.getDailyMedicalRecords(dogId!, formattedDate);
    setState(() {
      _dailyRecords = dailyRecords;
    });
  }

  String _formatTime(String dateTimeStr) {
    DateTime dateTime = DateFormat('EEE, dd MMM yyyy HH:mm:ss').parse(dateTimeStr, true);
    return DateFormat('HH:mm').format(dateTime.toLocal());
  }

  void _resetDailyRecords() {
    setState(() {
      _dailyRecords = [];
    });
  }

  void _showRecordDetails(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(record['vet_name']),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Address: ${record['address']}'),
              SizedBox(height: 8.0),
              Text('Time: ${_formatTime(record['record_datetime'])}'),
              SizedBox(height: 8.0),
              Text('Description: ${record['description']}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Medical Records",
          style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              calendarFormat: _calendarFormat,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _loadDailyRecords(selectedDay);
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
                _loadEventsForMonth(focusedDay);
                // _resetDailyRecords();
              },
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
              },
              calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                      color: AppColors.primaryColor1,
                      shape: BoxShape.circle
                  ),
                  selectedDecoration: BoxDecoration(
                    color: AppColors.secondaryColor2,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(
                      color: AppColors.whiteColor
                  ),
                  selectedTextStyle: TextStyle(
                      color: AppColors.blackColor
                  )
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  String dayKey = day.day.toString();
                  bool hasEvent = _events[dayKey] ?? false;

                  return Center(
                    child: Stack(
                      children: [
                        Text(
                          day.day.toString(),
                          style: const TextStyle(color: Colors.black),
                        ),
                        if (hasEvent)
                          Positioned(
                            bottom: 4,
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Divider(),
            const SizedBox(height: 16.0),
            Expanded(
              child: _dailyRecords.isNotEmpty
                  ? ListView.builder(
                itemCount: _dailyRecords.length,
                itemBuilder: (context, index) {
                  final record = _dailyRecords[index];
                  final time = _formatTime(record['record_datetime']);
                  return ListTile(
                    title: Text(record['vet_name']),
                    subtitle: Text(record['address']),
                    trailing: Text(time),
                    onTap: () {
                      _showRecordDetails(record);
                    },
                  );
                },
              )
                  : const Center(
                child: Text('No medical records for this day.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
