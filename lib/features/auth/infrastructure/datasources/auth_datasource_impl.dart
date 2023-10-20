

import 'package:dio/dio.dart';
import 'package:teslo_shop/config/config.dart';
import 'package:teslo_shop/features/auth/domain/domain.dart';
import 'package:teslo_shop/features/auth/infrastructure/infrastructure.dart';


//para gestionar las peticiones http he instalado DIO --> flutter pub add dio
class AuthDatasourceImp extends AuthDataSource {

  //implementamos DIO para manejar las peticiones http
  final dio = Dio(
     BaseOptions(
      baseUrl: Environment.apiUrl,
    )
  );


  @override
  Future<User> checkAuthStatus(String token) {
    // TODO: implement checkAuthStatus
    throw UnimplementedError();
  }

  @override
  Future<User> login(String email, String password)  async{

      try {
        final response = await dio.post('/auth/login',
            data: {
                'email':email,
                'password':password
        });

        //usamos la clase creada por nosotros en infrastructure/mappers para mapear
        //la respuesta en Json y pasarla a la entidad User
        final user = UserMapper.userJsonToEntity(response.data);
        return user;
      
      //controlamos un tipo de error de dio
      } on DioException catch (e) {

          if(e.response?.statusCode == 401) throw WrongCredentials();  //usamos la clase WrongCredentials creada en infrastructure/errors
          if(e.type == DioExceptionType.connectionTimeout) throw ConnectionTimeout; //usamos la clase ConnectionTimeout creada en infrastructure/errors
          throw CustomError('Something worng happend', 1); //usamos la clase CustomError creada en infrastructure/errors
      }catch (e) {
           throw CustomError('Something worng happend', 1); //usamos la clase CustomEr creada en infrastructure/errors
      }
  }

  @override
  Future<User> register(String email, String password, String fullName) {
    // TODO: implement register
    throw UnimplementedError();
  }

}