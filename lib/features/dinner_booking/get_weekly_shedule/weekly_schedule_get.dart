import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, Map<String, String>>> fetchUserSchedules() async {
  final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
  final schedules = <String, Map<String, String>>{};

  for (var userDoc in usersSnapshot.docs) {
    final userId = userDoc.id;
    final weeklySchedule = Map<String, String>.from(userDoc['weekly_schedule'] ?? {});
    schedules[userId] = weeklySchedule;
  }

  return schedules;
}
