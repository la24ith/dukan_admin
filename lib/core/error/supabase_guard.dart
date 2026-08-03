// lib/core/error/supabase_guard.dart
import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'app_error_translator.dart';
import 'exceptions.dart';

Future<T> guardSupabaseCall<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on ServerException {
    // رسائل قواعد العمل المرمية يدوياً — نمررها كما هي
    rethrow;
  } on AuthException {
    rethrow;
  } on AuthApiException catch (e) {
    throw AuthException(AppErrorTranslator.translate(e.message));
  } on PostgrestException catch (e) {
    throw ServerException(AppErrorTranslator.translate(e.message));
  } on StorageException catch (e) {
    throw ServerException(AppErrorTranslator.translate(e.message));
  } on SocketException catch (_) {
    throw ServerException(AppErrorTranslator.translate('SocketException'));
  } on TimeoutException catch (_) {
    throw ServerException(AppErrorTranslator.translate('TimeoutException'));
  } catch (e) {
    throw ServerException(AppErrorTranslator.translate(e.toString()));
  }
}
