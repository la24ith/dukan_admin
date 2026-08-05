// lib/core/di/injection.dart
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../network/network_info.dart';
import '../services/image_upload_service.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/domain/usecases/sign_in.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/orders/data/datasources/admin_orders_remote_data_source.dart';
import '../../features/orders/data/repositories/admin_orders_repository_impl.dart';
import '../../features/orders/domain/repositories/admin_orders_repository.dart';
import '../../features/orders/domain/usecases/orders_usecases.dart';
import '../../features/orders/presentation/cubit/admin_orders_cubit.dart';
import '../../features/orders/presentation/cubit/admin_order_details_cubit.dart';
import '../../features/categories/data/datasources/categories_remote_data_source.dart';
import '../../features/categories/data/repositories/categories_repository_impl.dart';
import '../../features/categories/domain/repositories/categories_repository.dart';
import '../../features/categories/domain/usecases/categories_usecases.dart';
import '../../features/categories/presentation/cubit/categories_cubit.dart';
import '../../features/products/data/datasources/admin_products_remote_data_source.dart';
import '../../features/products/data/repositories/admin_products_repository_impl.dart';
import '../../features/products/domain/repositories/admin_products_repository.dart';
import '../../features/products/domain/usecases/products_usecases.dart';
import '../../features/products/presentation/cubit/admin_products_cubit.dart';
import '../../features/coupons/data/datasources/coupons_remote_data_source.dart';
import '../../features/coupons/data/repositories/coupons_repository_impl.dart';
import '../../features/coupons/domain/repositories/coupons_repository.dart';
import '../../features/coupons/domain/usecases/coupons_usecases.dart';
import '../../features/coupons/presentation/cubit/coupons_cubit.dart';
import '../../features/delivery_fees/data/datasources/delivery_fees_remote_data_source.dart';
import '../../features/delivery_fees/data/repositories/delivery_fees_repository_impl.dart';
import '../../features/delivery_fees/domain/repositories/delivery_fees_repository.dart';
import '../../features/delivery_fees/domain/usecases/delivery_fees_usecases.dart';
import '../../features/delivery_fees/presentation/cubit/delivery_fees_cubit.dart';

final sl = GetIt.instance;

Future<void> setupInjection() async {
  // External
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  sl.registerLazySingleton<InternetConnection>(() => InternetConnection());

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // Auth Feature
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton(() => SignIn(sl()));
  sl.registerLazySingleton(() => GetCurrentAdmin(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerFactory(
    () => AuthCubit(
      signInUseCase: sl(),
      getCurrentAdminUseCase: sl(),
      signOutUseCase: sl(),
    ),
  );

  // Orders Feature
  sl.registerLazySingleton<AdminOrdersRemoteDataSource>(
    () => AdminOrdersRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AdminOrdersRepository>(
    () => AdminOrdersRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton(() => GetAdminOrders(sl()));
  sl.registerLazySingleton(() => GetAdminOrderDetails(sl()));
  sl.registerLazySingleton(() => GetAdminOrderItems(sl()));
  sl.registerLazySingleton(() => GetAdminOrderHistory(sl()));
  sl.registerLazySingleton(() => UpdateOrderStatus(sl()));
  sl.registerFactory(() => AdminOrdersCubit(getAdminOrdersUseCase: sl()));
  sl.registerFactory(
    () => AdminOrderDetailsCubit(
      getOrderDetailsUseCase: sl(),
      getOrderItemsUseCase: sl(),
      getOrderHistoryUseCase: sl(),
      updateOrderStatusUseCase: sl(),
    ),
  );

  // Shared Service
  sl.registerLazySingleton(() => ImageUploadService(sl()));

  // Categories Feature
  sl.registerLazySingleton<CategoriesRemoteDataSource>(
    () =>
        CategoriesRemoteDataSourceImpl(client: sl(), imageUploadService: sl()),
  );
  sl.registerLazySingleton<CategoriesRepository>(
    () => CategoriesRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton(() => GetCategories(sl()));
  sl.registerLazySingleton(() => AddCategory(sl()));
  sl.registerLazySingleton(() => UpdateCategory(sl()));
  sl.registerLazySingleton(() => DeleteCategory(sl()));
  sl.registerFactory(
    () => CategoriesCubit(
      getCategoriesUseCase: sl(),
      addCategoryUseCase: sl(),
      updateCategoryUseCase: sl(),
      deleteCategoryUseCase: sl(),
    ),
  );

  // Products Feature
  sl.registerLazySingleton<AdminProductsRemoteDataSource>(
    () => AdminProductsRemoteDataSourceImpl(
      client: sl(),
      imageUploadService: sl(),
    ),
  );
  sl.registerLazySingleton<AdminProductsRepository>(
    () =>
        AdminProductsRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton(() => GetAdminProducts(sl()));
  sl.registerLazySingleton(() => AddAdminProduct(sl()));
  sl.registerLazySingleton(() => UpdateAdminProduct(sl()));
  sl.registerLazySingleton(() => DeleteAdminProduct(sl()));
  sl.registerLazySingleton(() => AdjustProductStock(sl()));
  sl.registerFactory(
    () => AdminProductsCubit(
      getProductsUseCase: sl(),
      addProductUseCase: sl(),
      updateProductUseCase: sl(),
      deleteProductUseCase: sl(),
      adjustStockUseCase: sl(),
    ),
  );

  // Coupons Feature

  sl.registerLazySingleton<CouponsRemoteDataSource>(
    () => CouponsRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<CouponsRepository>(
    () => CouponsRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton(() => GetCoupons(sl()));
  sl.registerLazySingleton(() => AddCoupon(sl()));
  sl.registerLazySingleton(() => UpdateCoupon(sl()));
  sl.registerLazySingleton(() => DeleteCoupon(sl()));
  sl.registerFactory(
    () => CouponsCubit(
      getCouponsUseCase: sl(),
      addCouponUseCase: sl(),
      updateCouponUseCase: sl(),
      deleteCouponUseCase: sl(),
    ),
  );

  //delivery_fees

  sl.registerLazySingleton<DeliveryFeesRemoteDataSource>(
    () => DeliveryFeesRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<DeliveryFeesRepository>(
    () => DeliveryFeesRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton(() => GetDeliveryFees(sl()));
  sl.registerLazySingleton(() => AddDeliveryFee(sl()));
  sl.registerLazySingleton(() => UpdateDeliveryFee(sl()));
  sl.registerLazySingleton(() => DeleteDeliveryFee(sl()));
  sl.registerFactory(
    () => DeliveryFeesCubit(
      getFeesUseCase: sl(),
      addFeeUseCase: sl(),
      updateFeeUseCase: sl(),
      deleteFeeUseCase: sl(),
    ),
  );
}
