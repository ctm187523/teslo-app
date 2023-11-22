

import 'package:teslo_shop/features/auth/domain/domain.dart';

//clase para mapear el Json recibido a la entidad User
class UserMapper {

  static User userJsonToEntity(Map<String,dynamic> json) =>User(
      id: json['id'],
      email: json['email'],
      fullName: json['fullName'], 
      roles: List<String>.from(json['roles'].map(( role) => role)), //es una lista de roles
      token: json['token'] ?? '' //si no viene null
  );
}