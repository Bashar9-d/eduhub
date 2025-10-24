import 'package:flutter/material.dart';

import '../../constant/otherwise/color_manage.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    final Widget content = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
              children: [
                const TextSpan(
                  text: "About EduHub\n\n",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                const TextSpan(
                  text:
                  "EduHub is a modern educational platform that connects teachers and students in a smart, interactive learning environment. Our mission is to make learning engaging, accessible, and effective for everyone.\n\n",
                ),
                TextSpan(
                  text: "Our Vision:\n",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ColorManage.firstPrimary,
                    fontSize: 17,
                  ),
                ),
                const TextSpan(
                  text: "To be a leading digital learning platform accessible to students and teachers worldwide.\n\n",
                ),
                TextSpan(
                  text: "Our Mission:\n",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ColorManage.firstPrimary,
                    fontSize: 17,
                  ),
                ),
                const TextSpan(
                  text:
                  "To deliver interactive, creative, and collaborative learning experiences that empower both teachers and students to succeed.\n\n",
                ),
                TextSpan(
                  text: "Our Services:\n",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ColorManage.firstPrimary,
                    fontSize: 17,
                  ),
                ),
                const TextSpan(
                  text:
                  "- Lesson and content management\n- Dashboards for students & teachers\n- Performance tracking & reporting\n- Communication tools for teachers and students\n- Notifications and reminders for important updates\n\n",
                ),
                TextSpan(
                  text: "Our Values:\n",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ColorManage.firstPrimary,
                    fontSize: 17,
                  ),
                ),
                const TextSpan(
                  text:
                  "Quality, privacy, transparency, and continuous improvement guide all our efforts at EduHub.\n\n",
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(thickness: 1.2, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            "Join us on a journey to better learning and education with EduHub. Together, we make learning smarter and more fun!",
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: ColorManage.secondPrimary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );

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
            title: const Text("About Us"),
            centerTitle: true,
            foregroundColor: Colors.white,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: content,
    );
  }
}
