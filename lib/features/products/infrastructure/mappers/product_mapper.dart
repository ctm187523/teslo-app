

import 'package:teslo_shop/config/constants/environment.dart';
import 'package:teslo_shop/features/auth/infrastructure/infrastructure.dart';
import 'package:teslo_shop/features/products/domain/domain.dart';

class ProductMapper {

  static jsonToEntity( Map<String, dynamic> json ) => Product(
      id: json['id'], 
      title: json['title'],
      price: double.parse( json['price'].toString()), //al ser double debemos hacer una conversion, hay veces que nos devuelve entero
      description: json['description'], 
      slug: json['slug'], 
      stock: json['stock'], //al ser entero no debemos hacer conversion, siempre retorna un entero
      sizes: List<String>.from( json['sizes'].map( (size) => size)), //extraemos las tallas recibidas del Json y las colocamos al List de String
      gender: json['gender'], 
      tags: List<String>.from( json['tags'].map( (tag) => tag)), //extraemos los tags recibidos del Json y las colocamos al List de String, 
      images: List<String>.from( //mapeamos las imagenes recibidas del Json y discriminamos si enpiezan por http(devolvemos la imagen), si no la tratamos
        json['images'].map(
        (image) => image.startsWith('http')
          ? image
          : '${Environment.apiUrl}/files/product/$image',
        )
      ), 
      user: UserMapper.userJsonToEntity( json['user']) //usamos el mapper ya creado por nosotros
    );
}