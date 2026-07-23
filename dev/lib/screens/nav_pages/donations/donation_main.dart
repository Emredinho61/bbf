// ignore_for_file: deprecated_member_use

import 'package:bbf_app/backend/services/auth_services.dart';
import 'package:bbf_app/backend/services/user_service.dart';
import 'package:bbf_app/components/donations/donation_dialog.dart';
import 'package:bbf_app/screens/nav_pages/donations/manage_minor_project_dialog.dart';
import 'package:bbf_app/screens/nav_pages/donations/upload_donation_project.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:bbf_app/utils/helper/check_user_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// All icons selectable in the minor-project picker — listed by name so the
// tree shaker can include them. Looked up at runtime via codePoint.
final _kProjectIcons = <int, IconData>{
  Icons.volunteer_activism.codePoint: Icons.volunteer_activism,
  Icons.mosque.codePoint: Icons.mosque,
  Icons.school.codePoint: Icons.school,
  Icons.group.codePoint: Icons.group,
  Icons.favorite.codePoint: Icons.favorite,
  Icons.local_hospital.codePoint: Icons.local_hospital,
  Icons.restaurant.codePoint: Icons.restaurant,
  Icons.home.codePoint: Icons.home,
  Icons.child_care.codePoint: Icons.child_care,
  Icons.elderly.codePoint: Icons.elderly,
  Icons.book.codePoint: Icons.book,
  Icons.water.codePoint: Icons.water,
  Icons.eco.codePoint: Icons.eco,
  Icons.sports_soccer.codePoint: Icons.sports_soccer,
  Icons.construction.codePoint: Icons.construction,
  Icons.attach_money.codePoint: Icons.attach_money,
  Icons.healing.codePoint: Icons.healing,
  Icons.star.codePoint: Icons.star,
  Icons.people.codePoint: Icons.people,
  Icons.flash_on.codePoint: Icons.flash_on,
};

IconData _resolveIcon(int? codePoint) =>
    _kProjectIcons[codePoint] ?? Icons.volunteer_activism;

String _fmt(double value) {
  return "€${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}";
}

// ── Overview ──────────────────────────────────────────────────────────────────

class DonationOverview extends StatefulWidget {
  const DonationOverview({super.key});

  @override
  State<DonationOverview> createState() => _DonationOverviewState();
}

class _DonationOverviewState extends State<DonationOverview> {
  final _checkUser = CheckUserHelper();
  final _auth = AuthService();
  final _userService = UserService();

  bool _isUserAdmin = false;

  @override
  void initState() {
    super.initState();
    _isUserAdmin = _checkUser.getUsersPrefs();
    _checkAdmin();
  }

  void _checkAdmin() async {
    if (_auth.currentUser == null) return;
    final isAdmin = await _userService.checkIfUserIsAdmin();
    if (!mounted) return;
    setState(() {
      if (isAdmin != _isUserAdmin) {
        _checkUser.setCheckUsersPrefs(isAdmin);
        _isUserAdmin = isAdmin;
      }
    });
  }

  Future<void> _deleteMinorProject(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('minor_projects')
          .doc(id)
          .delete();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Projekt gelöscht.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fehler beim Löschen: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? BColors.backgroundColorDark
          : const Color(0xFFF2F4F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 40.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Page header ─────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 24.h, 20.w, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Spenden',
                            style: TextStyle(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1C1C1E),
                              letterSpacing: -0.6,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            'Gemeinsam Großes bewegen',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => showDonationDialog(context),
                      icon: const Icon(Icons.volunteer_activism, size: 16),
                      label: const Text('Spenden'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xff2E7D32),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 11.h,
                        ),
                        textStyle: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // ── Donation hint ────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _DonationHintCard(isDark: isDark),
              ),

              SizedBox(height: 20.h),

