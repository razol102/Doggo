import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class ContactUsScreen extends StatelessWidget {
  static const String routeName = "/ContactUsScreen";

  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.whiteColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  "assets/images/contact_us_background.png",
                  width: media.width * 0.65,
                ),
              ),
              const SizedBox(height: 35),
              const Text(
                "Meet the Nesher Team",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.blackColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              _buildDeveloperCard(
                name: "Shir Tzfania",
                email: "shir.tzfania@gmail.com",
                imagePath: "assets/images/shir.png",
              ),
              _buildDeveloperCard(
                name: "Raz Olewsky",
                email: "raz12316@gmail.com",
                imagePath: "assets/images/raz.png",
              ),
              _buildDeveloperCard(
                name: "Nizan Naor",
                email: "nizan.naor11@gmail.com",
                imagePath: "assets/images/nizan.png",
              ),            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeveloperCard({
    required String name,
    required String email,
    required String imagePath,
  }) {
    return Card(
      color: AppColors.lightPrimaryColor1,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(imagePath),
          radius: 30,
        ),
        title: Text(
          name,
          textAlign: TextAlign.start,
          style: TextStyle(
            color: AppColors.blackColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Email: $email", style: TextStyle(color: AppColors.grayColor)),
          ],
        ),
        contentPadding: const EdgeInsets.all(5),
      ),
    );
  }
}
