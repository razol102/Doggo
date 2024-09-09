import 'package:flutter/material.dart';
import 'package:mobile/common_widgets/round_gradient_button.dart';
import 'package:mobile/screens/activity/widgets/frequency_selector.dart';
import 'package:mobile/screens/activity/widgets/goal_category_selector.dart';
import 'package:mobile/utils/app_colors.dart';
import 'package:mobile/common_widgets/round_textfield.dart';
import 'package:mobile/services/http_service.dart';
import 'package:mobile/services/preferences_service.dart';
import 'package:mobile/services/validation_methods.dart';


class AddUpdateGoalTemplateScreen extends StatefulWidget {
  final int? templateId; // Pass templateId for update; null for add

  AddUpdateGoalTemplateScreen({Key? key, this.templateId}) : super(key: key);

  @override
  _AddUpdateGoalTemplateScreenState createState() => _AddUpdateGoalTemplateScreenState();
}

class _AddUpdateGoalTemplateScreenState extends State<AddUpdateGoalTemplateScreen> {
  final _targetValueController = TextEditingController();
  String _selectedCategory = 'steps'; // Default category
  String _frequency = 'daily'; // Default frequency
  String? _errorText;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.templateId != null) {
      _loadGoalTemplate();
    }
  }

  Future<void> _loadGoalTemplate() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final goalTemplate = await HttpService.getGoalTemplateInfo(widget.templateId!);
      _targetValueController.text = goalTemplate['target_value'].toString();
      _frequency = goalTemplate['frequency'];
      _selectedCategory = goalTemplate['category'];
    } catch (e) {
      print('Error loading goal template: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load goal template.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onFrequencyChanged(String newFrequency) {
    if (widget.templateId == null) {
      setState(() {
        _frequency = newFrequency;
      });
    }
  }

  void _onCategoryChanged(String newCategory) {
    if (widget.templateId == null) {
      setState(() {
        _selectedCategory = newCategory;
      });
    }
  }

  Future<void> _saveGoalTemplate() async {
    setState(() {
      _isLoading = true;
    });

    String? validationError = _validateFields();
    if (validationError != null) {
      setState(() {
        _errorText = validationError;
      });
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      if (widget.templateId == null) {
        // Add new goal template
        final int? dogId = await PreferencesService.getDogId();
        await HttpService.createGoal(
          dogId!,
          _targetValueController.text,
          _frequency,
          _selectedCategory,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goal template added successfully!')),
        );
      } else {
        // Update existing goal template
        await HttpService.updateGoalTemplate(widget.templateId!, _targetValueController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goal template updated successfully!')),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      print('Error saving goal template: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save goal template.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? _validateFields() {
    String targetValue = _targetValueController.text;

    if (_selectedCategory == 'steps' || _selectedCategory == 'calories_burned') {
      return ValidationMethods.validatePositiveInt(targetValue, 'Target Value');
    } else if (_selectedCategory == 'distance') {
      return ValidationMethods.validatePositiveDouble(targetValue, 'Target Value');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          widget.templateId == null ? 'Add Goal Template' : 'Update Goal Template',
          style: const TextStyle(
            color: AppColors.blackColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: widget.templateId != null
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.blackColor),
          onPressed: () => Navigator.pop(context),
        )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RoundTextField(
              textEditingController: _targetValueController,
              hintText: "Target Value",
              icon: 'assets/icons/target_icon.png',
              textInputType: TextInputType.number,
              errorText: _errorText,
            ),
            const SizedBox(height: 16),
            FrequencySelector(
              selectedFrequency: _frequency,
              onFrequencyChanged: _onFrequencyChanged,
              isReadOnly: widget.templateId != null,
            ),
            const SizedBox(height: 16),
            GoalCategorySelector(
              selectedCategory: _selectedCategory,
              onCategoryChanged: _onCategoryChanged,
              isReadOnly: widget.templateId != null,
            ),
            const SizedBox(height: 20),
            RoundGradientButton(
              title: widget.templateId == null ? 'Add Goal' : 'Update Goal',
              onPressed: _saveGoalTemplate,
            ),
          ],
        ),
      ),
    );
  }
}
