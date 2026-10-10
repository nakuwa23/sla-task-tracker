/// Shared form-validation rules. Each function returns `null` when the
/// value is valid, or an error string to show under the field.
class Validators {
  Validators._();

  static String? requiredText(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  static String? minLength(String? value, int min, {String field = 'This field'}) {
    if (value == null || value.trim().length < min) {
      return '$field must be at least $min characters';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Work email is required';
    final pattern = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
    if (!pattern.hasMatch(value.trim())) return 'Enter a valid work email';
    return null;
  }

  /// Ensures the due date is strictly after the start date.
  static String? dueAfterStart(DateTime? start, DateTime? due) {
    if (due == null) return 'Due date is required';
    if (start != null && !due.isAfter(start)) {
      return 'Due date must be after the start date';
    }
    return null;
  }
}
