
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/features/auth/infrastructure/infrastructure.dart';
import 'package:teslo_shop/features/shared/infrastructure/services/key_value_storage_service.dart';

import '../../../shared/infrastructure/services/key_value_storage_service_impl.dart';
import '../../domain/domain.dart';

enum AuthStatus { checking, authenticated, notAuthenticated}


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
  //propiedad para poder grabar,obtener,borrar en el disco duro los tokens
  final KeyValueStorageService keyValueStorageService;

  //constructor
  AuthNotifier(
    {
      required this.authRepository,
      required this.keyValueStorageService
    }
  ): super( AuthState());
  
  //metodos
  Future<void> loginUser(String email, String password) async {

      //creamos un retardo para que se pueda ver un loading, etc, al ser el backend local 
      //es mas rapido que si fuera remoto, lo simulamos
      await Future.delayed(const Duration(microseconds: 500));
  
      try {
        
        final user = await authRepository.login(email, password);
        _setLoggedUser(user);

        //llamamos a la clase creda por nosotros CustomError de auth/infrastructure/errors
        //por si falla el try y implementada en auth_datasource_impl linea 45
      } on CustomError catch (e){

         //llamaos al metodo creado abajo logOut
        logOut( e.message);
   
      }catch (e) {
        
        //llamamos al metodo creado abajo logOut, tenemos un error no controlado
        logOut( 'Errror no controlado');
      }
  }

  void registerUser(String email, String password, String fullName) async {

      //creamos un retardo para que se pueda ver un loading, etc, al ser el backend local 
      //es mas rapido que si fuera remoto, lo simulamos
       await Future.delayed(const Duration(microseconds: 500));

        try {
        
        final user = await authRepository.register(email,password,fullName);
        _setLoggedUser(user);

        //llamamos a la clase creda por nosotros CustomError de auth/infrastructure/errors
        //por si falla el try y implementada en auth_datasource_impl linea 75
      } on CustomError catch (e){

         //llamamos al metodo creado abajo logOut
        logOut( e.message);
   
      }catch (e) {
        
        //llamamos al metodo creado abajo logOut, tenemos un error no controlado
        logOut( 'Errror no controlado');
      }
  }

  void checkAuthStatus() async {

  }

  //metodo privado comun usado en los metodos de arriba
  void _setLoggedUser( User user) async {

    //guardamos el token en el disco duro usando el storage_service implementado 
    await keyValueStorageService.setKeyValue('token', user.token);
    
    state = state.copyWith(
      user: user,
      authStatus: AuthStatus.authenticated,
      errorMessage: '',    //borramos el mensaje
    );
  }

  Future<void> logOut( [ String? errorMessage] ) async {
    //guardamos el token del disco duro usando el storage_service implementado 
    await keyValueStorageService.removeValue('token');
    
    state = state.copyWith(
      authStatus: AuthStatus.notAuthenticated,
      user: null,
      errorMessage: errorMessage,
    );
  }
}

//creamos el provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  
  //creamos una instancia de AuthRepositoryImpl de auth/infrastructure/repositories
  //lo usamos al final del todo en la creacion del provider, es un argumento que exige
  //para hacer una instancia a la clase creada abajo AuthNotifier
  //para poder manejar el storage, esta instancia la pueden usar todas las clases del archivo
  final authRepository = AuthRepositoryImpl();

  //creamos una instancia de la clase creada por nosotros KeyValueStorageServiceImpl para manejar las sharedPreferences
  //y poder guardar en el disco duro los tokens
  final keyValueStorageService = KeyValueStorageServiceImpl();
  
  return AuthNotifier(
    authRepository: authRepository,
    keyValueStorageService: keyValueStorageService,

  );
});