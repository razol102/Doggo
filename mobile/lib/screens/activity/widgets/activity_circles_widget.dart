import 'package:flutter/material.dart';
import 'package:mobile/utils/app_colors.dart';

class ActivityCirclesWidget extends StatefulWidget {
  final Function(String activityType) onActivitySelected;

  const ActivityCirclesWidget({Key? key, required this.onActivitySelected}) : super(key: key);

  @override
  _ActivityCirclesWidgetState createState() => _ActivityCirclesWidgetState();
}

class _ActivityCirclesWidgetState extends State<ActivityCirclesWidget> {
  final List<Map<String, String>> activities = [
    {"activity_type": "walk", "image": "assets/images/walk_activity.png"},
    {"activity_type": "run", "image": "assets/images/run_activity.png"},
    {"activity_type": "swim", "image": "assets/images/swim_activity.png"},
    {"activity_type": "game", "image": "assets/images/game_activity.png"},
    {"activity_type": "train", "image": "assets/images/train_activity.png"},
    {"activity_type": "hike", "image": "assets/images/hike_activity.png"},
    {"activity_type": "other", "image": "assets/images/unknown_activity.png"}
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                height: 120, // Adjust height as needed
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: (activities.length / 3).ceil(), // Number of pages
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, pageIndex) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: activities
                          .skip(pageIndex * 3)
                          .take(3)
                          .map((activity) => GestureDetector(
                        onTap: () => widget.onActivitySelected(activity["activity_type"]!),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundImage: AssetImage(activity["image"]!),
                              radius: 35.0,
                              backgroundColor: Colors.grey.shade200,
                            ),
                            const SizedBox(height: 5.0),
                            Text(
                              activity["activity_type"]!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ))
                          .toList(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  (activities.length / 3).ceil(),
                      (index) => AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    height: 8.0,
                    width: _currentPage == index ? 16.0 : 8.0,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.primaryColor2
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
