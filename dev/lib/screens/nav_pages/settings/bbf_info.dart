import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const _boardMembers = [
    _BoardMember('Abderrahim Jahdari', 'Vorsitzender'),
    _BoardMember('Qais Alketib', 'Stellvertretender Vorsitzender'),
    _BoardMember('Markus Hanser', 'Kassenwart'),
    _BoardMember('Rauia Jahdari', 'Mitglied'),
    _BoardMember('Hamouda Belakhal', 'Mitglied'),
  ];

  static const _goals = [
    'Aktive Teilnahme an der Entwicklung der Gesellschaft in Freiburg und Umgebung.',
    'Förderung der kulturellen und religiösen Begegnungen mit den unterschiedlichen Institutionen der Gesellschaft.',
    'Sich gegenüber der nicht-muslimischen Gesellschaft zu öffnen und die kulturellen Werte des Islams aufzuzeigen.',
    'Planen und durchführen von karitativen und ehrenamtlichen Aktivitäten.',
    'Den Jugendlichen eine Orientierung geben, um Werte des Edels und Tugend zu vermitteln.',
    'Ausbau der institutionellen Arbeit und Förderung der Zusammenarbeit aller Muslime in unserer Stadt.',
    'Den Bedürfnissen der arabischen und muslimischen Gemeinschaft nachzukommen.',
    'Förderung der akademischen und beruflichen Entwicklung sowie Integration.',
  ];

  static const _principles = [
    'Bewahrung der menschlichen, islamischen Werte und Moral.',
    'Umsetzung der toleranten islamischen Prinzipien.',
    'Zielerreichung durch fleißige Arbeit und Ehrgeiz.',
    'Engagement zum Erfolg mit höchster Qualität und Effizienz.',
    'Koordination, Zusammenarbeit, Einigkeit und Einsatz aller Kräfte.',
    'Arbeiten in einem wissenschaftlichen Rahmen für höchste Qualität.',
    'Gute Beziehungen mit allen gesellschaftlichen Partnern pflegen.',
    'Geordnete institutionelle Arbeit durch Planung und Disziplin.',
  ];

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
          'Über Uns',
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
          // Intro banner
          _introBanner(isDark),

          // Geschichte
          _sectionHeader('Geschichte', isDark),
          _infoCard(
            isDark,
            children: [
              _textTile(
                icon: Icons.flag_outlined,
                title: 'Der Anfang',
                body:
                    'Der Bildungs- und Begegnungsverein Freiburg e.V. ist ein unabhängiger, gemeinnütziger Verein, der sich am Gemeinschaftsleben beteiligen möchte. '
                    'Er wurde 2016 von muslimischen Freiburgern gegründet, um eine aktive Rolle auf kultureller, religiöser und gesellschaftlicher Ebene zu spielen '
                    'und um die dringenden Bedürfnisse der muslimischen Gemeinschaft in Freiburg und Umgebung gerecht zu werden.',
                isDark: isDark,
                isLast: false,
              ),
              _textTile(
                icon: Icons.auto_awesome_outlined,
                title: 'Die Identität',
                body:
                    'Der Verein vertritt eine gemäßigte Ansicht, die aus dem Buch Gottes, aus der Lebensgeschichte des Propheten, der „Sunna" '
                    'und am Beispiel der rechtschaffenen Vorgänger hergeleitet ist.',
                isDark: isDark,
                isLast: true,
              ),
            ],
          ),

          // Vision
          _sectionHeader('Vision', isDark),
          _infoCard(
            isDark,
            children: [
              _textTile(
                icon: Icons.visibility_outlined,
                title: 'Die Vision',
                body:
                    'Aufbau und Entwicklung der Gesellschaft sowie die Entwicklung der muslimischen Gemeinschaft in allen Lebensbereichen '
                    'und ihren Mitgliedern ein soziales, kulturelles Umfeld zur Verfügung zu stellen.\n\n'
                    'Der Verein wirkt in Unabhängigkeit von politischen Ausrichtungen und Parteien. '
                    'Er finanziert sich über die Mitgliederbeiträge und Spenden wohltätiger Personen.',
                isDark: isDark,
                isLast: true,
              ),
            ],
          ),

          // Ziele
          _sectionHeader('Unsere Ziele', isDark),
          _bulletCard(isDark, items: _goals),

          // Grundsätze
          _sectionHeader('Unsere Grundsätze', isDark),
          _bulletCard(isDark, items: _principles),

          // Vorstand
          _sectionHeader('Aktueller Vorstand', isDark),
          _boardCard(isDark),

          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  // ── Intro banner ────────────────────────────────────────────────────────────

  Widget _introBanner(bool isDark) {
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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.mosque_outlined,
              color: Colors.white,
              size: 26.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BBF-Verein Freiburg',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Gegründet 2016 · Gemeinnützig · Ehrenamtlich',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section header ──────────────────────────────────────────────────────────

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

  // ── Card wrapper ────────────────────────────────────────────────────────────

  Widget _infoCard(bool isDark, {required List<Widget> children}) {
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
        child: Column(children: children),
      ),
    );
  }

  // ── Text tile (icon + title + body) ─────────────────────────────────────────

  Widget _textTile({
    required IconData icon,
    required String title,
    required String body,
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
                    SizedBox(height: 6.h),
                    Text(
                      body,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade500,
                        height: 1.5,
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

  // ── Bullet list card ────────────────────────────────────────────────────────

  Widget _bulletCard(bool isDark, {required List<String> items}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
        children: items.map((item) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 5.h),
                  child: Container(
                    width: 6.r,
                    height: 6.r,
                    decoration: BoxDecoration(
                      color: BColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isDark
                          ? Colors.white.withOpacity(0.85)
                          : const Color(0xFF3C3C3C),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Board members card ──────────────────────────────────────────────────────

  Widget _boardCard(bool isDark) {
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
          children: _boardMembers.asMap().entries.map((e) {
            final m = e.value;
            final isLast = e.key == _boardMembers.length - 1;
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40.r,
                        height: 40.r,
                        decoration: BoxDecoration(
                          color: BColors.primary.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_outline,
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
                              m.name,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1C1C1E),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              m.role,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey.shade500,
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
          }).toList(),
        ),
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────

class _BoardMember {
  final String name;
  final String role;
  const _BoardMember(this.name, this.role);
}
