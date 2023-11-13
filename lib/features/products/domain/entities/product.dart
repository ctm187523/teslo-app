
//usamos Paste Json as Code con command+shift+p, habiendo previamente
//copiado de Postman el resultado de la consulta http://localhost:3000/api/products
//hemos puesto de nombre Product, hemos echo variaciones para adaptarlo


import '../../../auth/domain/entities/user.dart';

class Product {
  String id;
  String title;
  int price;
  String description;
  String slug;
  int stock;
  List<String> sizes;
  String gender;
  List<String> tags;
  List<String> images;
  User? user;           //importamos el Usuario de auth/domain/entities/user

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.slug,
    required this.stock,
    required this.sizes,
    required this.gender,
    required this.tags,
    required this.images,
    required this.user,
  });
}