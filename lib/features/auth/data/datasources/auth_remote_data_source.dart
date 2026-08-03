// lib/features/auth/data/datasources/auth_remote_data_source.dart
import 'package:dukan_admin/core/error/supabase_guard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
    return guardSupabaseCall(() async {
      // تسجيل الدخول بنفس آلية تطبيق الزبون (fake email)
      final response = await client.auth.signInWithPassword(
        email: PhoneValidator.toFakeEmail(phone),
        password: password,
      );

      if (response.user == null) {
        throw ServerException('فشل تسجيل الدخول');
      }

      // التحقق إن الحساب فعلاً admin — هذا الفحص الأمني الأساسي
      // حتى لو تجاوز شخص للـ Auth ما يقدر يستخدم الأدمن لأنه بيتصد هون
      final profileRow = await client
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .single();

      final model = AdminModel.fromJson(profileRow);

      if (!model.isAdmin) {
        // مستخدم عادي — نسجّل خروجه فوراً ونرفضه
        await client.auth.signOut();
        throw ServerException(
          'هذا الحساب ليس حساب أدمن. يُرجى التواصل مع المسؤول.',
        );
      }

      return model;
    });
  }

  @override
  Future<AdminModel?> getCurrentAdmin() async {
    return guardSupabaseCall(() async {
      final user = client.auth.currentUser;
      if (user == null) return null;

      final profileRow = await client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      final model = AdminModel.fromJson(profileRow);

      // لو الجلسة لا تزال موجودة لكن الرول تغيّر — نسجّل خروجه
      if (!model.isAdmin) {
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
