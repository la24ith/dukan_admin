// lib/core/di/env.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  Env._();

  static Future<void> load({bool isProd = false}) async {
    await dotenv.load(fileName: isProd ? '.env.prod' : '.env.dev');
  }

  static String get supabaseUrl => dotenv.env['SUPABASE_URL']!;
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY']!;
}
