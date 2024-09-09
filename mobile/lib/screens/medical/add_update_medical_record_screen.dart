import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/common_widgets/round_gradient_button.dart';
import 'package:mobile/services/http_service.dart';
import 'package:mobile/utils/app_colors.dart';
import 'package:mobile/services/validation_methods.dart';

class AddUpdateMedicalRecordScreen extends StatefulWidget {
  static const String routeName = "/AddUpdateMedicalRecordScreen";

  final DateTime date;
  final String dogId;
  final bool isUpdate;
  final int? recordId;

  const AddUpdateMedicalRecordScreen({
    Key? key,
    required this.date,
    required this.dogId,
    this.isUpdate = false,
    this.recordId,
  }) : super(key: key);

  @override
  _AddUpdateMedicalRecordScreenState createState() => _AddUpdateMedicalRecordScreenState();
}

class _AddUpdateMedicalRecordScreenState extends State<AddUpdateMedicalRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _vetNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _timeController.text = DateFormat('HH:mm').format(widget.date);
    if (widget.isUpdate && widget.recordId != null) {
      _loadMedicalRecord();
    }
  }

  @override
  void dispose() {
    _vetNameController.dispose();
    _addressController.dispose();
    _timeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadMedicalRecord() async {
    try {
      final fetchedData = await HttpService.getMedicalRecord(widget.recordId!);
      setState(() {
        _vetNameController.text = fetchedData['vet_name'];
        _addressController.text = fetchedData['address'];
        DateTime recordDateTime = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'", 'en_US').parse(fetchedData['record_datetime'], true).toLocal();
        _timeController.text = DateFormat('HH:mm').format(recordDateTime);
        _descriptionController.text = fetchedData['description'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading medical record: $e')),
      );
    }
  }

  Future<void> _saveMedicalRecord() async {
    if (_formKey.currentState!.validate()) {
      try {
        DateTime dateTime = DateTime(
          widget.date.year,
          widget.date.month,
          widget.date.day,
          int.parse(_timeController.text.split(':')[0]),
          int.parse(_timeController.text.split(':')[1]),
        );
        final recordData = {
          'vet_name': _vetNameController.text,
          'address': _addressController.text,
          'record_datetime': DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").format(dateTime.toUtc()),
          'description': _descriptionController.text,
        };

        if (widget.isUpdate) {
          await HttpService.updateMedicalRecord(widget.recordId!, recordData);
        } else {
          await HttpService.addMedicalRecord(widget.dogId, recordData);
        }

        Navigator.of(context).pop(true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving medical record: $e')),
        );
      }
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          widget.isUpdate ? "Update Medical Record" : "Add Medical Record",
          style: const TextStyle(
              color: AppColors.blackColor,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  controller: _vetNameController,
                  label: 'Vet Name',
                  icon: Icons.person,
                  validator: (value) => ValidationMethods.validateNotEmpty(value, 'Vet Name')
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _addressController,
                  label: 'Address',
                  icon: Icons.location_on,
                  validator: (value) => ValidationMethods.validateNotEmpty(value, 'Address'),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _timeController,
                  label: 'Time',
                  icon: Icons.access_time,
                  readOnly: true,
                  onTap: () => _selectTime(context),
                  validator: (value) => ValidationMethods.validateNotEmpty(value, 'Time'),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  icon: Icons.description,
                  maxLines: 3,
                  validator: (value) => ValidationMethods.validateNotEmpty(value, 'Description'),
                ),
                const SizedBox(height: 24),
                RoundGradientButton(title: widget.isUpdate ? 'Update' : 'Save', onPressed: _saveMedicalRecord),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
    );
  }
}
