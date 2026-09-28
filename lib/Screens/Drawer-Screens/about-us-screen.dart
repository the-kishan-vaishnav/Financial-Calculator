import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF44474b),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "About Us",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Color(0xFF44474b),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // App Logo Placeholder
            Center(
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFf2faf7),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.calculate_rounded,
                  size: 60,
                  color: Color(0xFF00D09C),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Finance Calc Pro",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF44474b),
              ),
            ),
            const Text(
              "Version 1.0.4",
              style: TextStyle(color: Color(0xFF7c7e8c), fontSize: 14),
            ),
            const SizedBox(height: 40),

            // Mission Statement
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Our Mission",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF44474b),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "We aim to simplify complex financial decisions for everyone. Whether you are planning a home loan, calculating your SIP returns, or converting units, Finance Calc Pro provides accurate and instant results to help you grow your wealth.",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            const Divider(
              color: Color(0xFFedf2f7),
              thickness: 1,
              indent: 24,
              endIndent: 24,
            ),

            // Action Links
            _aboutLinkTile(
              Icons.language_rounded,
              "Official Website",
              "www.financecalc.pro",
            ),
            _aboutLinkTile(
              Icons.mail_outline_rounded,
              "Support Email",
              "support@financecalc.pro",
            ),
            _aboutLinkTile(
              Icons.description_outlined,
              "Privacy Policy",
              "Read our terms",
            ),

            const SizedBox(height: 40),

            // Social Media Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _socialIcon(Icons.facebook),
                _socialIcon(Icons.camera_alt_outlined), // Instagram
                _socialIcon(Icons.business_outlined), // LinkedIn
              ],
            ),

            const SizedBox(height: 40),
            const Text(
              "© 2025 Finance Calc Pro. All rights reserved.",
              style: TextStyle(color: Color(0xFF7c7e8c), fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _aboutLinkTile(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(icon, color: const Color(0xFF00D09C)),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Color(0xFF44474b),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 13, color: Color(0xFF7c7e8c)),
      ),
      trailing: const Icon(
        Icons.open_in_new,
        size: 16,
        color: Color(0xFFedf2f7),
      ),
      onTap: () {},
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFedf2f7)),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: const Color(0xFF44474b), size: 20),
    );
  }
}
