
import 'package:formz/formz.dart';
import 'package:teslo_shop/features/shared/infrastructure/inputs/password.dart';

// Define input validation errors
enum PasswordError { empty, length, format,match }

// Extend FormzInput and provide the input type and error type.
class ConfirmedPassword extends FormzInput<String, PasswordError> {

  //creamos una instancia de Password
  final Password original;
  
  static final RegExp passwordRegExp = RegExp(
    r'(?:(?=.*\d)|(?=.*\W+))(?![.\n])(?=.*[A-Z])(?=.*[a-z]).*$',
  );

  // Call super.pure to represent an unmodified form input.
  const ConfirmedPassword.pure() : original = const Password.pure(), super.pure('');

  // Call super.dirty to represent a modified form input.
  const ConfirmedPassword.dirty(String value, {required this.original }) : super.dirty(value);


  String? get errorMessage {
    if ( isValid || isPure ) return null;

    if ( displayError == PasswordError.empty ) return 'El campo es requerido';
    if ( displayError == PasswordError.length ) return 'Mínimo 6 caracteres';
    if ( displayError == PasswordError.format ) return 'Debe de tener Mayúscula, letras y un número';
    if ( displayError == PasswordError.match) return 'Las contraseñas no coinciden';
    return null;
  }


  // Override validator to handle validating a given input value.
  @override
  PasswordError? validator(String value) {

    if ( value.isEmpty || value.trim().isEmpty ) return PasswordError.empty;
    if ( value.length < 6 ) return PasswordError.length;
    if ( !passwordRegExp.hasMatch(value) ) return PasswordError.format;
    if ( value != original.value) return PasswordError.match;
    return null;
  }
}