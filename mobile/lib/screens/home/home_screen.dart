import 'package:mobile/screens/ble_test_screen.dart';
import 'package:mobile/screens/home/widgets/BCS_pie_chart.dart';
import 'package:mobile/screens/home/widgets/dog_activity_status.dart';
import 'package:mobile/screens/home/widgets/workout_progress_line_chart.dart';
import 'package:mobile/services/ble_service.dart';
import 'package:mobile/utils/app_colors.dart';
import 'package:mobile/screens/home/widgets/workout_row.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../common_widgets/round_button.dart';
import '../devices/BLE_connection_screen.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = "/HomeScreen";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BleService _bleService = BleService();
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _checkConnectionStatus();
  }

  void _checkConnectionStatus() async {
    //final isConnected = false;
    final isConnected = await _bleService.isConnected;
    setState(() {
      _isConnected = isConnected;
    });
  }

  void _navigateToBleConnectionScreen(BuildContext context) async {
    await Navigator.pushNamed(context, BleConnectionScreen.routeName);
    setState(() {}); // Refresh home page to reflect updated connection status
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

  List lastWorkoutArr = [
    {
      "name": "Full Body Workout",
      "image": "assets/images/Workout1.png",
      "kcal": "180",
      "time": "20",
      "progress": 0.3
    },
    {
      "name": "Lower Body Workout",
      "image": "assets/images/Workout2.png",
      "kcal": "200",
      "time": "30",
      "progress": 0.4
    },
    {
      "name": "Ab Workout",
      "image": "assets/images/Workout3.png",
      "kcal": "300",
      "time": "40",
      "progress": 0.7
    },
  ];

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
                  color: _isConnected ? Colors.green : Colors.red,),
                  color: AppColors.blackColor,
                  onPressed: () async {
                    //Navigator.pushNamed(context, BleTestScreen.routeName);
                    await Navigator.pushNamed(context, BleConnectionScreen.routeName);
                    _checkConnectionStatus();
                  },
                ),
              ],
            ),
          ),
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star, // Replace with your desired icon
                color: AppColors.blackColor,
                size: 20,
              ),
              SizedBox(width: 8), // Space between the icon and the title
              Text(
                "Tommy",
                style: TextStyle(
                  color: AppColors.blackColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 8), // Space between the icon and the title
              Icon(Icons.battery_3_bar),
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
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     const Text(
                //       "Workout Progress",
                //       style: TextStyle(
                //         color: AppColors.blackColor,
                //         fontSize: 16,
                //         fontWeight: FontWeight.w600,
                //       ),
                //     ),
                //     Container(
                //       height: 35,
                //       padding: EdgeInsets.symmetric(horizontal: 8),
                //       decoration: BoxDecoration(
                //           gradient: LinearGradient(colors: AppColors.primaryG),
                //           borderRadius: BorderRadius.circular(15)),
                //       child: DropdownButtonHideUnderline(
                //         child: DropdownButton(
                //           items: ["Weekly", "Monthly"]
                //               .map((name) => DropdownMenuItem(
                //               value: name,
                //               child: Text(
                //                 name,
                //                 style: const TextStyle(
                //                     color: AppColors.blackColor,
                //                     fontSize: 14),
                //               )))
                //               .toList(),
                //           onChanged: (value) {},
                //           icon: const Icon(Icons.expand_more,
                //               color: AppColors.whiteColor),
                //           hint: const Text("Weekly",
                //               textAlign: TextAlign.center,
                //               style: TextStyle(
                //                   color: AppColors.whiteColor, fontSize: 12)),
                //         ),
                //       ),
                //     )
                //   ],
                // ),
                // SizedBox(height: media.width * 0.05),
                // Container(
                //     padding: const EdgeInsets.only(left: 15),
                //     height: media.width * 0.5,
                //     width: double.maxFinite,
                //     child:
                //     LineChart(
                //       LineChartData(
                //         showingTooltipIndicators:
                //         showingTooltipOnSpots.map((index) {
                //           return ShowingTooltipIndicators([
                //             LineBarSpot(
                //               tooltipsOnBar,
                //               lineBarsData.indexOf(tooltipsOnBar),
                //               tooltipsOnBar.spots[index],
                //             ),
                //           ]);
                //         }).toList(),
                //         lineTouchData: LineTouchData(
                //           enabled: true,
                //           handleBuiltInTouches: false,
                //           touchCallback: (FlTouchEvent event,
                //               LineTouchResponse? response) {
                //             if (response == null ||
                //                 response.lineBarSpots == null) {
                //               return;
                //             }
                //             if (event is FlTapUpEvent) {
                //               final spotIndex =
                //                   response.lineBarSpots!.first.spotIndex;
                //               showingTooltipOnSpots.clear();
                //               setState(() {
                //                 showingTooltipOnSpots.add(spotIndex);
                //               });
                //             }
                //           },
                //           mouseCursorResolver: (FlTouchEvent event,
                //               LineTouchResponse? response) {
                //             if (response == null ||
                //                 response.lineBarSpots == null) {
                //               return SystemMouseCursors.basic;
                //             }
                //             return SystemMouseCursors.click;
                //           },
                //           getTouchedSpotIndicator: (LineChartBarData barData,
                //               List<int> spotIndexes) {
                //             return spotIndexes.map((index) {
                //               return TouchedSpotIndicatorData(
                //                 FlLine(
                //                   color: Colors.transparent,
                //                 ),
                //                 FlDotData(
                //                   show: true,
                //                   getDotPainter:
                //                       (spot, percent, barData, index) =>
                //                       FlDotCirclePainter(
                //                         radius: 3,
                //                         color: Colors.white,
                //                         strokeWidth: 3,
                //                         strokeColor: AppColors.secondaryColor1,
                //                       ),
                //                 ),
                //               );
                //             }).toList();
                //           },
                //           touchTooltipData: LineTouchTooltipData(
                //             //tooltipBgColor: AppColors.secondaryColor1,
                //             tooltipRoundedRadius: 20,
                //             getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                //               return lineBarsSpot.map((lineBarSpot) {
                //                 return LineTooltipItem(
                //                   "${lineBarSpot.x.toInt()} mins ago",
                //                   const TextStyle(
                //                     color: Colors.white,
                //                     fontSize: 10,
                //                     fontWeight: FontWeight.bold,
                //                   ),
                //                 );
                //               }).toList();
                //             },
                //           ),
                //         ),
                //         lineBarsData: lineBarsData1,
                //         minY: -0.5,
                //         maxY: 110,
                //         titlesData: FlTitlesData(
                //             show: true,
                //             leftTitles: AxisTitles(),
                //             topTitles: AxisTitles(),
                //             bottomTitles: AxisTitles(
                //               sideTitles: bottomTitles,
                //             ),
                //             rightTitles: AxisTitles(
                //               sideTitles: rightTitles,
                //             )),
                //         gridData: FlGridData(
                //           show: true,
                //           drawHorizontalLine: true,
                //           horizontalInterval: 25,
                //           drawVerticalLine: false,
                //           getDrawingHorizontalLine: (value) {
                //             return FlLine(
                //               color: AppColors.grayColor.withOpacity(0.15),
                //               strokeWidth: 2,
                //             );
                //           },
                //         ),
                //         borderData: FlBorderData(
                //           show: true,
                //           border: Border.all(
                //             color: Colors.transparent,
                //           ),
                //         ),
                //       ),
                //     )
                // ),
                WorkoutProgressLineChart(),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Latest Outdoor Activities",
                      style: TextStyle(
                          color: AppColors.blackColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "See More",
                        style: TextStyle(
                            color: AppColors.grayColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                    )
                  ],
                ),
                ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: lastWorkoutArr.length,
                    itemBuilder: (context, index) {
                      var wObj = lastWorkoutArr[index] as Map? ?? {};
                      return InkWell(
                          onTap: () {
                            //Navigator.pushNamed(context, FinishWorkoutScreen.routeName);
                          },
                          child: WorkoutRow(wObj: wObj));
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
