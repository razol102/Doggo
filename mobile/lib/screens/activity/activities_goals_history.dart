import 'package:flutter/material.dart';
import 'package:mobile/screens/activity/widgets/activities_goals_list.dart';
import 'package:mobile/services/http_service.dart';
import 'package:mobile/utils/app_colors.dart';

class ActivitiesGoalsHistoryScreen extends StatefulWidget {
  final int dogId;
  final String type;

  const ActivitiesGoalsHistoryScreen({
    super.key,
    required this.dogId,
    required this.type,
  });

  @override
  _ActivitiesGoalsHistoryScreenState createState() =>
      _ActivitiesGoalsHistoryScreenState();
}

class _ActivitiesGoalsHistoryScreenState
    extends State<ActivitiesGoalsHistoryScreen> {
  List<Map<String, dynamic>> itemsArr = [];
  bool isLoading = false;
  int currentPage = 1;
  late int limit;
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();

    // Set limit based on the type (5 for activities, 4 for goals)
    limit = widget.type == 'activity' ? 5 : 4;

    _fetchItems();
  }

  Future<void> _fetchItems({bool reset = false}) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      if (reset) {
        itemsArr.clear();
        currentPage = 1;
        hasMoreData = true;
      }
    });

    try {
      // Fetch one more item than the limit to check if more data exists
      List<Map<String, dynamic>>? newItems;

      if (widget.type == 'activity') {
        newItems = await HttpService.getOutdoorActivities(
          widget.dogId,
          limit + 1, // Fetch limit + 1 items
          (currentPage - 1) * limit,
        );
      } else if (widget.type == 'goal') {
        newItems = await HttpService.getGoalsList(
          widget.dogId,
          limit + 1, // Fetch limit + 1 items
          (currentPage - 1) * limit,
        );
      }

      setState(() {
        if (newItems != null && newItems.isNotEmpty) {
          // If more than the limit is fetched, set hasMoreData to true and remove the extra item
          if (newItems.length > limit) {
            itemsArr = [...itemsArr, ...newItems.take(limit)];
            hasMoreData = true;
          } else {
            itemsArr = [...itemsArr, ...newItems];
            hasMoreData = false;
          }
        } else {
          hasMoreData = false;
        }
      });
    } catch (e) {
      print("Error fetching ${widget.type}s: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching ${widget.type}s. Please try again later.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _loadMoreItems() {
    if (!isLoading && hasMoreData) {
      currentPage++;
      _fetchItems();
    }
  }

  void _loadPreviousPage() {
    if (currentPage > 1 && !isLoading) {
      setState(() {
        currentPage--;
        itemsArr.clear();
        hasMoreData = true;
      });
      _fetchItems();
    }
  }

  void _loadNextPage() {
    if (hasMoreData && !isLoading) {
      setState(() {
        currentPage++;
        itemsArr.clear();
      });
      _fetchItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        title: Text(
          widget.type == 'activity' ? "Activities History" : "Goals History",
          style: const TextStyle(
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
                  if (scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent &&
                      !isLoading) {
                    _loadMoreItems();
                    return true;
                  }
                  return false;
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ActivitiesGoalsList(
                    ItemsArr: itemsArr,
                    dogId: widget.dogId,
                    type: widget.type, // Pass type to the ActivitiesList
                  ),
                ),
              ),
            ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  color: AppColors.secondaryColor1,
                ),
              ),
            Container(
              color: Colors.white.withOpacity(0.5),
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
                    style: const TextStyle(color: AppColors.blackColor),
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
