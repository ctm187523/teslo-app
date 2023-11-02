

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


  //manejamos el checking del estado del usuario, si tine un token valido
  @override
  Future<User> checkAuthStatus(String token) async{
    
    try {
      
      final response = await dio.get('/auth/check-status',
       
       //parametros de Dio
       options: Options(
        headers: {
          'Authorization': 'Bearer $token'
        }
       )
      );

      final user = UserMapper.userJsonToEntity(response.data);
      return user;
    
    } on DioException catch (e) {

      if(e.response?.statusCode == 401) {
        throw CustomError('Token incorrecto');
      }
      throw Exception(); //excepcion no controlada
      }catch (e) {
          throw Exception();  //excepcion no controlada
      }
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

          if(e.response?.statusCode == 401) {
            throw CustomError(e.response?.data['message'] ?? 'Credenciales incorrectas');  //si no viene usamos el string Credenciales incorrectas
          }
          if(e.type == DioExceptionType.connectionTimeout) {
            throw CustomError('Revisar conexión de internet'); 
          }
          throw Exception(); //excepcion no controlada
      }catch (e) {
           throw Exception();  //excepcion no controlada
      }
  }

  @override
  Future<User> register(String email, String password, String fullName) async{
     try {
        final response = await dio.post('/auth/register',
            data: {
                'email':email,
                'password':password,
                'fullName':fullName,
        });

        //usamos la clase creada por nosotros en infrastructure/mappers para mapear
        //la respuesta en Json y pasarla a la entidad User
        final user = UserMapper.userJsonToEntity(response.data);
        return user;
      
      //controlamos un tipo de error de dio
      } on DioException catch (e) {

          if(e.response?.statusCode == 401) {
            throw CustomError(e.response?.data['message'] ?? 'Credenciales incorrectas');  //si no viene usamos el string Credenciales incorrectas
          }
          if(e.type == DioExceptionType.connectionTimeout) {
            throw CustomError('Revisar conexión de internet'); 
          }
          throw Exception(); //excepcion no controlada
      }catch (e) {
           throw Exception();  //excepcion no controlada
      }
  }

}