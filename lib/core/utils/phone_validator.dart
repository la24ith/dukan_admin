// lib/core/utils/phone_validator.dart
class PhoneValidator {
  PhoneValidator._();

  static bool isValid(String phone) {
    final cleaned = phone.trim();
    return cleaned.startsWith('09') && cleaned.length == 10;
  }

  static String toFakeEmail(String phone) => '$phone@salla-app.com';
}
