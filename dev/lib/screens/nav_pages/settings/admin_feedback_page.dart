// ignore_for_file: deprecated_member_use

import 'package:bbf_app/backend/services/feedback_service.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdminFeedbackPage extends StatefulWidget {
  const AdminFeedbackPage({super.key});

  @override
  State<AdminFeedbackPage> createState() => _AdminFeedbackPageState();
}

class _AdminFeedbackPageState extends State<AdminFeedbackPage> {
  final FeedbackService _feedbackService = FeedbackService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _helpEntries = [];
  List<Map<String, dynamic>> _wishEntries = [];
  List<Map<String, dynamic>> _appEntries = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final grouped = await _feedbackService.getAllFeedback();

    if (mounted) {
      setState(() {
        _helpEntries = grouped['help'] ?? [];
        _wishEntries = grouped['wish'] ?? [];
        _appEntries = grouped['app'] ?? [];
        _isLoading = false;
      });
    }
  }

  String _formatTimestamp(dynamic ts) {
    if (ts == null) return '';
    final dt = (ts as Timestamp).toDate();
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? BColors.backgroundColorDark : const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: isDark ? BColors.prayerRowDark : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C1C1E),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              size: 18.sp, color: BColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Nutzer-Feedback',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1C1C1E),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: BColors.primary, size: 22.sp),
            onPressed: _load,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              color: BColors.primary,
              child: ListView(
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                children: [
                  _Section(
                    icon: Icons.volunteer_activism_outlined,
                    title: 'Wie kann ich helfen?',
                    entries: _helpEntries,
                    showEmail: true,
                    isDark: isDark,
                    formatTimestamp: _formatTimestamp,
                  ),
                  SizedBox(height: 16.h),
                  _Section(
                    icon: Icons.star_outline_rounded,
                    title: 'Was wünschen sich Nutzer?',
                    entries: _wishEntries,
                    showEmail: false,
                    isDark: isDark,
                    formatTimestamp: _formatTimestamp,
                  ),
                  SizedBox(height: 16.h),
                  _Section(
                    icon: Icons.phone_android_outlined,
                    title: 'Was fehlt in der App?',
                    entries: _appEntries,
                    showEmail: false,
                    isDark: isDark,
                    formatTimestamp: _formatTimestamp,
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
    );
  }
}

// ── Section ───────────────────────────────────────────────────────────────────

class _Section extends StatefulWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.entries,
    required this.showEmail,
    required this.isDark,
    required this.formatTimestamp,
  });

  final IconData icon;
  final String title;
  final List<Map<String, dynamic>> entries;
  final bool showEmail;
  final bool isDark;
  final String Function(dynamic) formatTimestamp;

  @override
  State<_Section> createState() => _SectionState();
}

class _SectionState extends State<_Section> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final count = widget.entries.length;

    return Container(
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
      child: Column(
        children: [
          // Section header (tappable)
          InkWell(
            borderRadius: _expanded
                ? BorderRadius.vertical(top: Radius.circular(16.r))
                : BorderRadius.circular(16.r),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: BColors.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child:
                        Icon(widget.icon, color: BColors.primary, size: 18.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: BColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: BColors.primary),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey.shade400,
                    size: 22.sp,
                  ),
                ],
              ),
            ),
          ),

          if (_expanded) ...[
            Divider(
              height: 1,
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.grey.withOpacity(0.15),
            ),
            if (count == 0)
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  'Noch keine Einträge.',
                  style: TextStyle(
                      fontSize: 13.sp, color: Colors.grey.shade400),
                ),
              )
            else
              ...widget.entries.asMap().entries.map((e) {
                final i = e.key;
                final entry = e.value;
                final isLast = i == count - 1;
                return _EntryTile(
                  entry: entry,
                  showEmail: widget.showEmail,
                  isDark: isDark,
                  isLast: isLast,
                  date: widget.formatTimestamp(entry['timestamp']),
                );
              }),
          ],
        ],
      ),
    );
  }
}

// ── Entry tile ────────────────────────────────────────────────────────────────

class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.entry,
    required this.showEmail,
    required this.isDark,
    required this.isLast,
    required this.date,
  });

  final Map<String, dynamic> entry;
  final bool showEmail;
  final bool isDark;
  final bool isLast;
  final String date;

  @override
  Widget build(BuildContext context) {
    final text = entry['text'] as String? ?? '';
    final email = entry['email'] as String? ?? '';

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date
              if (date.isNotEmpty)
                Text(
                  date,
                  style: TextStyle(
                      fontSize: 11.sp, color: Colors.grey.shade400),
                ),
              SizedBox(height: 4.h),
              // Text
              Text(
                text,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark ? Colors.white.withOpacity(0.9) : const Color(0xFF1C1C1E),
                  height: 1.45,
                ),
              ),
              if (showEmail && email.isNotEmpty) ...[
                SizedBox(height: 8.h),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: email));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('E-Mail kopiert: $email'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.email_outlined,
                          size: 14.sp, color: BColors.primary),
                      SizedBox(width: 6.w),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: BColors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: BColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.grey.withOpacity(0.12),
          ),
      ],
    );
  }
}
