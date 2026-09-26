import 'package:dartz/dartz.dart';
import 'package:bellabox/core/errors/failures.dart';
import 'package:bellabox/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, Unit>> sendOtp(String phone);
  Future<Either<Failure, User>> verifyOtp(String phone, String code);
  Future<Either<Failure, User?>> restoreSession();
  Future<Either<Failure, Unit>> logout();
}
