import 'package:flutter/material.dart';
import 'package:mobile/screens/activity/goals_templates_screen.dart';
import 'package:mobile/screens/activity/start_new_activity.dart';
import 'package:mobile/screens/activity/widgets/activities_goals_list.dart';
import 'package:mobile/screens/activity/widgets/activity_circles_widget.dart';
import '../../common_widgets/round_button.dart';
import '../../main.dart';
import '../../services/http_service.dart';
import '../../services/preferences_service.dart';
import '../../utils/app_colors.dart';
import 'activities_goals_history.dart';

class ActivityScreen extends StatefulWidget {
  static String routeName = "/ActivityScreen";

  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> with RouteAware{
  int? _dogId;
  late List<Map<String, dynamic>> goalsArr = [];

  @override
  void initState() {
    super.initState();
    _loadDogId();
    _fetchDog3LatestGoals();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void didPopNext() {
    _fetchDog3LatestGoals();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> _loadDogId() async {
    final dogId = await PreferencesService.getDogId();
    setState(() {
      _dogId = dogId;
    });
  }

  Future<void> _startActivity(BuildContext context, String activityType) async {
    if (_dogId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StartNewActivityScreen(activityType: activityType, dogId: _dogId!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to retrieve dog ID')),
      );
    }
  }

  void _fetchDog3LatestGoals() async {
    final dogId = await PreferencesService.getDogId();
    if (dogId != null) {
      final goals = await HttpService.getGoalsList(dogId, 3, 0); // request for the latest 3 activities
      if (goals != null) {
        setState(() {
          goalsArr = goals;
        });
      }
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Activities & Goals",
          style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView( // Add this to enable scrolling
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16), // Padding inside the container
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.primaryG), // Gradient background
                borderRadius: BorderRadius.circular(media.width * 0.065), // Rounded corners
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    "assets/icons/bg_dots.png",
                    height: media.width * 0.4,
                    width: double.maxFinite,
                    fit: BoxFit.fitHeight,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Add New Activity",
                          style: TextStyle(
                              color: AppColors.blackColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 7),
                        ActivityCirclesWidget(
                          onActivitySelected: (activityType) {
                            _startActivity(context, activityType);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: media.width * 0.05),
            const Divider(),
            SizedBox(height: media.width * 0.0005),
            RoundButton(
                title: "Show Activities History",
                onPressed: () {
                  if (_dogId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActivitiesGoalsHistoryScreen(dogId: _dogId!, type: 'activity',),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to retrieve dog ID')),
                    );
                  }
                },
                backgroundColor: AppColors.primaryColor2,
                titleColor: AppColors.whiteColor),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Latest Goals",
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  color: AppColors.primaryColor1,
                  onPressed: () { // navigate to GoalsTemplatesScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GoalsTemplatesScreen(dogId: _dogId!),
                      ),
                    );
                  },
                  tooltip: 'Create Goal',
                ),
                SizedBox(width: media.width * 0.35),
                IconButton(
                  icon: Icon(Icons.open_in_new),
                  color: AppColors.primaryColor1,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActivitiesGoalsHistoryScreen(dogId: _dogId!, type: 'goal',),
                      ),
                    );
                  },
                  tooltip: 'Open Goals History',
                ),
              ],
            ),
            ActivitiesGoalsList(ItemsArr: goalsArr, dogId: _dogId, type: 'goal',),
            SizedBox(
              height: media.width * 0.1,
            ),
          ],
        ),
      ),
    );
  }
}
