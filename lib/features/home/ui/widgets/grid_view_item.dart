import 'package:flutter/material.dart';

class GridViewItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const GridViewItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(height: 3),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}