import 'package:flutter/material.dart';
import 'package:mobile/utils/app_colors.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import 'package:mobile/services/http_service.dart';
import 'package:mobile/screens/activity/add_update_goal_template.dart';
import 'package:mobile/screens/activity/start_new_activity.dart';

class OutdoorActivityGoalRow extends StatelessWidget {
  final Map item;
  final int dogId;
  final String type; // "activity" or "goal" or "template"

  const OutdoorActivityGoalRow({super.key, required this.item, required this.dogId, required this.type});

  String _getImageByActivityType(String activityType) {
    String imagePath;
    switch (activityType) {
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

  Future<void> _fetchItemDetails(BuildContext context, int itemId) async {
    try {
      final details = type == "activity"
          ? await HttpService.getOutdoorActivityInfo(itemId)
          : type == "goal"
          ? await HttpService.getGoalInfo(itemId)
          : await HttpService.getGoalTemplateInfo(itemId);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              type == "activity"
                  ? item["activity_type"].toString()
                  : type == "goal"
                  ? "${item["category"].toString().toUpperCase()} GOAL"
                  : "Goal",
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (type == "activity") ...[
                  Text("Calories Burned: ${details["calories_burned"]}"),
                  Text("Distance: ${details["distance"]} km"),
                  Text("Steps: ${details["steps"]}"),
                  Text("Start Time: ${details["start_time"]}"),
                  Text("End Time: ${details["end_time"] ?? 'Ongoing'}"),
                ] else if (type == "goal") ...[
                  Text("Category: ${details["category"]}"),
                  Text("Current Value: ${details["current_value"]}"),
                  Text("Target Value: ${details["target_value"]}"),
                  Text("Start Date: ${details["start_date"]}"),
                  Text("End Date: ${details["end_date"]}"),
                ] else if (type == "template") ...[
                  Text("Category: ${details["category"]}"),
                  Text("Target Value: ${details["target_value"]}"),
                  Text("Frequency: ${details["frequency"]}"),
                ],
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              if (type == "activity" && item["end_time"] == null) ...[
                TextButton(
                  child: const Text("End Activity"),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StartNewActivityScreen(
                          activityType: item["activity_type"].toString(),
                          dogId: dogId,
                          currentActivityId: itemId,
                        ),
                      ),
                    );
                  },
                ),
              ] else if (type == "template") ... [
                TextButton(
                  child: const Text("Edit Goal"),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddUpdateGoalTemplateScreen(
                          templateId: item["template_id"], // Pass the templateId
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          );
        },
      );
    } catch (e) {
      print("Error fetching ${type == 'activity' ? 'activity' : type == 'goal' ? 'goal' : 'template'} details: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error fetching details")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final currentValue = double.tryParse(item["current_value"]?.toString() ?? '0') ?? 0;
    final targetValue = double.tryParse(item["target_value"]?.toString() ?? '1') ?? 1; // Avoid division by zero

    // Calculate ratio
    final ratio = currentValue / targetValue;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset(
              type == "activity"
                  ? _getImageByActivityType(item["activity_type"].toString())
                  : type == "goal"
                  ? "assets/images/goal.png"
                  : "assets/images/template.png",
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type == "activity"
                      ? item["activity_type"].toString()
                      : type == "goal"
                      ? "${item["category"].toString().toUpperCase()} GOAL"
                      : "Goal",
                  style: type == "activity" && (item["end_time"] == null) ?
                  const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ) :
                  const TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 12,
                  )
                  ,
                ),
                const SizedBox(height: 4),
                if (type == "activity") ...[
                  // For activity-related details
                  if (item["end_time"] != null) ...[
                    Text(
                      "${item["calories_burned"].toString()} Calories Burned | Duration: ${item["duration"].toString()} | ${item["distance"].toString()} km",
                      style: const TextStyle(
                        color: AppColors.grayColor,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ] else ...[
                    Text(
                      "Start Time: ${item["start_time"].toString()}",
                      style: const TextStyle(
                        color: AppColors.grayColor,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ] else if (type == "goal") ...[
                  // For goal-related details
                  Text(
                    "Category: ${item["category"].toString()}",
                    style: const TextStyle(
                      color: AppColors.grayColor,
                      fontSize: 10,
                    ),
                  ),
                  item["is_finished"] ?
                  Text(
                    "Target Value: ${item["target_value"].toString()} | Current Value: ${item["current_value"].toString()}",
                    style: const TextStyle(
                      color: AppColors.grayColor,
                      fontSize: 10,
                    ),
                  ) :
                  Text(
                    "Target Value: ${item["target_value"].toString()}",
                    style: const TextStyle(
                      color: AppColors.grayColor,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Progress bar
                  SimpleAnimationProgressBar(
                    height: 15,
                    width: media.width * 0.5,
                    backgroundColor: Colors.grey.shade100,
                    foregrondColor: AppColors.primaryColor1,
                    ratio: ratio,
                    direction: Axis.horizontal,
                    curve: Curves.fastLinearToSlowEaseIn,
                    duration: const Duration(seconds: 3),
                    borderRadius: BorderRadius.circular(7.5),
                    gradientColor: LinearGradient(
                        colors: AppColors.primaryG,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight),
                  ),
                ] else if (type == "template") ...[
                  // For template-related details
                  Text(
                    "Category: ${item["category"].toString()}",
                    style: const TextStyle(
                      color: AppColors.grayColor,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    "Target Value: ${item["target_value"].toString()}",
                    style: const TextStyle(
                      color: AppColors.grayColor,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    "Frequency: ${item["frequency"].toString()}",
                    style: const TextStyle(
                      color: AppColors.grayColor,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _fetchItemDetails(context, item["${type}_id"]);
            },
            icon: Image.asset(
              "assets/icons/next_icon.png",
              width: 30,
              height: 30,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
