// lib/core/error/app_error_translator.dart
class AppErrorTranslator {
  AppErrorTranslator._();

  static final RegExp _arabicPattern = RegExp(r'[\u0600-\u06FF]');

  static String translate(String raw) {
    if (_arabicPattern.hasMatch(raw)) return raw;

    final msg = raw.toLowerCase();

    if (msg.contains('invalid login credentials')) {
      return 'رقم الهاتف أو كلمة المرور غير صحيحة';
    }
    if (msg.contains('already registered') ||
        msg.contains('already exists') ||
        msg.contains('user_already_exists')) {
      return 'هذا الرقم مسجّل مسبقًا';
    }
    if (msg.contains('rate limit') || msg.contains('too many requests')) {
      return 'محاولات كثيرة، الرجاء الانتظار قليلًا';
    }
    if (msg.contains('jwt expired') || msg.contains('session') && msg.contains('expired')) {
      return 'انتهت صلاحية الجلسة، الرجاء تسجيل الدخول مجددًا';
    }
    if (msg.contains('permission denied')) {
      return 'ليس لديك صلاحية لتنفيذ هذا الإجراء';
    }
    if (msg.contains('duplicate key') || msg.contains('unique constraint')) {
      return 'هذا العنصر موجود مسبقًا';
    }
    if (msg.contains('socketexception') || msg.contains('failed host lookup')) {
      return 'تعذّر الاتصال بالخادم، تحقق من اتصالك';
    }
    if (msg.contains('timeoutexception')) {
      return 'استغرق الاتصال وقتًا طويلًا، حاول مجددًا';
    }

    return 'حدث خطأ غير متوقع، الرجاء المحاولة مجددًا';
  }
}
