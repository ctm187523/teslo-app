


//hemos instalado Riverpood

//State del provider

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:teslo_shop/features/auth/presentation/providers/auth_provider.dart';
import 'package:teslo_shop/features/shared/infrastructure/inputs/confirmedpassword.dart';
import 'package:teslo_shop/features/shared/infrastructure/inputs/fullname.dart';

import '../../../shared/shared.dart';

class RegisterFormState {

  final bool isPosting; //para cuando hacemos la transaccion y es asincrona verificar el ususario
  final bool isFormPosted;//cuando el usuario toca el boton de ingresar
  final bool isValid;
  final Email email;
  final Password password;
  final ConfirmedPassword confirmedPassword;
  final FullName fullName;
  

  //constructor
  RegisterFormState({
    this.isPosting = false, 
    this.isFormPosted = false,
    this.isValid = false,
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.confirmedPassword = const ConfirmedPassword.pure(),
    this.fullName = const FullName.pure(),
  });

  RegisterFormState copyWith({

    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    Email? email,
    Password? password,
    ConfirmedPassword? confirmedPassword,
    FullName? fullName
  })=> RegisterFormState(

    isPosting: isPosting ?? this.isPosting,
    isFormPosted: isFormPosted ?? this.isFormPosted,
    isValid: isValid ?? this.isValid,
    email: email ?? this. email,
    password: password ?? this.password,
    confirmedPassword: confirmedPassword ?? this.confirmedPassword,
    fullName: fullName ?? this.fullName,
  );

  //sobreescribimos el metodo toString para poder imprimir sus valores por consola
  @override
  String toString(){
    return '''
      RegisterFormState:
        isPosting = $isPosting 
        isFormPosted = $isFormPosted
        isValid = $isValid
        email = $email
        password = $password
        confirmedPassword = $confirmedPassword
        fullname = $fullName
  ''';
  }

  void onFormSubmit() {}

}


//implementamos un notifier, usamos el snippet stateNotifier
class RegisterFormNotifier extends StateNotifier<RegisterFormState> {
  
  //propiedad que recibe una funcion, que hara referencia al metodo registerUser del provider auth_provider
  //es recibida por el metodo creado al final registerFormProvider
  final Function(String,String,String) registerUserCallback;

  //constructor
  RegisterFormNotifier(
    {
      required this.registerUserCallback,
    }
  ): super( RegisterFormState()); //con LoginFormState creamos el estado inicial siempre es sincrono
  
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

  onConfirmedPassWord ( String value) {
    final newConfirmedPassword = ConfirmedPassword.dirty(original: state.password , value);
    state = state.copyWith(
      confirmedPassword: newConfirmedPassword,
      isValid: Formz.validate([ newConfirmedPassword, state.confirmedPassword])
    );
  }

  onFullNameChange ( String value) {

    final newFullName = FullName.dirty(value);
    state = state.copyWith(
      fullName: newFullName,
      isValid: Formz.validate([newFullName, state.fullName])
    );
  }

  //al tocar el boton de Ingresar todos los campos se verifican, hallan sido como tocados
  onFormSubmit() async{

    //llamamos al metodo creado abajo
    _touchEveryField();

    if( !state.isValid) return;

    //llamamos a la funcion recibida por parametro(loginUser de auth_provider)
    //para que una vez echas las validaciones haga la peticion http
    await registerUserCallback(state.email.value, state.password.value, state.fullName.value);

  }

  //metodo privado, para que al hacer el submit(tocar boton ingresar)
  //se manoseen todos los campos ya que en su estado inicial son pure
  //y de esta manera al ser manoseados vemos sus posibles errores
  _touchEveryField(){

    final email = Email.dirty(state.email.value);
    final password = Password.dirty(state.password.value);
    final confirmedPassword = ConfirmedPassword.dirty(original: password, state.confirmedPassword.value);
    final fullName = FullName.dirty(state.fullName.value);

    //informamos al state de los cambios efectuados
    state = state.copyWith(
      isFormPosted: true,
      email: email,
      password: password,
      confirmedPassword: confirmedPassword,
      fullName: fullName,
      isValid: Formz.validate([email, password, confirmedPassword,  fullName])
    );
  }

}




// creamos el provider StateNotifierProvider, usamos el snippet stateNotifierProvider
//usamos el modificador de autoDispose porque al salir de la pantalla del login y volver a entrar
//limpie la informacion podria aparecer la contraseña al volver al login
final registerFormProvider = StateNotifierProvider.autoDispose<RegisterFormNotifier, RegisterFormState>((ref) {
  
  //hacemos una referencia al provider authProvider y su metodo loginUser
  final registerUserCallback = ref.watch(authProvider.notifier).registerUser;

  //creamos la instancia del loginFormNotifier(clase creada arriba) y le enviamos el parametro requerido
  return RegisterFormNotifier(
    registerUserCallback: registerUserCallback
  );
});