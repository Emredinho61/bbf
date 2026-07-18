import 'package:bbf_app/utils/constants/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bbf_app/screens/nav_pages/donations/upload_donation_project.dart';
import 'package:bbf_app/screens/nav_pages/donations/manage_minor_project_dialog.dart';
import 'package:bbf_app/backend/services/auth_services.dart';
import 'package:bbf_app/backend/services/user_service.dart';
import 'package:bbf_app/utils/helper/check_user_helper.dart';
import 'package:bbf_app/components/donations/donation_dialog.dart';

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
      await FirebaseFirestore.instance.collection('minor_projects').doc(id).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Projekt gelöscht.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Löschen: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? BColors.backgroundColorDark : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),

              // Header
              Text(
                'Spenden',
                style: TextStyle(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Unterstütze unsere Projekte',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
              ),

              SizedBox(height: 20.h),
              const _HeroCard(),
              SizedBox(height: 28.h),

              _sectionTitle("Hauptprojekt", false, null, isDark),
              SizedBox(height: 14.h),

              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
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

                  return _FeaturedProjectCard(
                    amount: amount,
                    target: target,
                    progress: progress,
                    isAdmin: _isUserAdmin,
                    isDark: isDark,
                    onEditTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => const EditHauptprojektDialog(),
                      );
                    },
                  );
                },
              ),

              SizedBox(height: 28.h),

              _sectionTitle(
                "Kleinere Projekte",
                _isUserAdmin,
                () {
                  showDialog(
                    context: context,
                    builder: (context) => const ManageMinorProjectDialog(),
                  );
                },
                isDark,
              ),
              SizedBox(height: 14.h),

              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('minor_projects')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Text(
                        "Keine kleineren Projekte vorhanden.",
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                          fontSize: 14.sp,
                        ),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    separatorBuilder: (context, index) => SizedBox(height: 14.h),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data();

                      return _ProjectCard(
                        title: data['title'] ?? '',
                        description: data['description'] ?? '',
                        amount: (data['amount'] ?? 0.0).toDouble(),
                        target: (data['target'] ?? 0.0).toDouble(),
                        progress: (data['progress'] ?? 0.0).toDouble(),
                        isAdmin: _isUserAdmin,
                        isDark: isDark,
                        iconCodePoint: data['iconCodePoint'] as int?,
                        imageUrl: data['imageUrl'] as String?,
                        onEdit: () {
                          showDialog(
                            context: context,
                            builder: (context) => ManageMinorProjectDialog(projectDoc: doc),
                          );
                        },
                        onDelete: () => _deleteMinorProject(doc.id),
                      );
                    },
                  );
                },
              ),

              SizedBox(height: 24.h),

              // CTA card
              Container(
                padding: EdgeInsets.all(18.w),
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
                child: Row(
                  children: [
                    const Icon(Icons.volunteer_activism, color: Color(0xff2E7D32)),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        "Deine Spende hilft. Bitte gebe beim Spenden einen Betreff ein, damit deine Spende zugeordnet werden kann.",
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade300 : Colors.black87,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    FilledButton(
                      onPressed: () => showDonationDialog(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xff2E7D32),
                      ),
                      child: const Text("Spenden"),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, bool showAddButton, VoidCallback? onAddTap, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1C1C1E),
          ),
        ),
        if (showAddButton)
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xff2E7D32)),
            onPressed: onAddTap,
          ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        gradient: const LinearGradient(
          colors: [Color(0xff2E7D32), Color(0xff66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              "BBF Freiburg",
              style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            "Die Gemeinde für\ndie Zukunft stärken.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Helfe mit, unsere Gemeinde zu stärken.",
            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13.sp),
          ),
        ],
      ),
    );
  }
}

class _FeaturedProjectCard extends StatelessWidget {
  final double amount;
  final double target;
  final double progress;
  final bool isAdmin;
  final bool isDark;
  final VoidCallback onEditTap;

  const _FeaturedProjectCard({
    required this.amount,
    required this.target,
    required this.progress,
    required this.isAdmin,
    required this.isDark,
    required this.onEditTap,
  });

  String _formatCurrency(double value) {
    return "€${value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    )}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? BColors.prayerRowDark : Colors.white,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        children: [
          Container(
            height: 160.h,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D3748) : const Color(0xffDDE7D8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            ),
            child: Stack(
              children: [
                const Center(child: Icon(Icons.mosque, size: 80, color: Color(0xff2E7D32))),
                if (isAdmin)
                  Positioned(
                    top: 12.h,
                    right: 12.w,
                    child: CircleAvatar(
                      backgroundColor: isDark ? BColors.prayerRowDark : Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xff2E7D32)),
                        onPressed: onEditTap,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Moscheebau",
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                        ),
                      ),
                    ),
                    Text(
                      "${(progress * 100).toStringAsFixed(0)}%",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff2E7D32),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: isDark ? const Color(0xFF2D3748) : const Color(0xFFE8F5E9),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff2E7D32)),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Text(
                      _formatCurrency(amount),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "Ziel ${_formatCurrency(target)}",
                      style: TextStyle(
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
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

  const _ProjectCard({
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

  String _formatCurrency(double value) {
    return "€${value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    )}";
  }

  Widget _buildIcon() {
    final icon = iconCodePoint != null
        ? IconData(iconCodePoint!, fontFamily: 'MaterialIcons')
        : Icons.volunteer_activism;
    return Container(
      width: 52.w,
      height: 52.h,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D3748) : const Color(0xffE8F5E9),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Icon(icon, color: const Color(0xff2E7D32)),
    );
  }

  void _openDetail(BuildContext context) {
    Navigator.push(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openDetail(context),
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        padding: EdgeInsets.all(18.w),
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
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIcon(),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                          color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAdmin)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Bearbeiten')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Löschen', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
              ],
            ),
            SizedBox(height: 14.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: isDark ? const Color(0xFF2D3748) : const Color(0xFFE8F5E9),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff2E7D32)),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Text(
                  _formatCurrency(amount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                  ),
                ),
                const Spacer(),
                Text(
                  "Ziel ${_formatCurrency(target)}",
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
      NetworkImage(url).resolve(const ImageConfiguration()).addListener(
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

  String _formatCurrency(double value) {
    return "€${value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    )}";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasImage = widget.imageUrl != null && widget.imageUrl!.isNotEmpty;
    final icon = widget.iconCodePoint != null
        ? IconData(widget.iconCodePoint!, fontFamily: 'MaterialIcons')
        : Icons.volunteer_activism;
    final percent = (widget.progress * 100).clamp(0.0, 100.0).toStringAsFixed(0);
    // Default to 16:9 while detecting; switch to 3:4 once portrait is confirmed
    final aspectRatio = (_isHorizontal == false) ? 3.0 / 4.0 : 16.0 / 9.0;
    const cardOverlap = 60.0;

    return Scaffold(
      backgroundColor: isDark ? BColors.backgroundColorDark : const Color(0xFFF5F7FA),
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
                              horizontal: 20.w, vertical: 16.h),
                          decoration: BoxDecoration(
                            color: isDark ? BColors.prayerRowDark : Colors.white,
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
                            _formatCurrency(widget.amount),
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
                                horizontal: 12.w, vertical: 4.h),
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
                              Color(0xff2E7D32)),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Ziel ${_formatCurrency(widget.target)}",
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
                              color:
                                  const Color(0xff2E7D32).withOpacity(0.12),
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
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
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