              // ── Main project card ────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('projects')
                      .doc('hauptprojekt')
                      .snapshots(),
                  builder: (context, snapshot) {
                    double amount = 1440000.0;
                    double target = 2000000.0;
                    double progress = 0.72;

                    if (snapshot.hasData && snapshot.data!.exists) {
                      final data = snapshot.data!.data();
                      if (data != null) {
                        amount = (data['amount'] ?? amount).toDouble();
                        target = (data['target'] ?? target).toDouble();
                        progress = (data['progress'] ?? progress).toDouble();
                      }
                    }

                    return _MainProjectCard(
                      amount: amount,
                      target: target,
                      progress: progress,
                      isAdmin: _isUserAdmin,
                      isDark: isDark,
                      onEditTap: () => showDialog(
                        context: context,
                        builder: (_) => const EditHauptprojektDialog(),
                      ),
                      onDonateTap: () => showDonationDialog(context),
                    );
                  },
                ),
              ),

              SizedBox(height: 36.h),

              // ── Minor projects header ────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  children: [
                    Text(
                      'Weitere Projekte',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    if (_isUserAdmin)
                      GestureDetector(
                        onTap: () => showDialog(
                          context: context,
                          builder: (_) => const ManageMinorProjectDialog(),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xff2E7D32).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.add,
                                size: 14,
                                color: Color(0xff2E7D32),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Hinzufügen',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xff2E7D32),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: 14.h),

              // ── Minor project list ───────────────────────────────────────
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('minor_projects')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.h),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 16.h,
                      ),
                      child: _EmptyMinorProjects(isDark: isDark),
                    );
                  }

                  final docs = snapshot.data!.docs;
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data();
                      return _MinorProjectCard(
                        title: data['title'] ?? '',
                        description: data['description'] ?? '',
                        amount: (data['amount'] ?? 0.0).toDouble(),
                        target: (data['target'] ?? 0.0).toDouble(),
                        progress: (data['progress'] ?? 0.0).toDouble(),
                        isAdmin: _isUserAdmin,
                        isDark: isDark,
                        iconCodePoint: data['iconCodePoint'] as int?,
                        imageUrl: data['imageUrl'] as String?,
                        onEdit: () => showDialog(
                          context: context,
                          builder: (_) =>
                              ManageMinorProjectDialog(projectDoc: doc),
                        ),
                        onDelete: () => _deleteMinorProject(doc.id),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Main project card ─────────────────────────────────────────────────────────

class _MainProjectCard extends StatelessWidget {
  const _MainProjectCard({
    required this.amount,
    required this.target,
    required this.progress,
    required this.isAdmin,
    required this.isDark,
    required this.onEditTap,
    required this.onDonateTap,
  });

  final double amount;
  final double target;
  final double progress;
  final bool isAdmin;
  final bool isDark;
  final VoidCallback onEditTap;
  final VoidCallback onDonateTap;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).clamp(0.0, 100.0);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? BColors.prayerRowDark : Colors.white,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        children: [
          // ── Gradient hero area ───────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            child: Container(
              height: 200.h,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff1B5E20),
                    Color(0xff2E7D32),
                    Color(0xff388E3C),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    right: -40,
                    top: -40,
                    child: Container(
                      width: 180.r,
                      height: 180.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 40,
                    bottom: -60,
                    child: Container(
                      width: 140.r,
                      height: 140.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -20,
                    bottom: -20,
                    child: Container(
                      width: 100.r,
                      height: 100.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.04),
                      ),
                    ),
                  ),

                  // Top row: chip + edit
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 14.h,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            'BBF Freiburg',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (isAdmin)
                          GestureDetector(
                            onTap: onEditTap,
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.edit_outlined,
                                color: Colors.white,
                                size: 16.sp,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Centered icon + label
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.mosque,
                          size: 60.sp,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'Moscheebau',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Hauptprojekt',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Progress & CTA ───────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label + %
                Row(
                  children: [
                    Text(
                      'Fortschritt',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xff2E7D32).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        '${percent.toStringAsFixed(0)}% erreicht',
                        style: const TextStyle(
                          color: Color(0xff2E7D32),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: isDark
                        ? const Color(0xFF2D3748)
                        : const Color(0xFFE8F5E9),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xff2E7D32),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Amount row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _fmt(amount),
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1C1C1E),
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'gesammelt',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _fmt(target),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.grey.shade300
                                : const Color(0xFF3D3D3D),
                          ),
                        ),
                        Text(
                          'Ziel',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // CTA button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onDonateTap,
                    icon: const Icon(Icons.volunteer_activism, size: 18),
                    label: const Text('Jetzt spenden'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xff2E7D32),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      textStyle: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Minor project card ────────────────────────────────────────────────────────

class _MinorProjectCard extends StatelessWidget {
  const _MinorProjectCard({
    required this.title,
    required this.description,
    required this.amount,
    required this.target,
    required this.progress,
    required this.isAdmin,
    required this.isDark,
    this.iconCodePoint,
    this.imageUrl,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final String description;
  final double amount;
  final double target;
  final double progress;
  final bool isAdmin;
  final bool isDark;
  final int? iconCodePoint;
  final String? imageUrl;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final icon = iconCodePoint != null
        ? _resolveIcon(iconCodePoint)
        : Icons.volunteer_activism;
    final percent = (progress * 100).clamp(0.0, 100.0);

    return Material(
      color: isDark ? BColors.prayerRowDark : Colors.white,
      borderRadius: BorderRadius.circular(20.r),
      elevation: isDark ? 0 : 0,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProjectDetailPage(
              title: title,
              description: description,
              amount: amount,
              target: target,
              progress: progress,
              imageUrl: imageUrl,
              iconCodePoint: iconCodePoint,
            ),
          ),
        ),
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 54.r,
                  height: 54.r,
                  decoration: BoxDecoration(
                    color: const Color(0xff2E7D32).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xff2E7D32),
                    size: 26.sp,
                  ),
                ),
                SizedBox(width: 14.w),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1C1C1E),
                              ),
                            ),
                          ),
                          if (isAdmin)
                            PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.more_horiz,
                                size: 18.sp,
                                color: Colors.grey.shade400,
                              ),
                              onSelected: (v) {
                                if (v == 'edit') onEdit();
                                if (v == 'delete') onDelete();
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Bearbeiten'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text(
                                    'Löschen',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      if (description.isNotEmpty) ...[
                        SizedBox(height: 3.h),
                        Text(
                          description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                      SizedBox(height: 10.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6.r),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: isDark
                              ? const Color(0xFF2D3748)
                              : const Color(0xFFE8F5E9),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xff2E7D32),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Text(
                            _fmt(amount),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1C1C1E),
                            ),
                          ),
                          Text(
                            ' · Ziel ${_fmt(target)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${percent.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
                  size: 22.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyMinorProjects extends StatelessWidget {
  const _EmptyMinorProjects({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 48.sp,
              color: isDark ? Colors.white24 : Colors.grey.shade300,
            ),
            SizedBox(height: 12.h),
            Text(
              'Keine weiteren Projekte',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white38 : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Donation hint card ────────────────────────────────────────────────────────

class _DonationHintCard extends StatelessWidget {
  const _DonationHintCard({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: const Color(0xff2E7D32).withOpacity(isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xff2E7D32).withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: const Color(0xff2E7D32).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xff2E7D32),
              size: 20,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hinweis',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                    color: const Color(0xff2E7D32),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Bitte gib beim Spenden einen Betreff an, damit deine Spende einem Projekt zugeordnet werden kann.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Project detail page ───────────────────────────────────────────────────────

class ProjectDetailPage extends StatefulWidget {
  final String title;
  final String description;
  final double amount;
  final double target;
  final double progress;
  final String? imageUrl;
  final int? iconCodePoint;

  const ProjectDetailPage({
    super.key,
    required this.title,
    required this.description,
    required this.amount,
    required this.target,
    required this.progress,
    this.imageUrl,
    this.iconCodePoint,
  });

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  bool? _isHorizontal; // null = still detecting

  @override
  void initState() {
    super.initState();
    final url = widget.imageUrl;
    if (url != null && url.isNotEmpty) {
      NetworkImage(url)
          .resolve(const ImageConfiguration())
          .addListener(
            ImageStreamListener((info, _) {
              if (mounted) {
                setState(() {
                  _isHorizontal = info.image.width >= info.image.height;
                });
              }
            }),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasImage = widget.imageUrl != null && widget.imageUrl!.isNotEmpty;
    final icon = widget.iconCodePoint != null
        ? _resolveIcon(widget.iconCodePoint)
        : Icons.volunteer_activism;
    final percent = (widget.progress * 100)
        .clamp(0.0, 100.0)
        .toStringAsFixed(0);
    final aspectRatio = (_isHorizontal == false) ? 3.0 / 4.0 : 16.0 / 9.0;
    const cardOverlap = 60.0;

    return Scaffold(
      backgroundColor: isDark
          ? BColors.backgroundColorDark
          : const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section with floating title card
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16.w,
                    MediaQuery.of(context).padding.top + 8.h,
                    16.w,
                    0,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Image / icon placeholder
                      ClipRRect(
                        borderRadius: BorderRadius.circular(28.r),
                        child: hasImage
                            ? AspectRatio(
                                aspectRatio: aspectRatio,
                                child: CachedNetworkImage(
                                  imageUrl: widget.imageUrl!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  placeholder: (_, __) => Container(
                                    color: isDark
                                        ? const Color(0xFF2D3748)
                                        : const Color(0xffDDE7D8),
                                  ),
                                  errorWidget: (_, __, ___) =>
                                      _iconHero(icon, isDark, aspectRatio),
                                ),
                              )
                            : _iconHero(icon, isDark, 16.0 / 9.0),
                      ),

                      // Gradient overlay
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28.r),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: const [0.45, 1.0],
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.55),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Floating title card
                      Positioned(
                        bottom: -cardOverlap,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 16.h,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? BColors.prayerRowDark
                                : Colors.white,
                            borderRadius: BorderRadius.circular(22.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.09),
                                blurRadius: 28,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1C1C1E),
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Container(
                                height: 3.h,
                                width: 38.w,
                                decoration: BoxDecoration(
                                  color: const Color(0xff2E7D32),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: cardOverlap + 20),

                // Progress card
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: isDark ? BColors.prayerRowDark : Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _fmt(widget.amount),
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1C1C1E),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xff2E7D32).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              "$percent% erreicht",
                              style: const TextStyle(
                                color: Color(0xff2E7D32),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: LinearProgressIndicator(
                          value: widget.progress,
                          minHeight: 10,
                          backgroundColor: isDark
                              ? const Color(0xFF2D3748)
                              : const Color(0xFFE8F5E9),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xff2E7D32),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Ziel ${_fmt(widget.target)}",
                          style: TextStyle(
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Description card
                Container(
                  margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 32.h),
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: isDark
                        ? BColors.prayerRowDark
                        : const Color(0xFFF5F5F4),
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: const Color(0xff2E7D32).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              Icons.description_outlined,
                              color: const Color(0xff2E7D32),
                              size: 18.sp,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            'Beschreibung',
                            style: TextStyle(
                              color: const Color(0xff2E7D32),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      Divider(color: Colors.grey.withOpacity(0.18), height: 1),
                      SizedBox(height: 16.h),
                      Text(
                        widget.description,
                        style: TextStyle(
                          fontSize: 15.sp,
                          height: 1.7,
                          color: isDark
                              ? Colors.grey.shade200
                              : const Color(0xFF1C1C1E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Back button overlaid on top
          Positioned(
            top: MediaQuery.of(context).padding.top + 16.h,
            left: 28.w,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconHero(IconData icon, bool isDark, double aspectRatio) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        color: isDark ? const Color(0xFF2D3748) : const Color(0xffDDE7D8),
        child: Center(
          child: Icon(icon, size: 80, color: const Color(0xff2E7D32)),
        ),
      ),
    );
  }
}
