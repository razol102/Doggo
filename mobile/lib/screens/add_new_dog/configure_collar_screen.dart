import 'package:flutter/material.dart';
import 'package:mobile/screens/bottom_menu.dart';
import '../../common_widgets/round_gradient_button.dart';
import '../../common_widgets/round_textfield.dart';
import '../../services/http_service.dart';
import '../../utils/app_colors.dart';

class ConfigureCollarScreen extends StatefulWidget {
  final int dogId;

  static String routeName = "/ConfigureCollarScreen";

  const ConfigureCollarScreen({super.key, required this.dogId});

  @override
  _ConfigureCollarScreenState createState() => _ConfigureCollarScreenState();
}

class _ConfigureCollarScreenState extends State<ConfigureCollarScreen> {
  final TextEditingController _collarIdController = TextEditingController();

  void _configureCollarToBackend() async {
    try {
      final collarId = _collarIdController.text;
      final isAvailable = await HttpService.isCollarAvailable(collarId);
      if (isAvailable) {
        await HttpService.configureCollar(widget.dogId, collarId);
        print('Collar configured successfully');
        Navigator.pushNamed(context, BottomMenu.routeName);
      } else { // collar already attached to another dog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This collar is already attached to another dog.'),
            backgroundColor: Colors.red,
          ),
        );
      }

    } catch (e) {
      print('Failed to configure collar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(right: 15, left: 15),
            child: Column(
              children: [
                const SizedBox(height: 15,),
                Image.asset("assets/images/doggo_collar.png", width: media.width*0.7),
                const SizedBox(height: 15),
                const Text(
                  "Configure your dog's collar",
                  style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 10),
                const Text(
                  "Please enter the Collar ID below",
                  style: TextStyle(
                    color: AppColors.grayColor,
                    fontSize: 12,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 25),
                RoundTextField(
                  textEditingController: _collarIdController,
                  hintText: "Collar ID",
                  icon: "assets/icons/doggo_collar_icon.png",
                  textInputType: TextInputType.text,
                ),
                const SizedBox(height: 15),
                RoundGradientButton(
                  title: "Finish",
                  onPressed: _configureCollarToBackend,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

