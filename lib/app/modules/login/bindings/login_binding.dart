import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../app/data/datasources/auth_remote_datasource.dart';
import '../../../../app/data/repositories/auth_repository_impl.dart';
import '../../../../app/domain/usecases/login_user_usecase.dart';
import '../controllers/login_controller.dart';

class LoginBinding extends Bindings {
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

    // Use Case
    Get.lazyPut<LoginUserUseCase>(
      () => LoginUserUseCase(Get.find<AuthRepositoryImpl>()),
    );

    // Controller
    Get.lazyPut<LoginController>(
      () => LoginController(Get.find<LoginUserUseCase>()),
    );
  }
}
