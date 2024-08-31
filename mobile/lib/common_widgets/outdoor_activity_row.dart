import 'package:flutter/material.dart';
import 'package:mobile/utils/app_colors.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import 'package:mobile/services/http_service.dart';

import '../screens/activity/start_new_activity.dart';

class OutdoorActivityRow extends StatelessWidget {
  final Map wObj;
  final dogId;
  const OutdoorActivityRow({super.key, required this.wObj, this.dogId});

  String _getImageByActivityType(String activityType) {
    String imagePath;
    switch(activityType) {
      case "walk":
        imagePath = "assets/images/walk_activity.png";
        break;
      case "run":
        imagePath = "assets/images/run_activity.png";
        break;
      case "swim":
        imagePath = "assets/images/swim_activity.png";
        break;
      case "game":
        imagePath = "assets/images/game_activity.png";
        break;
      case "train":
        imagePath = "assets/images/train_activity.png";
        break;
      case "hike":
        imagePath = "assets/images/hike_activity.png";
        break;
      default:
        imagePath = "assets/images/unknown_activity.png";
    }
    return imagePath;
  }

  void _fetchActivityDetails(BuildContext context, int activityId) async {
    try {
      final activityDetails = await HttpService.getOutdoorActivityInfo(activityId);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(wObj["activity_type"].toString()),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Calories Burned: ${activityDetails["calories_burned"]}"),
                Text("Distance: ${activityDetails["distance"]} km"),
                Text("Steps: ${activityDetails["steps"]}"),
                Text("Start Time: ${activityDetails["start_time"]}"),
                Text("End Time: ${activityDetails["end_time"] ?? 'Ongoing'}"),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              if (wObj["end_time"] == null)
              TextButton(
                child: const Text("End Activity"),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StartNewActivityScreen(
                        activityType: wObj["activity_type"].toString(),
                        dogId: dogId,
                          currentActivityId: activityId
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      print("Error fetching activity details: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching activity details")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)]),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                _getImageByActivityType(wObj["activity_type"].toString()),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 15,),
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wObj["activity_type"].toString(),
                      style: const TextStyle(
                          color: AppColors.blackColor,
                          fontSize: 12),
                    ),
                    if (wObj["end_time"] != null) ...[
                      Text(
                        "${wObj["calories_burned"].toString()} Calories Burn | Duration: ${wObj["duration"].toString()} | ${wObj["distance"].toString()} km",
                        style: const TextStyle(
                          color: AppColors.grayColor,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 4,),
                      SimpleAnimationProgressBar(
                        height: 15,
                        width: media.width * 0.5,
                        backgroundColor: Colors.grey.shade100,
                        foregrondColor: Colors.purple,
                        ratio: wObj["progress"] as double? ?? 0.0,
                        direction: Axis.horizontal,
                        curve: Curves.fastLinearToSlowEaseIn,
                        duration: const Duration(seconds: 3),
                        borderRadius: BorderRadius.circular(7.5),
                        gradientColor: LinearGradient(
                            colors: AppColors.primaryG,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight),
                      ),
                    ],
                    if (wObj["end_time"] == null) ...[
                      Text(
                        "Start Time: ${wObj["start_time"].toString()}",
                        style: const TextStyle(
                          color: AppColors.grayColor,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                )),
            IconButton(
                onPressed: () {
                  if (wObj["end_time"] == null) {
                    // If the activity is not done yet, fetch details and open the activity screen
                    _fetchActivityDetails(context, wObj["activity_id"]);
                  } else {
                    // If the activity is done, show the details directly
                    _fetchActivityDetails(context, wObj["activity_id"]);
                  }
                },
                icon: Image.asset(
                  "assets/icons/next_icon.png",
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                ))
          ],
        ));
  }
}
