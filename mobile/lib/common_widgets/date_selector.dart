import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../common_widgets/round_textfield.dart';

class DateSelector extends StatelessWidget {
  final TextEditingController birthdateController;

  const DateSelector({Key? key, required this.birthdateController}) : super(key: key);

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != DateTime.now()) {
      birthdateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: RoundTextField(
          textEditingController: birthdateController,
          hintText: "Date Of Birth",
          icon: 'assets/icons/date_icon.png',
          textInputType: TextInputType.datetime,
          isObscureText: false,
        ),
      ),
    );
  }
}
