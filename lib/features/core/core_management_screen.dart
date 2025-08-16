import 'package:famconnect/features/core/core_assign_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CoreManagementScreen extends StatefulWidget {
  const CoreManagementScreen({super.key});

  @override
  State<CoreManagementScreen> createState() => _CoreManagementScreenState();
}

class _CoreManagementScreenState extends State<CoreManagementScreen> {
  DateTime _selectedDay = DateTime.now();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<_UserFreeSlot> _freeSlots = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchAllUsersFreeSlots(_selectedDay);
  }

  Future<void> _fetchAllUsersFreeSlots(DateTime day) async {
    setState(() {
      _loading = true;
      _freeSlots = [];
    });

    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    try {
      final usersSnapshot = await _firestore.collection('users').get();

      final userIdNameMap = {
        for (var userDoc in usersSnapshot.docs)
          userDoc.id: (userDoc.data()['name'] ?? 'No Name') as String,
      };

      final futures = userIdNameMap.entries.map((entry) async {
        final userId = entry.key;
        final userName = entry.value;

        final schedulesSnapshot = await _firestore
            .collection('user_schedules')
            .doc(userId)
            .collection('schedules')
            .where('status', isEqualTo: 'Free')
            .get();

        // Try to get assigned task from tasks/userId document
        String? taskDescription;
        try {
          final taskDoc = await _firestore.collection('tasks').doc(userId).get();
          if (taskDoc.exists) {
            final taskData = taskDoc.data();
            taskDescription = taskData?['taskDescription'] as String?;
          }
        } catch (_) {
          taskDescription = null;
        }

        return schedulesSnapshot.docs.map((doc) {
          final data = doc.data();
          final Timestamp timestamp = data['date'] as Timestamp;
          final DateTime date = timestamp.toDate();
          if (date.isBefore(dayStart) || !date.isBefore(dayEnd)) {
            return null;
          }

          final timeRange = (data['timeRange'] ?? 'Unknown Time') as String;
          final description = (data['description'] ?? '') as String;

          return _UserFreeSlot(
            userId: userId,
            userName: userName,
            timeRange: timeRange,
            description: description,
            date: date,
            assignedTask: taskDescription,
          );
        }).whereType<_UserFreeSlot>().toList();
      });

      final List<List<_UserFreeSlot>> slotsPerUser = await Future.wait(futures);

      setState(() {
        _freeSlots = slotsPerUser.expand((slots) => slots).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load free slots: $e')),
      );
    }
  }

  Future<void> _onDaySelected(DateTime day) async {
    setState(() {
      _selectedDay = day;
    });
    await _fetchAllUsersFreeSlots(day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Core Management')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              child: Text('Select Date: ${_selectedDay.toLocal()}'.split(' ')[0]),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDay,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null && picked != _selectedDay) {
                  await _onDaySelected(picked);
                }
              },
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _freeSlots.isEmpty
                ? const Center(child: Text('No free time slots found for the selected day'))
                : ListView.builder(
              itemCount: _freeSlots.length,
              itemBuilder: (context, index) {
                final slot = _freeSlots[index];

                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(slot.userName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Free Time: ${slot.timeRange}'),
                      if (slot.description.isNotEmpty)
                        Text('Note: ${slot.description}'),
                      Text('Date: ${slot.date.toLocal().toString().split(' ')[0]}'),
                      Text('Assigned Task: ${slot.assignedTask ?? 'None'}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_task),
                    tooltip: 'Assign Task',
                    onPressed: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (_) => AssignTaskScreen(
                            userName: slot.userName,
                            date: slot.date,
                            timeRange: slot.timeRange,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserFreeSlot {
  final String userId;
  final String userName;
  final String timeRange;
  final String description;
  final DateTime date;
  final String? assignedTask;

  _UserFreeSlot({
    required this.userId,
    required this.userName,
    required this.timeRange,
    required this.description,
    required this.date,
    this.assignedTask,
  });
}
