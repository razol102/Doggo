import 'package:flutter/material.dart';
import 'package:mobile/screens/activity/widgets/activities_list.dart';
import 'package:mobile/services/http_service.dart';

import '../../utils/app_colors.dart';

class ActivitiesHistoryScreen extends StatefulWidget {
  final int dogId;

  const ActivitiesHistoryScreen({Key? key, required this.dogId}) : super(key: key);

  @override
  _ActivitiesHistoryScreenState createState() => _ActivitiesHistoryScreenState();
}

class _ActivitiesHistoryScreenState extends State<ActivitiesHistoryScreen> {
  List<Map<String, dynamic>> activitiesArr = [];
  bool isLoading = false;
  int currentPage = 1;
  final int limit = 5;
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  Future<void> _fetchActivities({bool reset = false}) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      if (reset) {
        activitiesArr.clear();
        currentPage = 1;
        hasMoreData = true;
      }
    });

    try {
      List<Map<String, dynamic>>? newActivities = await HttpService.getOutdoorActivities(
        widget.dogId,
        limit,
        (currentPage - 1) * limit,
      );

      setState(() {
        if (newActivities != null && newActivities.isNotEmpty) {
          activitiesArr = [...activitiesArr, ...newActivities];
          if (newActivities.length < limit) {
            hasMoreData = false;
          }
        } else {
          hasMoreData = false;
        }
      });
    } catch (e) {
      print("Error fetching activities: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _loadMoreActivities() {
    if (!isLoading && hasMoreData) {
      currentPage++;
      _fetchActivities();
    }
  }

  void _loadPreviousPage() {
    if (currentPage > 1 && !isLoading) {
      setState(() {
        currentPage--;
        activitiesArr.clear();
        hasMoreData = true;
      });
      _fetchActivities();
    }
  }

  void _loadNextPage() {
    if (hasMoreData && !isLoading) {
      setState(() {
        currentPage++;
        activitiesArr.clear();
      });
      _fetchActivities();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Activities History",
          style: TextStyle(
            color: AppColors.blackColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.primaryG,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent && !isLoading) {
                    _loadMoreActivities();
                    return true;
                  }
                  return false;
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ActivitiesList(
                    activitiesArr: activitiesArr,
                    dogId: widget.dogId,
                  ),
                ),
              ),
            ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(color: AppColors.secondaryColor1,),
              ),
            Container(
              color: Colors.white.withOpacity(0.5), // Semi-transparent white for bottom section
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: currentPage > 1 ? _loadPreviousPage : null,
                    tooltip: 'Previous Page',
                  ),
                  Text(
                    'Page $currentPage',
                    style: TextStyle(color: AppColors.blackColor),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: hasMoreData ? _loadNextPage : null,
                    tooltip: 'Next Page',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}