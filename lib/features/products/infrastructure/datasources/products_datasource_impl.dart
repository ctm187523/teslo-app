

import 'package:dio/dio.dart';
import 'package:teslo_shop/config/constants/environment.dart';
import 'package:teslo_shop/features/products/domain/domain.dart';
import 'package:teslo_shop/features/products/infrastructure/errors/product_errors.dart';
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


  //metodo para crear o actualizar producto
  //sabemos si estamos creando o actualizando un producto si tenemos o no el id
  @override
  Future<Product> createUpdateProduct(Map<String, dynamic> productLike) async{
    
    try {

      final String? productId = productLike['id']; //el productId es opcional si viene actualizamos sino creamos
      final String method = (productId == null) ? 'POST' : 'PATCH'; //si no viene(queremos crear un nuevo producto ver product_form_provider linea 102) creamos(POST) si no actualizamos(PATCH),  PUT es reemplazo completo de la entidad, PATCH sólo de una parte

      //para hacer el PATCH en la URL ponemos el id para hacer un POST no
      final String url = (productId == null) ? '/products':'/products/$productId';
      
      //una vez sabemos si es POST o PATCH borramos el id ya que solo se utiliza para saber que metodo usar
      productLike.remove('id');

      //hacemos la peticion, enviamos la url, la data(el productLike) y en las Options el metodo(post o patch)
      final response = await dio.request(
        url,
        data: productLike,
        options: Options(
          method: method
        )
      );

      //trasnformamos la respuesta en JSON a un objeto de la clase Product, usamos ProductMapper creado anteriormente
      final product = ProductMapper.jsonToEntity(response.data);

      return product; //regresamos el nuevo producto creado o actualizado

    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<Product> getProductById(String id) async{
    
    try {
      
      final response = await dio.get('/products/$id');
      final product = ProductMapper.jsonToEntity(response.data);
      return product;
    
    }on DioException catch(e) {
      if( e.response!.statusCode == 404) throw ProductNotFound();
      throw Exception();
    }catch (e) {
      throw Exception();
    }
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