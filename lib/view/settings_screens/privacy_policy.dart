import 'package:flutter/material.dart';

import '../../constant/otherwise/color_manage.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [ColorManage.firstPrimary, ColorManage.secondPrimary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: const Text("Privacy Policy"),
            centerTitle: true,
            foregroundColor: Colors.white,
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style:  TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Theme.of(context).colorScheme.primary,
                ),
                children: [
                  const TextSpan(
                    text: "Welcome to EduHub\n\n",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const TextSpan(
                    text:
                        "EduHub is a secure and user-friendly educational app designed for both students and teachers. Your privacy is very important to us, and we are committed to protecting your personal information.\n\n",
                  ),
                  TextSpan(
                    text: "Information We Collect:\n",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorManage.firstPrimary,
                      fontSize: 17,
                    ),
                  ),
                  const TextSpan(
                    text:
                        "We may collect basic personal information such as your name, email address and educational level. Additionally, we may collect usage data like your activities, lessons accessed, and device information.\n\n",
                  ),
                  TextSpan(
                    text: "How We Use Your Information:\n",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorManage.firstPrimary,
                      fontSize: 17,
                    ),
                  ),
                  const TextSpan(
                    text:
                        "- To provide a personalized learning experience tailored to your needs.\n- To improve the features, performance, and overall quality of EduHub.\n- To communicate important updates, announcements, or feedback.\n- To ensure the security of your account and comply with applicable laws.\n\n",
                  ),
                  TextSpan(
                    text: "Data Sharing:\n",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorManage.firstPrimary,
                      fontSize: 17,
                    ),
                  ),
                  const TextSpan(
                    text:
                        "We do not share your personal information with third parties except with your consent, when required by law, or with trusted service providers who strictly follow our privacy standards.\n\n",
                  ),
                  TextSpan(
                    text: "Your Rights:\n",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorManage.firstPrimary,
                      fontSize: 17,
                    ),
                  ),
                  const TextSpan(
                    text:
                        "You can access, update, or request deletion of your personal data at any time. You can also choose to opt-out of receiving promotional messages or notifications.\n\n",
                  ),
                  TextSpan(
                    text: "Security Measures:\n",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorManage.firstPrimary,
                      fontSize: 17,
                    ),
                  ),
                  const TextSpan(
                    text:
                        "We implement technical and administrative measures to protect your data, though no system is completely immune to potential security risks.\n\n",
                  ),
                  TextSpan(
                    text: "Policy Updates:\n",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorManage.firstPrimary,
                      fontSize: 17,
                    ),
                  ),
                  const TextSpan(
                    text:
                        "EduHub may update this Privacy Policy occasionally. Any significant changes will be communicated through the app or via email.\n\n",
                  ),
                  TextSpan(
                    text: "Contact Us:\n",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorManage.firstPrimary,
                      fontSize: 17,
                    ),
                  ),
                  const TextSpan(
                    text:
                        "For any questions or concerns about your privacy or this policy, please reach out to us at: support@eduhub.com\n",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1.2, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              "Thank you for trusting EduHub. Your privacy and data security are our top priorities.",
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: ColorManage.secondPrimary.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
