// ignore_for_file: deprecated_member_use

import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class IconCircle extends StatelessWidget {
  const IconCircle({
    super.key,
    required this.icon,
    this.iconSize = 20,
    this.padding = 8,
  });

  final IconData icon;
  final double iconSize;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: BColors.primary.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: BColors.primary, size: iconSize),
    );
  }
}
