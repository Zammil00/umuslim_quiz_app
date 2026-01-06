import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../app/data/datasources/auth_remote_datasource.dart';
import '../../../../app/data/repositories/auth_repository_impl.dart';
import '../../../../app/domain/usecases/register_user_usecase.dart';
import '../controllers/register_controller.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    // Data Sources
    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(Supabase.instance.client),
    );

    // Repository
    Get.lazyPut<AuthRepositoryImpl>(
      () => AuthRepositoryImpl(Get.find<AuthRemoteDataSource>()),
    );

    // Use Cases
    Get.lazyPut<RegisterUserUseCase>(
      () => RegisterUserUseCase(Get.find<AuthRepositoryImpl>()),
    );

    // Controller
    Get.lazyPut<RegisterController>(
      () => RegisterController(Get.find<RegisterUserUseCase>()),
    );
  }
}
