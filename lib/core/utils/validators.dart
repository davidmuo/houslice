/// Form validation rules.
///
/// Houseslice is a verified student-only marketplace, so registration is
/// gated behind university email domains (see [allowedDomains]).
abstract final class Validators {
  /// University domains accepted at registration. Extend this list as the
  /// platform onboards more institutions.
  static const allowedDomains = [
    'alustudent.com',
    'alueducation.com',
    'ur.ac.rw',
    'auca.ac.rw',
  ];

  static final _emailRegex =
      RegExp(r'^[\w\.\-\+]+@([\w\-]+\.)+[a-zA-Z]{2,}$');

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(v)) return 'Enter a valid email address';
    return null;
  }

  /// Registration only: the email must belong to a supported university.
  static String? studentEmail(String? value) {
    final basic = email(value);
    if (basic != null) return basic;
    final domain = value!.trim().split('@').last.toLowerCase();
    if (!allowedDomains.contains(domain)) {
      return 'Use your university email (e.g. name@alustudent.com)';
    }
    return null;
  }

  static String? username(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Username is required';
    if (v.length < 3) return 'Username must be at least 3 characters';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    final basic = password(value);
    if (basic != null) return basic;
    if (value != original) return 'Passwords do not match';
    return null;
  }
}
