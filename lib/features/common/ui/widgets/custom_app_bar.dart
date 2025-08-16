import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      toolbarHeight: 60,
      title: Text(
        widget.title,
        style: GoogleFonts.dynaPuff(
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      backgroundColor: isDark ? const Color(0xFF121B22) : Color(0XF0F0F0DD),
      iconTheme: IconThemeData(
        color: isDark ? Colors.white : Colors.black,
      ),
      elevation: 4,
      flexibleSpace: Container(
        decoration: BoxDecoration(
           color: isDark ? const Color(0xFF121B22) : Color(0XF0F0F0DD),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.elliptical(12, 12),
          ),
        ),
      ),
    );

  }
}
