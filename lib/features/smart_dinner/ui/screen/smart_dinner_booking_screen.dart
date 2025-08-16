import 'package:famconnect/features/common/ui/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SmartDinnerBookingScreen extends StatefulWidget {
  const SmartDinnerBookingScreen({super.key});
  @override
  State<SmartDinnerBookingScreen> createState() => _SmartDinnerBookingScreenState();
}

class _SmartDinnerBookingScreenState extends State<SmartDinnerBookingScreen> {
  final List<String> daysOfWeek = [
    'monday', 'tuesday', 'wednesday',
    'thursday', 'friday', 'saturday', 'sunday'
  ];
  Map<String, List<String>> userSchedules = {};
  Map<String, String> suggestedSlots = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final rawSchedule = data['weekly_schedule'];

      final Map<String, String> schedule = {};

      if (rawSchedule is Map) {
        Map<String, dynamic> safeMap = Map<String, dynamic>.from(rawSchedule);
        safeMap.forEach((key, value) {
          if (value is String) {
            schedule[key] = value;
          }
        });
      }
      for (final day in daysOfWeek) {
        userSchedules.putIfAbsent(day, () => []);
        final slot = schedule[day];
        if (slot != null && slot.isNotEmpty) {
          userSchedules[day]!.add(slot);
        }
      }
    }
    _findCommonDinnerTimes();
    setState(() => isLoading = false);
  }
  void _findCommonDinnerTimes() {
    const dinnerStart = 18;
    const dinnerEnd = 22;

    for (final day in daysOfWeek) {
      final slots = userSchedules[day]!;
      if (slots.isEmpty) continue;

      final parsedSlots = slots.map((s) {
        final parts = s.split('-');
        if (parts.length != 2) return null;
        final start = int.tryParse(parts[0].split(':')[0]) ?? 0;
        final end = int.tryParse(parts[1].split(':')[0]) ?? 0;
        return [start, end];
      }).where((s) => s != null).cast<List<int>>().toList();

      if (parsedSlots.isEmpty) continue;

      int latestStart = parsedSlots.map((s) => s[0]).reduce((a, b) => a > b ? a : b);
      int earliestEnd = parsedSlots.map((s) => s[1]).reduce((a, b) => a < b ? a : b);

      // Check if overlap falls within dinner time
      if (latestStart < earliestEnd && latestStart >= dinnerStart && earliestEnd <= dinnerEnd) {
        suggestedSlots[day] = "${latestStart}:00 - ${earliestEnd}:00";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: ('Smart Dinner Suggestion')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : suggestedSlots.isEmpty
          ? const Center(child: Text('No common dinner time found this week.'))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: suggestedSlots.entries.map((entry) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(entry.key[0].toUpperCase() + entry.key.substring(1)),
              subtitle: Text('Suggested Time: ${entry.value}'),
              trailing: ElevatedButton(
                onPressed: () {
                  _bookDinner(entry.key, entry.value);
                },
                child: const Text("Book"),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _bookDinner(String day, String time) async {
    final currentUser = FirebaseFirestore.instance.collection('users').doc();
    try {
      await FirebaseFirestore.instance.collection('dinner_bookings').add({
        'day': day,
        'time': time,
        'booked_by': currentUser.id,
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dinner booked on $day at $time')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to book dinner')),
      );
    }
  }

}
