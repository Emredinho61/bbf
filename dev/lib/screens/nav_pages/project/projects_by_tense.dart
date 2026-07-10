import 'package:bbf_app/backend/services/projects_service.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:bbf_app/utils/helper/projects_page_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'project_card.dart';

class ProjectsByTense extends StatefulWidget {
  final String tense;
  const ProjectsByTense({super.key, required this.tense});

  @override
  State<ProjectsByTense> createState() => _ProjectsByTenseState();
}

class _ProjectsByTenseState extends State<ProjectsByTense> {
  late List<Map<String, dynamic>> _projects;
  final ProjectsPageHelper _helper = ProjectsPageHelper();
  final ProjectsService _service = ProjectsService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _projects = widget.tense == 'past'
        ? _helper.getPastProjectsFromCache()
        : _helper.getFutureProjectsFromCache();
    _initPage();
  }

  Future<void> _initPage() async {
    final loaded = widget.tense == 'past'
        ? await _service.getPastProjectsFromBackend()
        : await _service.getFutureProjectsFromBackend();

    if (!mounted) return;

    if (loaded != _projects) {
      if (widget.tense == 'past') {
        _helper.setPastProjectsInCache(loaded);
      } else {
        _helper.setFutureProjectsInCache(loaded);
      }
      setState(() {
        _projects = loaded;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading && _projects.isEmpty) {
      return _SkeletonList(isDark: isDark);
    }

    if (!_isLoading && _projects.isEmpty) {
      return _EmptyState(tense: widget.tense, isDark: isDark);
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
      itemCount: _projects.length,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (context, i) {
        final p = _projects[i];
        return Project(
          title: p['title'] as String,
          docId: p['id'] as String,
          year: p['year'] as int,
          month: p['month'] as int,
          day: p['day'] as int,
        );
      },
    );
  }
}

class _SkeletonList extends StatelessWidget {
  const _SkeletonList({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
      itemCount: 3,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (_, __) => _SkeletonCard(isDark: isDark),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final baseColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0);
    final highlightColor =
        isDark ? const Color(0xFF3C3C3C) : const Color(0xFFF5F5F5);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? BColors.prayerRowDark : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 180.h,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Row(
              children: [
                Container(
                  height: 28.h,
                  width: 110.w,
                  decoration: BoxDecoration(
                    color: highlightColor,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                const Spacer(),
                Container(
                  height: 28.h,
                  width: 90.w,
                  decoration: BoxDecoration(
                    color: highlightColor,
                    borderRadius: BorderRadius.circular(20.r),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.tense, required this.isDark});
  final String tense;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            tense == 'future'
                ? Icons.upcoming_outlined
                : Icons.history_outlined,
            size: 64.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            tense == 'future'
                ? 'Keine kommenden Projekte'
                : 'Keine vergangenen Projekte',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Schau später wieder vorbei.',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
