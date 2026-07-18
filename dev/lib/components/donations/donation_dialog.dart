
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bbf_app/utils/constants/colors.dart';

void showDonationDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? BColors.prayerRowDark : Colors.white;
    final cardBg = isDark ? BColors.backgroundColorDark : const Color(0xFFF3F7F3);
    final labelColor = isDark ? Colors.white : const Color(0xFF111827);
    final subColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    void copyToClipboard(BuildContext ctx, String label, String value) {
      Clipboard.setData(ClipboardData(text: value));
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text('$label kopiert'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    Widget copyRow(BuildContext ctx, String label, String value) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 11.sp,
                          color: subColor,
                          fontWeight: FontWeight.w500)),
                  SizedBox(height: 2.h),
                  Text(value,
                      style: TextStyle(
                          fontSize: 13.sp,
                          color: labelColor,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => copyToClipboard(ctx, label, value),
              child: Container(
                padding: EdgeInsets.all(7.w),
                decoration: BoxDecoration(
                  color: BColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.copy_rounded,
                    size: 15.sp, color: BColors.primary),
              ),
            ),
          ],
        ),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
        child: Builder(builder: (innerCtx) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: subColor.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Header
              Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: const Color(0xffE8F5E9),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: const Icon(Icons.volunteer_activism,
                        color: Color(0xff2E7D32)),
                  ),
                  SizedBox(width: 14.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Deine Spende zählt!',
                          style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w700,
                              color: labelColor)),
                      SizedBox(height: 2.h),
                      Text('Hilf uns die Gemeinde zu stärken',
                          style:
                              TextStyle(fontSize: 12.sp, color: subColor)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 22.h),

              // PayPal card (green gradient like _HeroCard)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  gradient: const LinearGradient(
                    colors: [Color(0xff2E7D32), Color(0xff66BB6A)],
                  ),
                ),
                padding:
                    EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Über PayPal spenden',
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          SizedBox(height: 4.h),
                          Text('Schnell & sicher',
                              style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.white70)),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xff2E7D32),
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 10.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                      ),
                      onPressed: () async {
                        final url = Uri.parse(
                            'https://www.paypal.com/donate/?hosted_button_id=ESTNXJLMMQQQS#');
                        if (!await launchUrl(url,
                            mode: LaunchMode.externalApplication)) {
                          debugPrint('Konnte PayPal nicht öffnen');
                        }
                      },
                      icon: Image.asset('assets/images/PayPalLogo.png',
                          height: 18.h),
                      label: Text('Spenden',
                          style: TextStyle(
                              fontSize: 13.sp, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Divider "oder"
              Row(
                children: [
                  Expanded(
                      child: Divider(color: subColor.withOpacity(0.3))),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Text('oder',
                        style:
                            TextStyle(fontSize: 12.sp, color: subColor)),
                  ),
                  Expanded(
                      child: Divider(color: subColor.withOpacity(0.3))),
                ],
              ),
              SizedBox(height: 16.h),

              // Bank info card (like _ProjectCard)
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                      color: BColors.primary.withOpacity(0.2), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: const Color(0xffE8F5E9),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: const Icon(Icons.account_balance,
                              color: Color(0xff2E7D32), size: 20),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Bildungs- und Begegnungsverein\nFreiburg e.V.',
                            style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: labelColor),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Divider(color: subColor.withOpacity(0.2), height: 1),
                    SizedBox(height: 10.h),
                    copyRow(innerCtx, 'IBAN',
                        'DE11 6805 0101 0014 3501 24'),
                    Divider(color: subColor.withOpacity(0.15), height: 1),
                    copyRow(innerCtx, 'BIC', 'FRSPDE66XXX'),
                    Divider(color: subColor.withOpacity(0.15), height: 1),
                    copyRow(innerCtx, 'Verwendungszweck', 'Spende'),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // Close button
              OutlinedButton(
                onPressed: () => Navigator.pop(sheetCtx),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: subColor.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.symmetric(vertical: 13.h),
                ),
                child: Text('Schließen',
                    style:
                        TextStyle(color: subColor, fontSize: 14.sp)),
              ),
            ],
          );
        }),
      ),
    );
  }