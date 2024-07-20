import 'package:flutter/material.dart';
import 'package:mobile/screens/profile/user_profile_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'auth/signup_step1_screen.dart';
import 'auth/login_screen.dart';
import '../../common_widgets/round_gradient_button.dart';
import 'package:mobile/utils/app_colors.dart';

class WelcomeScreen extends StatefulWidget {
  static String routeName = "/WelcomeScreen";

  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _hasPermission = false;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    var locationStatus = await Permission.location.request();
    var bluetoothStatus = await Permission.bluetoothScan.request();
    var bluetoothConnectStatus = await Permission.bluetoothConnect.request();

    setState(() {
      _hasPermission = locationStatus.isGranted &&
          bluetoothStatus.isGranted &&
          bluetoothConnectStatus.isGranted;
      _permissionDenied = locationStatus.isDenied ||
          bluetoothStatus.isDenied ||
          bluetoothConnectStatus.isDenied;
    });
  }

  void _showPermissionDeniedMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission Denied'),
        content: Text('The app cannot function without the required permissions. Please grant them in your device settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: media.width * 0.2),
              const Text(
                "Welcome!",
                style: TextStyle(
                  color: AppColors.secondaryColor1,
                  fontSize: 35,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w800,
                  shadows: [
                    Shadow(
                      offset: Offset(1.0, 1.0),
                      blurRadius: 4.0,
                      color: Color.fromARGB(128, 0, 0, 0),
                    ),
                  ],
                ),
              ),
              Image.asset("assets/images/welcome_promo.png",
                  width: media.width * 1.5, fit: BoxFit.fitWidth),
              const Text(
                "Your companion for a healthier & happier\nlife with your dog",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.grayColor,
                  fontSize: 12,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: media.width * 0.05),
              if (_hasPermission)
                RoundGradientButton(
                  title: "Login",
                  onPressed: () {
                    Navigator.pushNamed(context, LoginScreen.routeName);
                  },
                )
              else if (_permissionDenied)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Permission Denied'),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _showPermissionDeniedMessage,
                      child: Text('Show Message'),
                    ),
                  ],
                )
              else
                CircularProgressIndicator(),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, SignUpStep1Screen.routeName);
                },
                child: RichText(
                  text: const TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(
                      color: AppColors.grayColor,
                      fontSize: 11,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w400,
                    ),
                    children: [
                      TextSpan(
                        text: "Sign up",
                        style: TextStyle(
                          color: AppColors.secondaryColor2,
                          fontSize: 14,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
