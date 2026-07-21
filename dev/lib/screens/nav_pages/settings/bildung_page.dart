import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class BildungPage extends StatelessWidget {
  const BildungPage({super.key});

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Konnte URL nicht öffnen: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? BColors.backgroundColorDark
          : const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: isDark
            ? BColors.backgroundColorDark
            : const Color(0xFFF2F2F7),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18.sp,
            color: BColors.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Bildungsbereich',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1C1C1E),
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        children: [
          // Intro Banner
          _IntroBanner(
            isDark: isDark,
            onRegister: () => _launch('https://bit.ly/33Kev1R'),
          ),

          // Stats
          _sectionHeader('Auf einen Blick', isDark),
          _statsCard(isDark),

          // Fächer
          _sectionHeader('Unterrichtsfächer', isDark),
          _subjectsCard(isDark),

          // Kontakt & Anmeldung
          _sectionHeader('Kontakt & Anmeldung', isDark),
          _contactCard(isDark),

          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text, bool isDark) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 16.w, 6.h),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12.sp,
          color: Colors.grey.shade500,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _statsCard(bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? BColors.prayerRowDark : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _StatChip(
            value: '~200',
            label: 'Schüler',
            icon: Icons.people_outline,
            isDark: isDark,
          ),
          _StatDivider(isDark: isDark),
          _StatChip(
            value: '5–14',
            label: 'Alter',
            icon: Icons.child_care,
            isDark: isDark,
          ),
          _StatDivider(isDark: isDark),
          _StatChip(
            value: '9',
            label: 'Stufen',
            icon: Icons.layers_outlined,
            isDark: isDark,
          ),
          _StatDivider(isDark: isDark),
          _StatChip(
            value: '2017',
            label: 'Gegründet',
            icon: Icons.history_edu_outlined,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _subjectsCard(bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDark ? BColors.prayerRowDark : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          children: [
            _subjectTile(
              icon: Icons.translate,
              title: 'Arabisch',
              description:
                  'Lesen, Schreiben und Sprechen der arabischen Sprache – aufgeteilt in 3 Vorbereitungs- und 6 Grundstufen.',
              isDark: isDark,
              isLast: false,
            ),
            _subjectTile(
              icon: Icons.menu_book_outlined,
              title: 'Islamische Bildung',
              description:
                  'Grundlagen des islamischen Glaubens und der islamischen Praxis für Kinder und Jugendliche.',
              isDark: isDark,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _subjectTile({
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
    required bool isLast,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: BColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: BColors.primary, size: 20.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade500,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 70,
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.grey.withOpacity(0.15),
          ),
      ],
    );
  }

  Widget _contactCard(bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDark ? BColors.prayerRowDark : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          children: [
            _actionTile(
              icon: Icons.email_outlined,
              title: 'E-Mail schreiben',
              subtitle: 'schule@bbf-verein.de',
              isDark: isDark,
              isLast: false,
              onTap: () => _launch('mailto:schule@bbf-verein.de'),
            ),
            _actionTile(
              icon: Icons.app_registration_outlined,
              title: 'Online anmelden',
              subtitle: 'Anmeldeformular für die Arabisch-Schule',
              isDark: isDark,
              isLast: true,
              onTap: () => _launch('https://bit.ly/33Kev1R'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required bool isLast,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: BColors.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: BColors.primary, size: 20.sp),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1C1C1E),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 22.sp,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 70,
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.grey.withOpacity(0.15),
          ),
      ],
    );
  }
}

// ── Intro Banner ──────────────────────────────────────────────────────────────

class _IntroBanner extends StatelessWidget {
  const _IntroBanner({required this.isDark, required this.onRegister});

  final bool isDark;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [BColors.primary, BColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: BColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.school, color: Colors.white, size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Arabische Schule',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Seit 2017 bietet der BBF-Verein Unterricht in Arabisch und islamischer Bildung für Kinder zwischen 5 und 14 Jahren an.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13.sp,
              height: 1.5,
            ),
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: onRegister,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.app_registration_outlined,
                    color: BColors.primary,
                    size: 16.sp,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Jetzt anmelden',
                    style: TextStyle(
                      color: BColors.primary,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat helpers ──────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.value,
    required this.label,
    required this.icon,
    required this.isDark,
  });

  final String value;
  final String label;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: BColors.primary, size: 20.sp),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1C1C1E),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      width: 1,
      color: isDark
          ? Colors.white.withOpacity(0.08)
          : Colors.grey.withOpacity(0.2),
    );
  }
}
