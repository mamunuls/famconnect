import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famconnect/features/common/ui/widgets/custom_app_bar.dart';
import 'package:famconnect/features/event_create/ui/screen/event_create_screen.dart';
import 'package:famconnect/features/familychat/ui/screens/chat_room_screen.dart';
import 'package:famconnect/features/home/ui/screens/home_screen.dart';
import 'package:famconnect/features/home/ui/widgets/bottom_nav_bar_indicator_widget.dart';
import 'package:famconnect/features/profiles/ui/screens/profile_screen.dart';
import 'package:famconnect/features/setting/ui/screen/settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FamilyChatScreen extends StatefulWidget {
  const FamilyChatScreen({super.key});

  @override
  State<FamilyChatScreen> createState() => _FamilyChatScreenState();
}

class _FamilyChatScreenState extends State<FamilyChatScreen> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  int _currentIndex = 2;

  void _onNavBarTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EventCreateScreen()),
      );
        break;
      case 2:
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
  void initState() {
    super.initState();
    _createFamilyGroupIfNeeded();
  }

  Future<void> _createFamilyGroupIfNeeded() async {
    final groupDoc = FirebaseFirestore.instance.collection('group_chats').doc('family_group');
    final groupSnapshot = await groupDoc.get();

    if (!groupSnapshot.exists) {
      final allUsersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      final allUserIds = allUsersSnapshot.docs.map((doc) => doc.id).toList();

      await groupDoc.set({
        'groupName': 'Family Group',
        'members': allUserIds,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  void _openGroupChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomScreen(
          roomId: 'family_group_id',
          chatTitle: 'Family Group',
          isGroup: true,
        ),
      ),
    );

  }

  void _openPrivateChat(String uid, String name) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final chatId = _generateChatId(currentUser.uid, uid);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomScreen(
          roomId: chatId,
          chatTitle: name,
          isGroup: false,
          receiveId: uid,
        ),
      ),
    );
  }

  String _generateChatId(String id1, String id2) {
    return id1.hashCode <= id2.hashCode ? '$id1\_$id2' : '$id2\_$id1';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Family Chat'),
      body: Column(
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.group)),
            title: const Text('Family Group Chat'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _openGroupChat,
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Family Members', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final users = snapshot.data!.docs.where((doc) => doc.id != currentUser.uid).toList();
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(user['name']),
                      onTap: () => _openPrivateChat(user.id, user['name']),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBarWidget(
        currentIndex: _currentIndex,
        onNavBarTapped: _onNavBarTapped,
      ),
    );
  }
}

