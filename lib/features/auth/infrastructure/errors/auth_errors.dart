

//clases para manejar los errores al hacer una llamada http
class ConnectionTimeout implements Exception{}
class InvalidToken implements Exception{}
class WrongCredentials implements Exception {}

//clase para manejar errores personalizados
class CustomError implements Exception {

  //propiedades
  final String message;
  final int errorCode;

  //constructor
  CustomError(this.message, this.errorCode);


}