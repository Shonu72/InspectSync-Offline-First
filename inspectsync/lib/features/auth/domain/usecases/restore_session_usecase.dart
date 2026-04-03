import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RestoreSessionUseCase implements UseCase<UserEntity?, NoParams> {
  final IAuthRepository repository;

  RestoreSessionUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity?>> call(NoParams params) async {
    return await repository.restoreSession();
  }
}
