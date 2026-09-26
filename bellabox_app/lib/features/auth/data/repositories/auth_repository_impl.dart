import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bellabox/core/errors/exceptions.dart';
import 'package:bellabox/core/errors/failures.dart';
import 'package:bellabox/core/storage/secure_storage.dart';
import 'package:bellabox/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:bellabox/features/auth/domain/entities/user.dart';
import 'package:bellabox/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final SecureStorage _storage;

  AuthRepositoryImpl(this._remote, this._storage);

  @override
  Future<Either<Failure, Unit>> sendOtp(String phone) async {
    try {
      await _remote.sendOtp(phone: phone);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(mapExceptionToFailure(e.error ?? e));
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> verifyOtp(String phone, String code) async {
    try {
      final result = await _remote.verifyOtp(phone: phone, code: code);
      await _storage.write(SecureStorage.tokenKey, result.token);
      await _storage.write(
        SecureStorage.userKey,
        jsonEncode(result.user.toJson()),
      );
      return Right(result.user);
    } on DioException catch (e) {
      return Left(mapExceptionToFailure(e.error ?? e));
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> restoreSession() async {
    try {
      final token = await _storage.read(SecureStorage.tokenKey);
      if (token == null || token.isEmpty) return const Right(null);

      // Try cached user first for instant restore
      final cachedJson = await _storage.read(SecureStorage.userKey);
      User? cached;
      if (cachedJson != null) {
        try {
          cached = User.fromJson(jsonDecode(cachedJson) as Map<String, dynamic>);
        } catch (_) {
          cached = null;
        }
      }

      // Validate token against /auth/me in background-safe way
      try {
        final fresh = await _remote.me();
        await _storage.write(SecureStorage.userKey, jsonEncode(fresh.toJson()));
        return Right(fresh);
      } on DioException catch (e) {
        final err = e.error;
        if (err is UnauthorizedException) {
          // Token expired — clear session
          await _clearSession();
          return const Right(null);
        }
        // Network problem: fall back to cached user (offline-tolerant)
        if (cached != null) return Right(cached);
        return const Right(null);
      }
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      try {
        await _remote.logout();
      } catch (_) {
        // Even if server logout fails, clear locally
      }
      await _clearSession();
      return const Right(unit);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<void> _clearSession() async {
    await _storage.delete(SecureStorage.tokenKey);
    await _storage.delete(SecureStorage.userKey);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    SecureStorage.instance,
  );
});
