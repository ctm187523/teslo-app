

class User {

  final String id;
  final String email;
  final String fullName;
  final List<String> roles ;
  final String token;

  //constructor
  User({
    required this.id, 
    required this.email, 
    required this.fullName,
    required this.roles, 
    required this.token 
  });

  //metodo para comprobar si el usuario es administrador
  bool get isAdmin {
    return roles.contains('admin');
  }

}