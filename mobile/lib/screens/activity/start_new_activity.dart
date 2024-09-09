import 'package:flutter/material.dart';
import 'package:mobile/utils/app_colors.dart';
import 'package:mobile/common_widgets/round_gradient_button.dart';
import 'package:mobile/services/http_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartNewActivityScreen extends StatefulWidget {
  final String activityType;
  final int dogId;
  final int? currentActivityId;

  const StartNewActivityScreen({
    Key? key,
    required this.activityType,
    required this.dogId,
    this.currentActivityId,
  }) : super(key: key);

  @override
  _StartNewActivityScreenState createState() => _StartNewActivityScreenState();
}

class _StartNewActivityScreenState extends State<StartNewActivityScreen> {
  int? _activityId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _activityId = widget.currentActivityId; // Initialize with the passed activity ID
    print('current activity: ${widget.currentActivityId}');
  }

  void _startActivity() async {
    if (_activityId != null) return; // Prevent starting a new activity if one is already in progress
    setState(() => _isLoading = true);

    try {
      final activityId = await HttpService.startNewActivity(widget.dogId, widget.activityType);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('currentActivityId', activityId);

      setState(() {
        _activityId = activityId;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activity started successfully!')),
        );
      }
    } catch (e) {
      print('Error starting activity: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        _showErrorDialog('Failed to start activity. $e');
      }
    }
  }


  void _endActivity() async {
    if (_activityId == null) return; // Prevent ending an activity if none is in progress
    setState(() => _isLoading = true);

    try {
      await HttpService.endActivity(_activityId!);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('currentActivityId');

      setState(() {
        _activityId = null;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activity ended successfully!')),
        );
      }

      Navigator.of(context).pop();
    } catch (e) {
      print('Error ending activity: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        _showErrorDialog('Failed to end activity. Please try again.');
      }
    }
  }


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Activity Details",
          style: TextStyle(
            color: AppColors.blackColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/${widget.activityType}_background.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.activityType == "other"
                  ? "Get ready for your activity!"
                  : "Get ready for your ${widget.activityType}!",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (_activityId == null) // Show "Start" button when no activity is running
              RoundGradientButton(
                title: "Start",
                onPressed: _startActivity,
              ),
            if (_activityId != null) // Show "End" button when an activity is running
              RoundGradientButton(
                title: "End",
                onPressed: _endActivity,
              ),
          ],
        ),
      ),
    );
  }

}
