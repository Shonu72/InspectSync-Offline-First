import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../api/api_client.dart';
import '../api/interceptors/auth_interceptor.dart';
import '../db/app_database.dart';
import '../network/connectivity_service.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/restore_session_usecase.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  const storage = FlutterSecureStorage();
  sl.registerLazySingleton(() => storage);
  
  final dio = Dio();
  sl.registerLazySingleton(() => dio);
  
  sl.registerLazySingleton(() => AuthInterceptor(storage: sl()));
  sl.registerLazySingleton(() => ApiClient(dio: sl(), authInterceptor: sl()));
  
  sl.registerLazySingleton(() => AppDatabase());
  sl.registerLazySingleton(() => ConnectivityService());

  // Features - Auth
  // DataSources
  sl.registerLazySingleton<IAuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(apiClient: sl()));
  
  // Repositories
  sl.registerLazySingleton<IAuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl(), storage: sl()));
  
  // UseCases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => RestoreSessionUseCase(sl()));
  
  // Cubits
  sl.registerFactory(() => AuthCubit(
    loginUseCase: sl(), 
    logoutUseCase: sl(),
    restoreSessionUseCase: sl(),
  ));
  
  // Features - Tasks
  // (We'll add these as we migrate the Task feature)
}
