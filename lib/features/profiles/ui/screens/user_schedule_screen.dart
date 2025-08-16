import 'package:famconnect/features/common/ui/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';

class UserScheduleScreen extends StatefulWidget {
  const UserScheduleScreen({super.key});

  @override
  State<UserScheduleScreen> createState() => _UserScheduleScreenState();
}

class _UserScheduleScreenState extends State<UserScheduleScreen> {
  DateTime _selectedDay = DateTime.now();
  final Map<DateTime, List<Map<String, String>>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadEventsForDay(_selectedDay);
  }

  void _addEvent(String status, String description, String timeRange) async {
    final key = DateTime.utc(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );
    if (_events[key] == null) {
      _events[key] = [];
    }

    if (_events[key]!.length < 2) {
      final label = description.trim().isEmpty ? status : description;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User not logged in")));
        return;
      }

      final eventData = {
        "status": status,
        "description": "$label at $timeRange",
        "date": Timestamp.fromDate(key),
        "timeRange": timeRange,
      };

      final docRef = await FirebaseFirestore.instance
          .collection('user_schedules')
          .doc(user.uid)
          .collection('schedules')
          .add(eventData);

      _events[key]!.add({
        "status": status,
        "description": "$label at $timeRange",
        "docId": docRef.id,
      });

      setState(() {});
    }
  }

  Future<void> _loadEventsForDay(DateTime day) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final dayStart = DateTime.utc(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('user_schedules')
            .doc(user.uid)
            .collection('schedules')
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart))
            .where('date', isLessThan: Timestamp.fromDate(dayEnd))
            .get();

    final eventList =
        querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            "status": (data['status'] ?? 'Busy').toString(),
            "description": (data['description'] ?? '').toString(),
            "docId": doc.id,
          };
        }).toList();

    setState(() {
      _events[dayStart] = eventList;
    });
    print("Loading events for $dayStart");
    print("Query returned ${querySnapshot.docs.length} documents");
    for (var doc in querySnapshot.docs) {
      print(doc.id);
      print(doc.data());
    }
  }

  void _showAddDialog() {
    String selectedStatus = "Busy";
    final descController = TextEditingController();
    TimeOfDay? startTime;
    TimeOfDay? endTime;

    showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setStateDialog) => AlertDialog(
                  title: const Text("Add Schedule"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        items: const [
                          DropdownMenuItem(value: "Busy", child: Text("Busy")),
                          DropdownMenuItem(value: "Free", child: Text("Free")),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setStateDialog(() => selectedStatus = value);
                          }
                        },
                        decoration: const InputDecoration(labelText: "Status"),
                      ),
                      TextField(
                        controller: descController,
                        decoration: const InputDecoration(
                          labelText: "Description",
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setStateDialog(() => startTime = time);
                          }
                        },
                        child: Text(
                          startTime == null
                              ? 'Select Start Time'
                              : 'Start: ${startTime!.format(context)}',
                        ),
                      ),
                      SizedBox(height: 5),
                      ElevatedButton(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setStateDialog(() => endTime = time);
                          }
                        },
                        child: Text(
                          endTime == null
                              ? 'Select End Time'
                              : 'End: ${endTime!.format(context)}',
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        if (startTime != null && endTime != null) {
                          final timeRange =
                              '${startTime!.format(context)} - ${endTime!.format(context)}';
                          _addEvent(
                            selectedStatus,
                            descController.text,
                            timeRange,
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Add"),
                    ),
                  ],
                ),
          ),
    );
  }

  Widget _buildEventList() {
    final key = DateTime.utc(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );

    final events = _events[key] ?? [];
    print('Events for $key: $events');
    if (events.isEmpty) {
      return const Text("No events for this day");
    }
    return Column(
      children:
          events
              .map(
                (e) => Card(
                  color:
                      e["status"] == "Busy"
                          ? Colors.deepOrangeAccent.withOpacity(0.2)
                          : Colors.lightBlueAccent.withOpacity(0.2),
                  child: ListTile(
                    title: Text(e["status"]!),
                    subtitle: Text(e["description"]!),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteEvent(e, key),
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  void _deleteEvent(Map<String, String> event, DateTime key) async {
    final docId = event["docId"];
    final user = FirebaseAuth.instance.currentUser;
    if (docId != null && user != null) {
      await FirebaseFirestore.instance
          .collection('user_schedules')
          .doc(user.uid)
          .collection('schedules')
          .doc(docId)
          .delete();
    }

    _events[key]?.remove(event);

    if (_events[key]?.isEmpty ?? true) {
      _events.remove(key);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Weekly Scheduler"),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _selectedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            calendarFormat: CalendarFormat.week,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
              _loadEventsForDay(selectedDay);
            },
          ),
          const SizedBox(height: 10),
          _buildEventList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
