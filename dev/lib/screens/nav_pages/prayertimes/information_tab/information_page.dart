// ignore_for_file: deprecated_member_use

import 'package:bbf_app/backend/services/auth_services.dart';
import 'package:bbf_app/backend/services/information_service.dart';
import 'package:bbf_app/backend/services/user_service.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/information_tab/add_information_page.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/information_tab/delete_information_page.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:bbf_app/utils/helper/check_user_helper.dart';
import 'package:bbf_app/utils/helper/information_page_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class InformationPage extends StatefulWidget {
  const InformationPage({super.key});

  @override
  State<InformationPage> createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  final InformationService _informationService = InformationService();
  final InformationPageHelper _informationPageHelper = InformationPageHelper();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final CheckUserHelper _checkUserHelper = CheckUserHelper();

  List<Map<String, dynamic>> _allInformation = [];

  // IDs of text cards currently showing their content
  final Set<String> _expandedIds = {};

  late bool isUserAdmin;

  @override
  void initState() {
    super.initState();
    isUserAdmin = _checkUserHelper.getUsersPrefs();
    _initPage();
  }

  Future<void> _initPage() async {
    await _loadInformation();
    await _informationPageHelper.setTotalInformationNumber(
      _allInformation.length,
    );
    _checkUser();
  }

  Future<void> _loadInformation() async {
    final data = await _informationService.getAllInformation();
    if (!mounted) return;
    setState(() => _allInformation = data);
  }

  Future<void> _checkUser() async {
    if (_authService.currentUser == null) return;
    final value = await _userService.checkIfUserIsAdmin();
    if (mounted) {
      setState(() {
        if (value != isUserAdmin) {
          _checkUserHelper.setCheckUsersPrefs(value);
          isUserAdmin = value;
        }
      });
    }
  }

  bool _isImageType(Map<String, dynamic> info) =>
      (info['type'] as String?) == 'image';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: _allInformation.length + (isUserAdmin ? 1 : 0),
        itemBuilder: (context, index) {
          if (isUserAdmin && index == 0) {
            return _buildAdminRow(context);
          }
          final info = _allInformation[isUserAdmin ? index - 1 : index];
          return _isImageType(info)
              ? _buildImageCard(info, isDark)
              : _buildTextCard(info, isDark);
        },
      ),
    );
  }

  // ── Image card ────────────────────────────────────────────────────────────

  Widget _buildImageCard(Map<String, dynamic> info, bool isDark) {
    final imageUrl = info['Image'] as String? ?? '';
    if (imageUrl.isEmpty) return const SizedBox.shrink();

    // Use the orientation stored at upload time to pick an aspect ratio that
    // shows the image without letter-boxing or cropping important content.
    final orientation = info['orientation'] as String? ?? 'vertical';
    final aspectRatio = orientation == 'horizontal' ? 16 / 9.0 : 3 / 4.0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _FullscreenImagePage(imageUrl: imageUrl),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xff1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.withOpacity(0.35), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Hero(
                tag: imageUrl,
                child: AspectRatio(
                  aspectRatio: aspectRatio,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Skeletonizer(
                      enabled: true,
                      child: Container(color: Colors.grey.shade200),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.broken_image_outlined, size: 48),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Text card ─────────────────────────────────────────────────────────────

  Widget _buildTextCard(Map<String, dynamic> info, bool isDark) {
    final id = info['id'] as String? ?? '';
    final title = info['Titel'] as String? ?? '';
    final text = info['Text'] as String? ?? '';
    final isExpanded = _expandedIds.contains(id);
    final hasText = text.isNotEmpty;

    return GestureDetector(
      onTap: hasText
          ? () => setState(() {
                if (isExpanded) {
                  _expandedIds.remove(id);
                } else {
                  _expandedIds.add(id);
                }
              })
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xff1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.withOpacity(0.35), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xff1a1a1a),
                    ),
                  ),
                ),
                if (hasText)
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.green,
                    size: 24,
                  ),
              ],
            ),
            if (isExpanded && hasText) ...[
              const SizedBox(height: 10),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.65,
                  color: isDark
                      ? Colors.grey.shade300
                      : const Color(0xff374151),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Admin row ─────────────────────────────────────────────────────────────

  Widget _buildAdminRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _iconButton(
            context,
            icon: Icons.delete,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DeleteInformationPage(),
                ),
              );
              if (result == true) _loadInformation();
            },
          ),
          const SizedBox(width: 12),
          _iconButton(
            context,
            icon: Icons.add,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddInformationPage(),
                ),
              );
              if (result == true) _loadInformation();
            },
          ),
        ],
      ),
    );
  }

  Widget _iconButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : BColors.secondary,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: BColors.primary),
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 35, color: BColors.primary),
      ),
    );
  }
}

class _FullscreenImagePage extends StatelessWidget {
  final String imageUrl;

  const _FullscreenImagePage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Pinch-to-zoom image
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Hero(
                tag: imageUrl,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  errorWidget: (context, url, error) => const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
            ),
          ),

          // Close button
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
