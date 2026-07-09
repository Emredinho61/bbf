// ignore_for_file: deprecated_member_use

import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PickerTile extends StatelessWidget {
  const PickerTile({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.onTap,
    required this.isDark,
    this.selected,
    this.selectedIcon = Icons.check_circle_outline,
  });

  final String label;
  final String hint;
  final IconData icon;
  final IconData selectedIcon;
  final String? selected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final hasValue = selected != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isDark ? BColors.backgroundColorDark : const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: hasValue
                ? BColors.primary.withOpacity(0.6)
                : Colors.grey.withOpacity(0.25),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasValue ? selectedIcon : icon,
              color: hasValue ? BColors.primary : Colors.grey,
              size: 22.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                      color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    selected ?? hint,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: hasValue ? BColors.primary : Colors.grey.shade500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20.sp),
          ],
        ),
      ),
    );
  }
}
