import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

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
          'Kontakt',
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
          _sectionHeader('Kontaktmöglichkeiten', isDark),
          _contactCard(isDark),
          _sectionHeader('Häufige Fragen', isDark),
          _FaqCard(isDark: isDark, onLaunch: _launch),
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
            _contactTile(
              icon: Icons.phone_outlined,
              title: 'Ruf uns an',
              subtitle: '+49 761 5951 3138',
              isDark: isDark,
              isLast: false,
              onTap: () => _launch('tel:+4976159513138'),
            ),
            _contactTile(
              icon: Icons.email_outlined,
              title: 'Schreib uns',
              subtitle: 'info@bbf-verein.de',
              isDark: isDark,
              isLast: false,
              onTap: () => _launch('mailto:info@bbf-verein.de'),
            ),
            _contactTile(
              icon: Icons.location_on_outlined,
              title: 'Besuch uns',
              subtitle: 'Rufacherstr. 5, 79110 Freiburg',
              isDark: isDark,
              isLast: true,
              onTap: () => _launch(
                'https://maps.google.com/?q=Rufacherstr.+5,+79110+Freiburg',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactTile({
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
                  width: 36.r,
                  height: 36.r,
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
            indent: 66,
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.grey.withOpacity(0.15),
          ),
      ],
    );
  }
}

// ── FAQ Card ──────────────────────────────────────────────────────────────────

class _FaqCard extends StatelessWidget {
  const _FaqCard({required this.isDark, required this.onLaunch});

  final bool isDark;
  final Future<void> Function(String) onLaunch;

  static const _faqs = [
    _FaqData(
      q: 'Wie kann ich Mitglied in Ihrem Verein werden?',
      a: 'Füllen Sie bitte folgendes Formular aus und schicken Sie es uns zu oder kommen Sie einfach bei uns vorbei.',
      links: [
        _FaqLink(
          'Mitgliedsantrag (PDF)',
          'https://bbfverein.de/wp-content/uploads/2022/02/Mitgliedsantrag-BBF_E-Form.pdf',
        ),
      ],
    ),
    _FaqData(
      q: 'Ist in Ihrem Verein eine Konvertierung zum Islam möglich?',
      a: 'Ja, im BBF-Verein ist eine Konvertierung zum Islam möglich. Bitte kontaktieren Sie uns:',
      links: [
        _FaqLink('beratung@bbf-verein.de', 'mailto:beratung@bbf-verein.de'),
      ],
    ),
    _FaqData(
      q: 'Wie kann ich mein Kind in der Arabisch-Schule anmelden?',
      a: 'Unter folgendem Link können Sie Ihr Kind in der Arabisch-Schule anmelden:',
      links: [
        _FaqLink(
          'Arabisch-Unterricht anmelden',
          'https://docs.google.com/forms/d/1dtCVlQnG9q_QEZIJKn6hrmwdAKrfQCM1d_6KrSD-qJM/viewform?edit_requested=true',
        ),
      ],
    ),
    _FaqData(
      q: 'Wie kann ich mich in der Jugendgruppe anmelden?',
      a: 'Bitte kontaktiere die Jugendgruppe:',
      links: [_FaqLink('jugend@bbf-verein.de', 'mailto:jugend@bbf-verein.de')],
    ),
    _FaqData(
      q: 'Wir brauchen Hilfe bei einer islamischen Bestattung.',
      a: 'Bitte schreiben Sie uns eine E-Mail oder rufen Sie uns an.',
      links: [
        _FaqLink('bestattung@bbf-verein.de', 'mailto:bestattung@bbf-verein.de'),
        _FaqLink('+49 176 2164 9523', 'tel:+4917621649523'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
          children: _faqs.asMap().entries.map((e) {
            return _FaqTile(
              faq: e.value,
              isDark: isDark,
              isLast: e.key == _faqs.length - 1,
              onLaunch: onLaunch,
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── FAQ data models ───────────────────────────────────────────────────────────

class _FaqLink {
  final String label;
  final String url;
  const _FaqLink(this.label, this.url);
}

class _FaqData {
  final String q;
  final String a;
  final List<_FaqLink> links;
  const _FaqData({required this.q, required this.a, this.links = const []});
}

// ── FAQ tile (expandable) ─────────────────────────────────────────────────────

class _FaqTile extends StatefulWidget {
  const _FaqTile({
    required this.faq,
    required this.isDark,
    required this.isLast,
    required this.onLaunch,
  });

  final _FaqData faq;
  final bool isDark;
  final bool isLast;
  final Future<void> Function(String) onLaunch;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: BColors.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _expanded ? Icons.remove : Icons.add,
                    color: BColors.primary,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Text(
                    widget.faq.q,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          Padding(
            padding: EdgeInsets.fromLTRB(66.w, 0, 16.w, 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.faq.a,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                if (widget.faq.links.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  ...widget.faq.links.map(
                    (link) => GestureDetector(
                      onTap: () => widget.onLaunch(link.url),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.open_in_new,
                              size: 13.sp,
                              color: BColors.primary,
                            ),
                            SizedBox(width: 4.w),
                            Flexible(
                              child: Text(
                                link.label,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: BColors.primary,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: BColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        if (!widget.isLast)
          Divider(
            height: 1,
            indent: 66,
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.grey.withOpacity(0.15),
          ),
      ],
    );
  }
}
