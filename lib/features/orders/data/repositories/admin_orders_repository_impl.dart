// lib/features/orders/data/repositories/admin_orders_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/admin_order_entity.dart';
import '../../domain/entities/order_sub_entities.dart';
import '../../domain/repositories/admin_orders_repository.dart';
import '../datasources/admin_orders_remote_data_source.dart';

class AdminOrdersRepositoryImpl implements AdminOrdersRepository {
  final AdminOrdersRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AdminOrdersRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<AdminOrderEntity>>> getOrders({
    String? statusFilter,
  }) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      return Right(
        await remoteDataSource.getOrders(statusFilter: statusFilter),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, AdminOrderEntity>> getOrderDetails(
    String orderId,
  ) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await remoteDataSource.getOrderDetails(orderId));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<OrderItemEntity>>> getOrderItems(
    String orderId,
  ) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await remoteDataSource.getOrderItems(orderId));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<OrderStatusHistoryEntity>>> getOrderHistory(
    String orderId,
  ) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await remoteDataSource.getOrderHistory(orderId));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateOrderStatus({
    required String orderId,
    required String newStatus,
  }) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      await remoteDataSource.updateOrderStatus(
        orderId: orderId,
        newStatus: newStatus,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(BusinessRuleFailure(e.message));
    }
  }
}
