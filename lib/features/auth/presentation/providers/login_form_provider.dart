
//hemos instalado Riverpood

//!-State del provider

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import '../../../shared/shared.dart';

class LoginFormState {

  final bool isPosting; //para cuando hacemos la transaccion y es  asincrona verificar el ususario
  final bool isFormPosted;//cuando el usuario toca el boton de ingresar
  final bool isValid;
  final Email email;
  final Password password;

  //constructor
  LoginFormState({
    this.isPosting = false, 
    this.isFormPosted = false,
    this.isValid = false,
    this.email = const Email.pure(),
    this.password = const Password.pure()
  });

  LoginFormState copyWith({

    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    Email? email,
    Password? password,
  })=> LoginFormState(

    isPosting: isPosting ?? this.isPosting,
    isFormPosted: isFormPosted ?? this.isFormPosted,
    isValid: isValid ?? this.isValid,
    email: email ?? this. email,
    password: password ?? this.password
  );

  //sobreescribimos el metodo toString para poder imprimir sus valores por consola
  @override
  String toString(){
    return '''
      LoginFormState:
        isPosting = $isPosting 
        isFormPosted = $isFormPosted
        isValid = $isValid
        email = $email
        password = $password
  ''';
  }

}


//implementamos un notifier, usamos el snippet stateNotifier
class LoginFormNotifier extends StateNotifier<LoginFormState> {
  
  LoginFormNotifier(): super( LoginFormState()); //con LoginFormState creamos el estado inicial siempre es sincrono
  
  //metodos
  //cambiamos el email con validate lo validamos
  onEmailChange( String value) {

    final newEmail = Email.dirty(value);
    state = state.copyWith(
      email: newEmail,
      isValid: Formz.validate([newEmail, state.password])
    );
  }

  onPasswordChange( String value ){

     final newPassword = Password.dirty(value);
     state = state.copyWith(
      password: newPassword,
      isValid: Formz.validate([newPassword, state.email])
    );
  }

  //al tocar el boton de Ingresar todos los campos se verifican, hallan sido como tocados
  onFormSubmit() {

    //llamamos al metodo creado abajo
    _touchEveryField();

    if( !state.isValid) return;

    print(state);

  }

  //metodo privado, para que al hacer el submut(tocar boton ingresar)
  //se manoseen todos los campos ya que en su estado inicial son pure
  //y de esta manera al ser manoseados vemos sus posibles errores
  _touchEveryField(){

    final email = Email.dirty(state.email.value);
    final password = Password.dirty(state.password.value);

    //informamos al state de los cambios efectuados
    state = state.copyWith(
      isFormPosted: true,
      email: email,
      password: password,
      isValid: Formz.validate([email, password])
    );
  }

}




// creamos el provider StateNotifierProvider, usamos el snippet stateNotifierProvider
//usmaos el modificador de autoDispose porque al salir de la pantalla del login y volver a entrar
//limpie la informacion podria aparecer la contraseña al volver al login
final loginFormProvider = StateNotifierProvider.autoDispose<LoginFormNotifier, LoginFormState>((ref) {
  
  //creamos la instancia del loginFormNotifier
  return LoginFormNotifier();
});