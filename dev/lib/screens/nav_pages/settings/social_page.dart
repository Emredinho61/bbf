import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialPage extends StatelessWidget {
  const SocialPage({super.key});

  static const _services = [
    _Service(
      icon: Icons.article_outlined,
      title: 'Aufenthaltsberatung',
      description:
          'Unterstützung bei Asylverfahren und Aufenthaltstiteln durch eine arabisch- und deutschsprachige Sozialarbeiterin.',
      email: 'aufenthaltsberatung@bbf-verein.de',
    ),
    _Service(
      icon: Icons.favorite_outline,
      title: 'Eheberatung',
      description:
          'Ein arabisch- und deutschsprachiges Ehepaar berät unter Berücksichtigung islamischer Riten und kultureller Gegebenheiten.',
      email: 'eheberatung@bbf-verein.de',
    ),
    _Service(
      icon: Icons.school_outlined,
      title: 'Schulberatung',
      description:
          'Elternbegleiterinnen bauen eine Brücke zwischen Schule und Familie und unterstützen bei schulischen Fragen.',
      email: 'schulberatung@bbf-verein.de',
    ),
    _Service(
      icon: Icons.work_outline,
      title: 'Berufsberatung',
      description:
          'Unterstützung bei Berufsorientierung und Qualifikationsmöglichkeiten – insbesondere für Frauen und Jugendliche.',
      email: 'berufsberatung@bbf-verein.de',
    ),
    _Service(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Schuldnerberatung',
      description:
          'Hilfe zur Verbesserung der finanziellen Situation und langfristiger wirtschaftlicher Stabilität.',
      email: 'schuldnerberatung@bbf-verein.de',
    ),
    _Service(
      icon: Icons.family_restroom,
      title: 'Jugend- & Familienberatung',
      description:
          'Eine Psychologin mit interkultureller Kompetenz begleitet Jugendliche und Familien bei persönlichen Herausforderungen.',
      email: 'familienberatung@bbf-verein.de',
    ),
    _Service(
      icon: Icons.eco_outlined,
      title: 'Ernährungsberatung',
      description:
          'Beratung zu Ernährung, Diäten und sinnvollen Nahrungsergänzungen für ein gesundes Leben.',
      email: 'ernaehrungsberatung@bbf-verein.de',
    ),
    _Service(
      icon: Icons.spa_outlined,
      title: 'Bestattungsberatung',
      description:
          'Waschung des Verstorbenen und Begleitung nach islamischen Ritualen – einfühlsam und würdevoll.',
      email: 'bestattung@bbf-verein.de',
      phone: '+4917621649523',
    ),
  ];

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
          'Soziale Arbeit',
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
          _IntroBanner(
            isDark: isDark,
            onContact: () => _launch('mailto:sozial@bbf-verein.de'),
          ),
          _sectionHeader('Unsere Angebote', isDark),
          _servicesCard(isDark),
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

  Widget _servicesCard(bool isDark) {
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
          children: _services.asMap().entries.map((e) {
            final s = e.value;
            final isLast = e.key == _services.length - 1;
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
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
                        child: Icon(
                          s.icon,
                          color: BColors.primary,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.title,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1C1C1E),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              s.description,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey.shade500,
                                height: 1.45,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            // Email link
                            _ContactLink(
                              icon: Icons.email_outlined,
                              label: s.email,
                              url: 'mailto:${s.email}',
                              onLaunch: _launch,
                            ),
                            // Optional phone link
                            if (s.phone != null) ...[
                              SizedBox(height: 4.h),
                              _ContactLink(
                                icon: Icons.phone_outlined,
                                label: s.phone!
                                    .replaceFirst('+49', '+49 ')
                                    .replaceFirst('176', '176 '),
                                url: 'tel:${s.phone}',
                                onLaunch: _launch,
                              ),
                            ],
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
          }).toList(),
        ),
      ),
    );
  }
}

// ── Contact link row ──────────────────────────────────────────────────────────

class _ContactLink extends StatelessWidget {
  const _ContactLink({
    required this.icon,
    required this.label,
    required this.url,
    required this.onLaunch,
  });

  final IconData icon;
  final String label;
  final String url;
  final Future<void> Function(String) onLaunch;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onLaunch(url),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: BColors.primary),
          SizedBox(width: 5.w),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: BColors.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: BColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Intro Banner ──────────────────────────────────────────────────────────────

class _IntroBanner extends StatelessWidget {
  const _IntroBanner({required this.isDark, required this.onContact});

  final bool isDark;
  final VoidCallback onContact;

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
                child: Icon(
                  Icons.volunteer_activism,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Soziale Arbeit im BBF-Verein',
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
            'Wir bieten Beratung und Unterstützung in verschiedenen Lebensbereichen – ehrenamtlich und kostenfrei.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13.sp,
              height: 1.5,
            ),
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: onContact,
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
                    Icons.email_outlined,
                    color: BColors.primary,
                    size: 16.sp,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Allgemeine Anfrage',
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

// ── Data model ────────────────────────────────────────────────────────────────

class _Service {
  final IconData icon;
  final String title;
  final String description;
  final String email;
  final String? phone;

  const _Service({
    required this.icon,
    required this.title,
    required this.description,
    required this.email,
    this.phone,
  });
}
