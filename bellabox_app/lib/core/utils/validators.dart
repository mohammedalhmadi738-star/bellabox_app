class Validators {
  Validators._();

  /// Saudi mobile validation: local (05xxxxxxxx or 5xxxxxxxx) or +9665xxxxxxxx
  static bool isValidSaudiPhone(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    // Local formats
    if (RegExp(r'^5\d{8}$').hasMatch(digits)) return true;
    if (RegExp(r'^05\d{8}$').hasMatch(digits)) return true;
    if (RegExp(r'^9665\d{8}$').hasMatch(digits)) return true;
    if (RegExp(r'^009665\d{8}$').hasMatch(digits)) return true;
    return false;
  }

  static bool isValidEmail(String input) {
    return RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(input.trim());
  }

  static bool isNotEmpty(String? input) => input != null && input.trim().isNotEmpty;
}
