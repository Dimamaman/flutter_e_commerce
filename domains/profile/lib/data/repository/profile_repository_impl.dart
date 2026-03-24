import 'dart:io';

import 'package:common/utils/constants/app_constants.dart';
import 'package:common/utils/error/failure_response.dart';
import 'package:dartz/dartz.dart';
import 'package:dependencies/dio/dio.dart';
import 'package:profile/data/datasource/remote/profile_remote_datasource.dart';
import 'package:profile/data/mapper/profile_mapper.dart';
import 'package:profile/domain/entity/request/user_request_entity.dart';
import 'package:profile/domain/entity/response/user_entity.dart';
import 'package:profile/domain/repository/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource profileRemoteDataSource;
  final ProfileMapper mapper;

  ProfileRepositoryImpl({
    required this.profileRemoteDataSource,
    required this.mapper,
  });

  String _extractErrorMessage(DioError error) {
    final data = error.response?.data;
    if (data is Map) {
      final message = data[AppConstants.errorKey.message];
      if (message != null) return message.toString();
    }
    if (data is String && data.trim().isNotEmpty) return data;
    return error.response?.toString() ?? error.toString();
  }

  @override
  Future<Either<FailureResponse, UserEntity>> getUser() async {
    try {
      final response = await profileRemoteDataSource.getUser();
      return Right(mapper.mapUserDataDTOToUserEntity(response.data!));
    } on DioError catch (error) {
      return Left(FailureResponse(errorMessage: _extractErrorMessage(error)));
    }
  }

  @override
  Future<Either<FailureResponse, UserEntity>> updateUserData({
    required UserRequestEntity userRequestEntity,
  }) async {
    try {
      final response = await profileRemoteDataSource.updateUserData(
        userRequestDto: mapper.mapUserRequestEntityToDTO(userRequestEntity),
      );
      return Right(mapper.mapUserDataDTOToUserEntity(response.data!));
    } on DioError catch (error) {
      return Left(FailureResponse(errorMessage: _extractErrorMessage(error)));
    }
  }

  @override
  Future<Either<FailureResponse, UserEntity>> uploadPhoto({
    required File image,
  }) async {
    try {
      final response = await profileRemoteDataSource.uploadPhoto(image: image);
      return Right(mapper.mapUserDataDTOToUserEntity(response.data!));
    } on DioError catch (error) {
      return Left(FailureResponse(errorMessage: _extractErrorMessage(error)));
    }
  }
}
