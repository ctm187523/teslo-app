
import 'package:teslo_shop/features/auth/domain/domain.dart';
import '../infrastructure.dart';


class AuthRepositoryImpl extends AuthRepository {

  //propiedades
  final AuthDataSource dataSource;

  //constructor
  AuthRepositoryImpl({
    //es opcional si lo obtengo lo uso si no usamos la instancia de la clase AuthDatasourceImp()
    AuthDataSource? dataSource
  }): dataSource = dataSource ?? AuthDatasourceImp();

  @override
  Future<User> checkAuthStatus(String token) {
    return dataSource.checkAuthStatus(token);
  }

  @override
  Future<User> login(String email, String password) {
    return dataSource.login(email, password);
  }

  @override
  Future<User> register(String email, String password, String fullName) {
    return dataSource.register(email, password, fullName);
  }

}