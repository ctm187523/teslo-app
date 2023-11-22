

import 'package:dio/dio.dart';
import 'package:teslo_shop/config/constants/environment.dart';
import 'package:teslo_shop/features/products/domain/domain.dart';
import 'package:teslo_shop/features/products/infrastructure/mappers/product_mapper.dart';

class ProductsDatasourceImpl extends ProductsDataSource {

  //usamos late porque no lo vamos a configurar ahora, lo configuraremos despues
  //usamamos Dio para las peticiones http
  late final Dio dio;
  final String accesToken;
  
  //constructor
  ProductsDatasourceImpl({
    required this.accesToken
  }): dio = Dio(  //configuramos DIO
    BaseOptions(
      baseUrl: Environment.apiUrl,
      headers: { //en el Headers incluimos el token para hacer la peticion, en el constructor es requerido
        'Authorization': "Bearer $accesToken"
      }
    )
  );


  @override
  Future<Product> createUpdateProduct(Map<String, dynamic> productLike) {
    // TODO: implement createUpdateProduct
    throw UnimplementedError();
  }

  @override
  Future<Product> getProductById(String id) {
    // TODO: implement getProductById
    throw UnimplementedError();
  }

  @override
  Future<List<Product>> getProductByPage({int limit = 10, int offset = 0})  async{
    final response = await dio.get<List>('/products?limit=$limit&offset=$offset');
    final List<Product> products= []; 
    for ( final product in response.data ?? []){ //si no viene la data devolvemos un String vacio
      //usamos el mapper creado por nosotros
      products.add ( ProductMapper.jsonToEntity(product));
    }
    return products;
  }

  @override
  Future<List<Product>> searchProductByTerm(String term) {
    // TODO: implement searchProductByTerm
    throw UnimplementedError();
  }

}