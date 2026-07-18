import 'package:bbf_app/utils/constants/colors.dart';
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [BColors.backgroundColorDark, BColors.backgroundColorDark]
                : [BColors.backgroundColor, BColors.backgroundColor],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                SizedBox(height: 24.h),
                const _HeroCard(),
                SizedBox(height: 28.h),
                _sectionTitle("Hauptprojekt", false, null),
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
                  }
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
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
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
                          amount: data['amount'] ?? 0.0,
                          target: data['target'] ?? 0.0,
                          progress: (data['progress'] ?? 0.0).toDouble(),
                          isAdmin: _isUserAdmin,
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
                Container(
                  padding: EdgeInsets.all(18.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.volunteer_activism, color: Color(0xff2E7D32)),
                      SizedBox(width: 12.w),
                      const Expanded(child: Text("Deine Spende hilft. Bitte gebe beim Spenden einen Betreff ein, damit deine Spende zugeordnet werden kann.")),
                      FilledButton(
                        onPressed: () {showDonationDialog(context);},
                        child: const Text("Spende hier"),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, bool showAddButton, VoidCallback? onAddTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32.r),
        gradient: const LinearGradient(colors: [Color(0xff2E7D32), Color(0xff66BB6A)]),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Die Gemeinde für die Zukunft stärken.",
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12.h),
            const Text(
              "Helfe mit unsere Gemeinde zu stärken.",
              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

class _FeaturedProjectCard extends StatelessWidget {
  final double amount;
  final double target;
  final double progress;
  final bool isAdmin;
  final VoidCallback onEditTap;

  const _FeaturedProjectCard({
    required this.amount,
    required this.target,
    required this.progress,
    required this.isAdmin,
    required this.onEditTap,
  });

  String _formatCurrency(double value) {
    return "€${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28.r)),
      child: Column(
        children: [
          Container(
            height: 180.h,
            decoration: BoxDecoration(
              color: const Color(0xffDDE7D8),
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
                      backgroundColor: Colors.white,
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
                    const Expanded(
                      child: Text("Moscheebau", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                    Text(
                      "${(progress * 100).toStringAsFixed(0)}%",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xff2E7D32)),
                    )
                  ],
                ),
                SizedBox(height: 12.h),
                LinearProgressIndicator(value: progress, minHeight: 10),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Text(
                      _formatCurrency(amount),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff2E7D32)),
                    ),
                    const Spacer(),
                    Text("Ziel ${_formatCurrency(target)}")
                  ],
                )
              ],
            ),
          )
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
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProjectCard({
    required this.title,
    required this.description,
    required this.amount,
    required this.target,
    required this.progress,
    required this.isAdmin,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatCurrency(double value) {
    return "€${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24.r)),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 68.w,
                height: 68.h,
                decoration: BoxDecoration(
                  color: const Color(0xffE8F5E9),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: const Icon(Icons.volunteer_activism, color: Color(0xff2E7D32)),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    SizedBox(height: 6.h),
                    Text(description, style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
              if (isAdmin)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Bearbeiten')),
                    const PopupMenuItem(value: 'delete', child: Text('Löschen', style: TextStyle(color: Colors.red))),
                  ],
                ),
            ],
          ),
          SizedBox(height: 14.h),
          LinearProgressIndicator(value: progress, minHeight: 8),
          SizedBox(height: 12.h),
          Row(
            children: [
              Text(_formatCurrency(amount), style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text("Ziel ${_formatCurrency(target)}"),
            ],
          )
        ],
      ),
    );
  }
}