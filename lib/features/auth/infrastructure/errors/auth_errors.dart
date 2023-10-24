

//clases para manejar los errores al hacer una llamada http
class ConnectionTimeout implements Exception{}
class InvalidToken implements Exception{}
class WrongCredentials implements Exception {}

//clase para manejar errores personalizados
class CustomError implements Exception {

  //propiedades
  final String message;
  //final bool loggedRequired; //para hacer un log un registro
 // final int errorCode;  //para registrar el codigo del error si tuvieramos un log

  //constructor
  CustomError(this.message);
}