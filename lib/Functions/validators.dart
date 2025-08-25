String? validateEmail(String? value) {
  if (value == null || value.isEmpty) return 'Please enter your email';
  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
    return 'Please enter a valid email';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Please enter your password';
  if (value.length < 6) return 'Password must be at least 6 characters long';
  return null;
}

String? validatePhone(String? value) {
  if (value == null || value.isEmpty) return 'Please enter your phone number';
  if (!RegExp(r'^\d{10}$').hasMatch(value)) {
    return 'Phone number must be 10 digits';
  }
  return null;
}

String? validateDoubleField(String? value) {
  if (value == null || value.isEmpty) {
    return 'This field cannot be empty';
  }
  final parsed = double.tryParse(value);
  if (parsed == null) {
    return 'Please enter a valid number';
  }
  if (parsed < 0) {
    return 'Please enter a positive number';
  }
  return null;
}

String? validateStringField(String? value) {
  if (value == null || value.isEmpty) return 'This field cannot be empty';
  return null;
}

String? validateName(String? value) {
  if (value == null || value.isEmpty) {
    return 'This field cannot be empty';
  }
  return null;
}

String? validateIntField(String? value) {
  if (value == null || value.isEmpty) {
    return 'This field cannot be empty';
  }
  final parsed = int.tryParse(value);
  if (parsed == null) {
    return 'Please enter a valid number';
  }
  if (parsed < 0) {
    return 'Please enter a positive number';
  }
  return null;
}
