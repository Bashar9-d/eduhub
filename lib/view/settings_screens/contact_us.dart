import 'package:eduhub/constant/otherwise/color_manage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  @override
  Widget build(BuildContext context) {
    final Uri phoneNumber = Uri.parse('tel:+962782573330');
    final Uri emailUri = Uri.parse('mailto:amrosramrosr05@gmail.com');
    return Scaffold(
      appBar: AppBar(title: Text('Contact Us'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 26,
                backgroundImage: NetworkImage(
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT0Albxs3nJCxfue8iE7nYaN4SMZz_rpzFnIQ&s',
                ),
              ),
              title: Text('Jordan'),
            ),
            SizedBox(height: 20),
            ListTile(
              onTap: () async {
                await launchUrl(phoneNumber);
              },
              leading: Icon(
                Icons.phone_outlined,
                color: ColorManage.firstPrimary,
                size: 30,
              ),
              title: Text('Mobile Number'),
              subtitle: Text('+962782573330'),
            ),
            ListTile(
              onTap: () async {
                await launchUrl(emailUri);
              },
              leading: Icon(
                Icons.email_outlined,
                color: ColorManage.firstPrimary,
                size: 30,
              ),
              title: Text('Email Address'),
              subtitle: Text('amrosramrosr05@gmail.com'),
            ),
          ],
        ),
      ),
    );
  }
}
