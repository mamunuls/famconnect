import 'dart:convert';
import 'package:famconnect/app/asset_path.dart';
import 'package:famconnect/features/auth/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  _HomeAppBarState createState() => _HomeAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HomeAppBarState extends State<HomeAppBar> {
  String name = '';
  String email = '';
  String profileImageBase64 = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? storedBase64 = prefs.getString('profileImageBase64');

        if (storedBase64 != null && storedBase64.isNotEmpty) {
          if (mounted) {
            setState(() {
              profileImageBase64 = storedBase64;
            });
          }
        }

        Map<String, dynamic> userData = await AuthService().getUserData(
          user.uid,
        );
        if (mounted) {
          setState(() {
            name = userData['name'] ?? '';
            email = userData['email'] ?? '';
            profileImageBase64 = userData['profileImageBase64'] ?? '';
          });
        }
        if (profileImageBase64.isNotEmpty && storedBase64 == null) {
          await prefs.setString('profileImageBase64', profileImageBase64);
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      toolbarHeight: 100,
      backgroundColor: isDark ? const Color(0xFF121B22) : Color(0XF0F0F0DD),
      flexibleSpace: Container(
        height: 300.0,
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF121B22) : Color(0XF0F0F0DD),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.elliptical(11, 11),
          ),
        ),
      ),
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 20,
            backgroundImage:
                profileImageBase64.isNotEmpty
                    ? MemoryImage(base64Decode(profileImageBase64))
                        as ImageProvider
                    : AssetImage(AssetsPath.defaultProfileImage)
                        as ImageProvider,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello',
                  style: GoogleFonts.dynaPuff(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                Text(
                  name.isNotEmpty ? name : '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              await AuthService().signout(context);
            },
            icon: _buildLottieIcon(AssetsPath.logout),
          ),
        ],
      ),
    );
  }

  Widget _buildLottieIcon(String assetPath) {
    return Lottie.asset(assetPath, width: 35, height: 35);
  }
}
