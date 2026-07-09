import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DonationOverview extends StatelessWidget {
  const DonationOverview({super.key});

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
                      ? [
                          BColors.backgroundColorDark,
                          BColors.backgroundColorDark,
                        ]
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

              _sectionTitle("Hauptprojekt"),

              SizedBox(height: 14.h),

              const _FeaturedProjectCard(),

              SizedBox(height: 28.h),

              _sectionTitle("Kleinere Projekte"),

              SizedBox(height: 14.h),

              const _ProjectCard(
                title: "Klimanlagen modernisieren",
                description:
                    "In diesem Projekt soll eine Klimaanlage modernisiert werden.",
                amount: "€12,400",
                target: "€20,000",
                progress: .62,
              ),

              SizedBox(height: 14.h),

              const _ProjectCard(
                title: "Küche",
                description:
                    "Der Verein hat derzeit keine Küche in der Ahmet und ich kochen können.",
                amount: "€12,000",
                target: "€35,000",
                progress: .45,
              ),

              SizedBox(height: 14.h),

              const _ProjectCard(
                title: "Islamische Schule",
                description:
                    "Islamische Schule um die nöchste Generation Mujaheds auszubilden.",
                amount: "€5",
                target: "€1000",
                progress: .005,
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
                    const Icon(
                      Icons.volunteer_activism,
                      color: Color(0xff2E7D32),
                    ),
                    SizedBox(width: 12.w),
                    const Expanded(
                      child: Text(
                        "Let's make bbf great again..",
                      ),
                    ),
                    FilledButton(
                      onPressed: () {},
                      child: const Text("Spende hier"),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),)
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
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
        gradient: const LinearGradient(
          colors: [
            Color(0xff2E7D32),
            Color(0xff66BB6A),
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Die Gemeinde für die Zukunft stärken.",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            const Text(
              "Helfe mit unsere Gemeinde zu stärken.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24.h),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              onPressed: () {},
              icon: const Icon(
                Icons.favorite,
                color: Color(0xff2E7D32),
              ),
              label: const Text(
                "Hier Spenden",
                style: TextStyle(
                  color: Color(0xff2E7D32),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _FeaturedProjectCard extends StatelessWidget {
  const _FeaturedProjectCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28.r),
      ),
      child: Column(
        children: [
          Container(
            height: 180.h,
            decoration: BoxDecoration(
              color: const Color(0xffDDE7D8),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28.r),
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.mosque,
                size: 80,
                color: Color(0xff2E7D32),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                const Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Moscheebau",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      "72%",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff2E7D32),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 12.h),
                const LinearProgressIndicator(
                  value: .72,
                  minHeight: 10,
                ),
                SizedBox(height: 16.h),
                Row(
                  children: const [
                    Text(
                      "€1,440,000",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff2E7D32),
                      ),
                    ),
                    Spacer(),
                    Text("Ziel €2,000,000")
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
  final String amount;
  final String target;
  final double progress;

  const _ProjectCard({
    required this.title,
    required this.description,
    required this.amount,
    required this.target,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 68.w,
                height: 68.h,
                decoration: BoxDecoration(
                  color: const Color(0xffE8F5E9),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: const Icon(
                  Icons.volunteer_activism,
                  color: Color(0xff2E7D32),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 14.h),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(target),
            ],
          )
        ],
      ),
    );
  }
}
