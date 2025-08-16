

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famconnect/features/core/core_management_screen.dart';
import 'package:famconnect/features/dinner_booking/screen/dinner_booking_screen.dart';
import 'package:famconnect/features/event_create/ui/screen/event_create_screen.dart';
import 'package:famconnect/features/gifts/screens/gift_suggestion_screen.dart';
import 'package:famconnect/features/gps_tracker/screens/family_member_tracking_screen.dart';
import 'package:famconnect/features/gps_tracker/screens/gps_tracker_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:famconnect/app/asset_path.dart';
import 'package:famconnect/features/familychat/ui/screens/family_chat_screen.dart';
import 'package:famconnect/features/home/ui/widgets/bottom_nav_bar_indicator_widget.dart';
import 'package:famconnect/features/home/ui/widgets/grid_view_item.dart';
import 'package:famconnect/features/home/ui/widgets/home_app_bar.dart';
import 'package:famconnect/features/profiles/ui/screens/profile_screen.dart';
import 'package:famconnect/features/profiles/ui/screens/user_schedule_screen.dart';
import 'package:famconnect/features/setting/ui/screen/settings_screen.dart';
import 'package:famconnect/features/familychat/ui/widgets/user_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String name = '/home-screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          _currentUser = UserModel.fromMap(data, uid);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to load user data")));
    }
  }

  Stream<List<Map<String, dynamic>>> fetchNonPastEvents() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return FirebaseFirestore.instance
        .collection('events')
        .where('date', isGreaterThanOrEqualTo: todayStart.toIso8601String())
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                final data = doc.data();
                final isPublic = data['isPublic'] == true;
                final createdBy = data['createdBy'] ?? '';
                if (isPublic || createdBy == currentUserId) {
                  return {'id': doc.id, ...data};
                }
                return null;
              })
              .whereType<Map<String, dynamic>>()
              .toList();
        });
  }

  Widget buildEventCard(Map<String, dynamic> event) {
    final eventDate = DateTime.parse(event['date']);
    final formattedDate = DateFormat('d MMM, yyyy').format(eventDate);
    final formattedTime = DateFormat('hh:mm a').format(eventDate);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'] ?? 'Untitled Event',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "$formattedDate   $formattedTime",
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Icon(Icons.group, color: Colors.orange),
        ],
      ),
    );
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EventCreateScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FamilyChatScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: fetchNonPastEvents(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final events = snapshot.data!;
                final todayEvents = <Map<String, dynamic>>[];
                final upcomingEvents = <Map<String, dynamic>>[];

                for (var event in events) {
                  final eventDate = DateTime.parse(event['date']);
                  final eventDay = DateTime(
                    eventDate.year,
                    eventDate.month,
                    eventDate.day,
                  );

                  if (eventDay == today) {
                    todayEvents.add(event);
                  } else if (eventDay.isAfter(today)) {
                    upcomingEvents.add(event);
                  }
                }

                final limitedTodayEvents = todayEvents.take(2).toList();
                final limitedUpcomingEvents = upcomingEvents.take(2).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Today's Events",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (limitedTodayEvents.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text("No events for today."),
                      )
                    else
                      ...limitedTodayEvents.map(buildEventCard),

                    const SizedBox(height: 20),
                    const Text(
                      "Upcoming Events",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (limitedUpcomingEvents.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text("No upcoming events."),
                      )
                    else
                      ...limitedUpcomingEvents.map(buildEventCard),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(top: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 10,
                ),
                itemCount: 7,
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return GridViewItem(
                        icon: Lottie.asset(
                          AssetsPath.scheduleIcon,
                          height: 70,
                          width: 70,
                        ),
                        label: 'Schedule',
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserScheduleScreen(),
                              ),
                            ),
                      );
                    case 1:
                      return GridViewItem(
                        icon: Lottie.asset(
                          AssetsPath.familyTrackIcon,
                          height: 70,
                          width: 70,
                        ),
                        label: 'Find My Family',
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => FamilyMemberTrackingScreen(),
                              ),
                            ),
                      );
                    case 2:
                      return GridViewItem(
                        icon: Lottie.asset(
                          AssetsPath.locationIcon,
                          height: 70,
                          width: 70,
                        ),
                        label: 'GPS Locator',
                        onTap: () {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        FamilyMapScreen(userId: user.uid),
                              ),
                            );
                          }
                        },
                      );
                      case 3:
                      return GridViewItem(
                        icon: Lottie.asset(
                          AssetsPath.giftSuggestionIcon,
                          height: 70,
                          width: 70,
                        ),
                        label: 'Gift Suggestion',
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GiftSuggestionScreen(),
                              ),
                            ),
                      );
                    case 4:
                      return GridViewItem(
                        icon: Lottie.asset(
                          AssetsPath.choreIcon,
                          height: 70,
                          width: 70,
                        ),
                        label: 'Core Management',
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CoreManagementScreen(),
                              ),
                            ),
                      );
                    case 5:
                      return GridViewItem(
                        icon: Lottie.asset(
                          AssetsPath.dinnerBookIcon,
                          height: 70,
                          width: 70,
                        ),
                        label: 'Dinner Booking',
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AllUsersFreeTimeScreen(),
                              ),
                            ),
                      );
                    default:
                      return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBarWidget(
        currentIndex: _currentIndex,
        onNavBarTapped: _onNavBarTapped,
      ),
    );
  }
}
