
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/features/auth/infrastructure/infrastructure.dart';

import '../../domain/domain.dart';

enum AuthStatus { checking, authenticated, notAuthenticated}

//creamos una instancia de AuthRepositoryImpl de auth/infrastructure/repositories
//lo usamos al final del todo en la creacion del provider, es un argumeto que exige
//para hacer una isntancia a la clase creada abajo AuthNotifier
//para poder manejar el storage
final authRepository = AuthRepositoryImpl();


//clase para el estado, Riverpood
class AuthState {

  //propieades
  final AuthStatus authStatus;
  final User? user;
  final String errorMessage;

  //constructor
  AuthState({
    this.authStatus = AuthStatus.checking, 
    this.user,
    this.errorMessage = ''
  });

  AuthState copyWith({
    AuthStatus? authStatus,
    User? user,
    String? errorMessage
  }) => AuthState(
    authStatus: authStatus ?? this.authStatus,
    user: user ?? this.user,
    errorMessage: errorMessage ?? this.errorMessage
  );
  
}

//clase para los metodos
class AuthNotifier extends StateNotifier<AuthState> {

  //propiedad para manejar el storage fisico del dispositivo
  final AuthRepository authRepository;

  //constructor
  AuthNotifier(
    {
      required this.authRepository
    }
  ): super( AuthState());
  
  //metodos
  void loginUser(String email, String password) async {

      //creamos un retardo para que se pueda ver un loading, etc
      await Future.delayed(const Duration(microseconds: 500));
  
      try {
        
        final user = await authRepository.login(email, password);
        _setLoggedUser(user);

        //llamamos a la clase creda por nosotros WrongCrdentials de auth/infrastructure/errors
        //por si falla el trya
      } on WrongCredentials{

         //llamaos al metodo creado abajo logOut
        logOut( 'Credenciales no son correctas');
        
      }catch (e) {
        
        //llamamos al metodo creado abajo logOut, tenemos un error no controlado
        logOut( 'Error no controlado');
      }
  }

  void registerUser(String email, String password) async {

  }

  void checkAuthStatus() async {

  }

  //metodo privado comun usado en los metodos de arriba
  void _setLoggedUser( User user){

    //TODO: necesto guardar el token fisicamente en el dispositivo
    state = state.copyWith(
      user: user,
      authStatus: AuthStatus.authenticated,
    );
  }

  Future<void> logOut( [ String? errorMessage] ) async {
    //TODO: limpiar token
    state = state.copyWith(
      authStatus: AuthStatus.notAuthenticated,
      user: null,
      errorMessage: errorMessage,
    );
  }
}

//creamos el provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    authRepository: authRepository
  );
});