import 'package:mobile/screens/activity/activity_screen.dart';
import 'package:mobile/screens/home/widgets/BCS_pie_chart.dart';
import 'package:mobile/screens/home/widgets/dog_activity_status.dart';
import 'package:mobile/screens/home/widgets/workout_progress_line_chart.dart';
import 'package:mobile/services/ble_service.dart';
import 'package:mobile/services/http_service.dart';
import 'package:mobile/services/preferences_service.dart';
import 'package:mobile/utils/app_colors.dart';
import 'package:mobile/common_widgets/outdoor_activity_row.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile/main.dart';
import '../../common_widgets/round_button.dart';
import '../bottom_menu.dart';
import '../devices/BLE_connection_screen.dart';

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
    // This method is called when the user navigates back to this screen in case to take care of updating dog name
    _fetchDogInfo();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  void _initialize() {
    _checkBleConnectionStatus();
    _fetchDogInfo();
    _fetchDogLatestActivities();
  }

  void _checkBleConnectionStatus() async {
    final isConnected = await _bleService.isConnected;
    setState(() {
      _isConnectedToBle = isConnected;
    });
  }

  void _fetchDogInfo() async {
    final dogId = await PreferencesService.getDogId();
    if (dogId != null) {
      final dogInfo = await HttpService.getDogInfo(dogId);
      final dogName = dogInfo['name'];
      setState(() {
        _dogName = dogName;
      });
    }
  }

  void _fetchDogLatestActivities() async {
    final dogId = await PreferencesService.getDogId();
    if (dogId != null) {
      final activities = await HttpService.getAllOutdoorActivities(dogId);
      setState(() {
        activitiesArr = activities;
      });
    }
  }


  List<int> showingTooltipOnSpots = [21];

  List<FlSpot> get allSpots => const [
    FlSpot(0, 20),
    FlSpot(1, 25),
    FlSpot(2, 40),
    FlSpot(3, 50),
    FlSpot(4, 35),
    FlSpot(5, 40),
    FlSpot(6, 30),
    FlSpot(7, 20),
    FlSpot(8, 25),
    FlSpot(9, 40),
    FlSpot(10, 50),
    FlSpot(11, 35),
    FlSpot(12, 50),
    FlSpot(13, 60),
    FlSpot(14, 40),
    FlSpot(15, 50),
    FlSpot(16, 20),
    FlSpot(17, 25),
    FlSpot(18, 40),
    FlSpot(19, 50),
    FlSpot(20, 35),
    FlSpot(21, 80),
    FlSpot(22, 30),
    FlSpot(23, 20),
    FlSpot(24, 25),
    FlSpot(25, 40),
    FlSpot(26, 50),
    FlSpot(27, 35),
    FlSpot(28, 50),
    FlSpot(29, 60),
    FlSpot(30, 40),
  ];

  List<LineChartBarData> get lineBarsData1 => [
    lineChartBarData1_1,
    lineChartBarData1_2,
  ];

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
    isCurved: true,
    gradient: LinearGradient(colors: [
      AppColors.primaryColor2.withOpacity(0.5),
      AppColors.primaryColor1.withOpacity(0.5),
    ]),
    barWidth: 4,
    isStrokeCapRound: true,
    dotData: FlDotData(show: false),
    belowBarData: BarAreaData(show: false),
    spots: const [
      FlSpot(1, 35),
      FlSpot(2, 70),
      FlSpot(3, 40),
      FlSpot(4, 80),
      FlSpot(5, 25),
      FlSpot(6, 70),
      FlSpot(7, 35),
    ],
  );

  LineChartBarData get lineChartBarData1_2 => LineChartBarData(
    isCurved: true,
    gradient: LinearGradient(colors: [
      AppColors.secondaryColor2.withOpacity(0.5),
      AppColors.secondaryColor1.withOpacity(0.5),
    ]),
    barWidth: 2,
    isStrokeCapRound: true,
    dotData: FlDotData(show: false),
    belowBarData: BarAreaData(
      show: false,
    ),
    spots: const [
      FlSpot(1, 80),
      FlSpot(2, 50),
      FlSpot(3, 90),
      FlSpot(4, 40),
      FlSpot(5, 80),
      FlSpot(6, 35),
      FlSpot(7, 60),
    ],
  );

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    final lineBarsData = [
      LineChartBarData(
        showingIndicators: showingTooltipOnSpots,
        spots: allSpots,
        isCurved: false,
        barWidth: 3,
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(colors: [
            AppColors.primaryColor2.withOpacity(0.4),
            AppColors.primaryColor1.withOpacity(0.1),
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        dotData: FlDotData(show: false),
        gradient: LinearGradient(
          colors: AppColors.primaryG,
        ),
      ),
    ];

    final tooltipsOnBar = lineBarsData[0];

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
            const SizedBox(width: 8), // Space between the icon and the title
            Icon(Icons.battery_3_bar), // TODO: change by battery level
          ],
        ),
        actions: [
          InkWell(
              onTap: () {
                // Navigator.pushNamed(context, NotificationScreen.routeName);
              },
              child: IconButton(
                icon: Image.asset(
                  "assets/icons/notification_icon.png",
                  width: 24, // Set width here
                  height: 24, // Set height here
                  fit: BoxFit.contain,
                ),
                onPressed: () {
                  // Navigator.pushNamed(context, NotificationsScreen.routeName);
                },
              )
          ),],),
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
                RoundButton(title: "Add New Activity", onPressed: () {}, backgroundColor: AppColors.primaryColor2, titleColor: AppColors.whiteColor),
                const Divider(),
                SizedBox(height: media.width * 0.05),
                BcsPieChart(),
                SizedBox(height: media.width * 0.05),
                WorkoutProgressLineChart(),
                SizedBox(
                  height: media.width * 0.05,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Latest Outdoor Activities",
                      style: TextStyle(
                          color: AppColors.blackColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                activitiesArr.isEmpty ?
                    const Center(child: Text("No Activities Available."),)
                    :
                ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 3, //show 3 latest activities
                    itemBuilder: (context, index) {
                      var wObj = activitiesArr[index];
                      return InkWell(
                          onTap: () {
                            //Navigator.pushNamed(context, FinishWorkoutScreen.routeName);
                          },
                          child: OutdoorActivityRow(wObj: wObj));
                    }),
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