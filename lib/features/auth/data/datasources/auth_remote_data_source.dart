// lib/features/auth/data/datasources/auth_remote_data_source.dart
import 'package:dukan_admin/core/error/supabase_guard.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../../../core/error/app_error_translator.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/phone_validator.dart';
import '../models/admin_model.dart';

abstract class AuthRemoteDataSource {
  Future<AdminModel> signIn({required String phone, required String password});
  Future<AdminModel?> getCurrentAdmin();
  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient client;
  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<AdminModel> signIn({
    required String phone,
    required String password,
  }) async {
    debugPrint(
      '[AUTH] محاولة تسجيل دخول: ${PhoneValidator.toFakeEmail(phone)}',
    );

    late final AuthResponse response;
    try {
      response = await client.auth.signInWithPassword(
        email: PhoneValidator.toFakeEmail(phone),
        password: password,
      );
      debugPrint(
        '[AUTH] signInWithPassword نجح — user id: ${response.user?.id}',
      );
    } on AuthApiException catch (e) {
      debugPrint(
        '[AUTH] AuthApiException: ${e.message} | statusCode: ${e.statusCode}',
      );
      throw AuthException(AppErrorTranslator.translate(e.message));
    } catch (e) {
      debugPrint('[AUTH] خطأ غير متوقع أثناء signIn: ${e.runtimeType} — $e');
      throw ServerException(AppErrorTranslator.translate(e.toString()));
    }

    if (response.user == null) {
      debugPrint('[AUTH] response.user == null بعد signIn الناجح!');
      throw ServerException('فشل تسجيل الدخول');
    }

    debugPrint('[AUTH] نقرأ الـ profile للمستخدم: ${response.user!.id}');

    return guardSupabaseCall(() async {
      try {
        final profileRow = await client
            .from('profiles')
            .select()
            .eq('id', response.user!.id)
            .single();

        debugPrint('[AUTH] profile row: $profileRow');

        final model = AdminModel.fromJson(profileRow);
        debugPrint(
          '[AUTH] role المستخدم: ${model.role} | isAdmin: ${model.isAdmin}',
        );

        if (!model.isAdmin) {
          debugPrint('[AUTH] الحساب ليس أدمن — تسجيل خروج فوري');
          await client.auth.signOut();
          throw ServerException(
            'هذا الحساب ليس حساب أدمن. يُرجى التواصل مع المسؤول.',
          );
        }

        return model;
      } on PostgrestException catch (e) {
        debugPrint(
          '[AUTH] PostgrestException عند قراءة profiles: '
          'code=${e.code} | message=${e.message} | details=${e.details} | hint=${e.hint}',
        );
        rethrow;
      }
    });
  }

  @override
  Future<AdminModel?> getCurrentAdmin() async {
    return guardSupabaseCall(() async {
      final user = client.auth.currentUser;
      if (user == null) {
        debugPrint('[AUTH] getCurrentAdmin: لا يوجد مستخدم حالي');
        return null;
      }

      debugPrint('[AUTH] getCurrentAdmin: يقرأ profile للمستخدم ${user.id}');

      final profileRow = await client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      final model = AdminModel.fromJson(profileRow);
      debugPrint('[AUTH] getCurrentAdmin role: ${model.role}');

      if (!model.isAdmin) {
        debugPrint('[AUTH] getCurrentAdmin: ليس أدمن — تسجيل خروج');
        await client.auth.signOut();
        return null;
      }

      return model;
    });
  }

  @override
  Future<void> signOut() async {
    return guardSupabaseCall(() => client.auth.signOut());
  }
}
