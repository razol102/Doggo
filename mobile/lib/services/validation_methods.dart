class ValidationMethods {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }


  static   String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number cannot be empty';
    }

    // Basic regex to allow for optional country code and different formats
    final phoneNumberRegex = RegExp(r'^\+?(\d{1,3})?[-.\s]?\d{3}[-.\s]?\d{3}[-.\s]?\d{4}$');
    if (!phoneNumberRegex.hasMatch(value)) {
      return 'Enter a valid phone number';
    }

    return null;
  }

  static String? validateNotEmpty(String? value, String field) {
    if (value == null || value.isEmpty) {
      return '$field cannot be empty';
    }
    return null;
  }

  static String? validatePositiveInt(String? value, String field) {
    String? emptyError = validateNotEmpty(value, field);
    if (emptyError != null) { // field is empty
      return emptyError;
    } else if (int.tryParse(value!) == null) {
      return '$field must be an integer';
    } else if (int.tryParse(value)! < 0) {
      return '$field must be positive number';
    }
    return null;
  }

  static String? validatePositiveDouble(String? value, String field) {
    String? emptyError = validateNotEmpty(value, field);
    if (emptyError != null) { // field is empty
      return emptyError;
    } else if (double.tryParse(value!) == null) {
      return '$field must be a number';
    } else if (double.tryParse(value)! <= 0) {
      return '$field must be positive number';
    }
    return null;
  }

}