import 'package:mobile/screens/activity/widgets/activities_goals_list.dart';
import 'package:mobile/screens/home/widgets/BCS_pie_chart.dart';
import 'package:mobile/screens/home/widgets/dog_activity_status.dart';
import 'package:mobile/services/ble_service.dart';
import 'package:mobile/services/http_service.dart';
import 'package:mobile/services/preferences_service.dart';
import 'package:mobile/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:mobile/main.dart';
import 'package:mobile/common_widgets/round_button.dart';
import 'package:mobile/screens/activity/activities_goals_history.dart';
import 'package:mobile/screens/activity/start_new_activity.dart';
import 'package:mobile/screens/activity/widgets/activity_circles_widget.dart';
import 'package:mobile/screens/devices/BLE_connection_screen.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = "/HomeScreen";

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  final BleService _bleService = BleService();
  bool _isConnectedToBle = false;
  String? _dogName;
  int? dogId;
  late List<Map<String, dynamic>> activitiesArr = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void didPopNext() {
    _checkBleConnectionStatus();
    _fetchDogInfo();
    _fetchDog3LatestActivities();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  void _initialize() {
    _checkBleConnectionStatus();
    _fetchDogInfo();
    _fetchDog3LatestActivities();
  }

  void _checkBleConnectionStatus() async {
    final isConnected = await _bleService.isConnected;
    setState(() {
      _isConnectedToBle = isConnected;
    });
  }

  void _fetchDogInfo() async {
    try {
      // Fetch dogId from preferences
      dogId = await PreferencesService.getDogId();

      if (dogId != null) {
        // Try fetching dog information
        final dogInfo = await HttpService.getDogInfo(dogId!);
        final dogName = dogInfo['name'];

        // Update UI with dog name
        setState(() {
          _dogName = dogName;
        });
      }
    } catch (e) {
      // Handle any errors and display a SnackBar with the error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch dog info: ${e.toString()}')),
      );
    }
  }


  void _fetchDog3LatestActivities() async {
    try {
      final dogId = await PreferencesService.getDogId();
      if (dogId != null) {
        final activities = await HttpService.getOutdoorActivities(dogId, 3, 0); // request for the latest 3 activities
        if (activities != null) {
          setState(() {
            activitiesArr = activities;
          });
        }
      }
    } catch (e) {
      print('Error fetching activities: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching activities. Please try again later.')),
      );
    }
  }


  void _showActivityCirclesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: 300.0,
            height: 180.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.primaryG,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Center(
              child: ActivityCirclesWidget(
                onActivitySelected: (String activityType) {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StartNewActivityScreen(
                        activityType: activityType,
                        dogId: dogId!,
                        currentActivityId: null, // No current activity in progress
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

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
        leading: Container(
          margin: const EdgeInsets.only(left: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.bluetooth,
                  color: _isConnectedToBle ? Colors.green : Colors.red,),
                color: AppColors.blackColor,
                onPressed: () async {
                  await Navigator.pushNamed(context, BleConnectionScreen.routeName);
                  _checkBleConnectionStatus();
                },
              ),
            ],
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isConnectedToBle ?
            const Icon(
              Icons.phone,
              color: AppColors.blackColor,
              size: 20,
            ) :
            const Icon(
              Icons.home,
              color: AppColors.blackColor,
              size: 20,
            ) ,
            SizedBox(width: 8),
            Text(
              _dogName ?? 'Dog Name',
              style: const TextStyle(
                color: AppColors.blackColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.battery_3_bar),
            const SizedBox(width: 50,)
          ],
        ),
        // actions: [
        //   InkWell(
        //       onTap: () {
        //         // Navigator.pushNamed(context, NotificationScreen.routeName);
        //       },
        //       // child: IconButton(
        //       //   icon: Image.asset(
        //       //     "assets/icons/notification_icon.png",
        //       //     width: 24, // Set width here
        //       //     height: 24, // Set height here
        //       //     fit: BoxFit.contain,
        //       //   ),
        //       //   onPressed: () {
        //       //     // Navigator.pushNamed(context, NotificationsScreen.routeName);
        //       //   },
        //       // )
        //   ),],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                DogActivityStatus(),
                SizedBox(height: media.width * 0.05),
                const Divider(),
                SizedBox(height: media.width * 0.0005),
                RoundButton(
                    title: "Add New Activity",
                    onPressed: () {
                      _showActivityCirclesDialog(context);
                    },
                    backgroundColor: AppColors.primaryColor2,
                    titleColor: AppColors.whiteColor
                ),
                const Divider(),
                SizedBox(height: media.width * 0.05),
                if(dogId != null) ...[BcsPieChart(dogId: dogId!,)] ,
                SizedBox(height: media.width * 0.05),
                // WorkoutProgressLineChart(),
                // SizedBox(
                //   height: media.width * 0.05,
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Latest Outdoor Activities",
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.open_in_new),
                      color: AppColors.primaryColor1,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ActivitiesGoalsHistoryScreen(dogId: dogId!, type: 'activity',),
                          ),
                        );
                      },
                      tooltip: 'Open Activities History',
                    ),
                  ],
                ),
                ActivitiesGoalsList(ItemsArr: activitiesArr, dogId: dogId, type: 'activity',),
                SizedBox(
                  height: media.width * 0.1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}