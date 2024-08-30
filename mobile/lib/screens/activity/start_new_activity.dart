import 'package:flutter/material.dart';
import 'package:mobile/utils/app_colors.dart';
import '../../common_widgets/round_gradient_button.dart';
import '../../services/http_service.dart';
import '../../services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartNewActivityScreen extends StatefulWidget {
  final String activityType;
  final int dogId;

  const StartNewActivityScreen({Key? key, required this.activityType, required this.dogId}) : super(key: key);

  @override
  _StartNewActivityScreenState createState() => _StartNewActivityScreenState();
}

class _StartNewActivityScreenState extends State<StartNewActivityScreen> {
  int? _activityId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadActivityId();
  }

  Future<void> _loadActivityId() async {
    setState(() => _isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _activityId = prefs.getInt('currentActivityId');
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading activity ID: $e');
      setState(() => _isLoading = false);
    }
  }

  void _startActivity() {
    if (_activityId != null) return;
    setState(() => _isLoading = true);
    HttpService.startNewActivity(widget.dogId, widget.activityType).then((activityId) async {
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
    }).catchError((e) {
      print('Error starting activity: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        _showErrorDialog('$e');
      }
    });
  }

  void _endActivity() {
    if (_activityId == null) return;
    setState(() => _isLoading = true);
    HttpService.endActivity(_activityId!).then((_) async {
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
    }).catchError((e) {
      print('Error ending activity: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        _showErrorDialog('Failed to end activity. Please try again.');
      }
    });
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
          "Start New Activity",
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
            RoundGradientButton(
              title: "Start",
              onPressed: _activityId == null ? _startActivity : () {},
            ),
            const SizedBox(height: 10),
            RoundGradientButton(
              title: "End",
              onPressed: _activityId != null ? _endActivity : () {},
            ),
          ],
        ),
      ),
    );
  }
}