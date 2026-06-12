import 'package:flutter/material.dart';

void main() {
  runApp(const DonationOverview());
}

class DonationOverview extends StatelessWidget {
  const DonationOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Donations',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xffF6F5F2),
        useMaterial3: true,
      ),
      home: const DonationPage(),
    );
  }
}

class DonationPage extends StatelessWidget {
  const DonationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const _Header(),
              const SizedBox(height: 24),

              const _HeroCard(),

              const SizedBox(height: 28),

              _sectionTitle("Featured Campaign"),

              const SizedBox(height: 14),

              const _FeaturedProjectCard(),

              const SizedBox(height: 28),

              _sectionTitle("Community Projects"),

              const SizedBox(height: 14),

              const _ProjectCard(
                title: "Prayer Hall Cooling",
                description:
                    "Install energy efficient cooling systems before summer.",
                amount: "€12,400",
                target: "€20,000",
                progress: .62,
              ),

              const SizedBox(height: 14),

              const _ProjectCard(
                title: "Community Kitchen",
                description:
                    "Renovate and modernize the kitchen for events.",
                amount: "€18,900",
                target: "€35,000",
                progress: .54,
              ),

              const SizedBox(height: 14),

              const _ProjectCard(
                title: "Learning Center",
                description:
                    "Create study spaces and educational resources.",
                amount: "€31,500",
                target: "€50,000",
                progress: .63,
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.volunteer_activism,
                      color: Color(0xff2E7D32),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Every contribution helps us build a stronger community.",
                      ),
                    ),
                    FilledButton(
                      onPressed: () {},
                      child: const Text("Donate"),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu),
        ),
        const Spacer(),
        const Text(
          "Donations",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none),
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
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [
            Color(0xff2E7D32),
            Color(0xff66BB6A),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Build For The Future",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Help expand our community center and prayer facilities.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
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
                "Donate Now",
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
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Container(
            height: 180,
            decoration: const BoxDecoration(
              color: Color(0xffDDE7D8),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
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
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Row(
                  children: [
                    Expanded(
                      child: Text(
                        "New Mosque Expansion",
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
                const SizedBox(height: 12),
                const LinearProgressIndicator(
                  value: .72,
                  minHeight: 10,
                ),
                const SizedBox(height: 16),
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
                    Text("Goal €2,000,000")
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xffE8F5E9),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.volunteer_activism,
                  color: Color(0xff2E7D32),
                ),
              ),
              const SizedBox(width: 14),
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
                    const SizedBox(height: 6),
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
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
          ),
          const SizedBox(height: 12),
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