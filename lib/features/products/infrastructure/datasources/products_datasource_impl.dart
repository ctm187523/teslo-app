

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


  //metodo para tratar cada una de las imagenes, comprobamos si tiene /
  //es llamado por el metodo creado abajo _uploadPhotos
  Future<String> _uploadFile ( String path ) async {

    try {
      
      //si tiene slash cortamos el path y solo nos quedamos con la ultima parte que es la que contiene el nombre de la imagen
      //ya en el backend, el backend le pondra un id unico
      final fileName = path.split('/').last;

      //el objeto data contendra la imagen, ya con el formato correcto
      final FormData data = FormData.fromMap({
        'file': MultipartFile.fromFileSync(path, filename: fileName) //la llave que pide el backend el file,mandamos el path del dispositivo
      });

      //hacemos una peticion psot al backend con la imagen
      final response = await dio.post('/files/product', data: data); 

      //devolvemos la imagen recibida con el nuevo path creado en el backend
      return response.data['image'];
    } catch (e) {
      throw Exception();
    }
  }

  //metodo para hacer que las imagenes que vienen del dispositvo o tomadas con la camara, tengan
  //una identificacion de la imagen correcta, ya que si no la tratamos mandariamos al backend
  //la direccion url de donde se ubica la imagen en el dispositivo ej: cleme/documents/ , debemos
  //enviar al backend un correcto id sin barras inclinadas /
  Future<List<String>> _uploadPhotos(List<String> photos ) async {
    
    //discriminamos las imagenes que contienen slash /
    final photosToUpload = photos.where((element) => element.contains('/') ).toList();
    final photosToIgnore = photos.where((element) => !element.contains('/') ).toList();

    final List<Future<String>> uploadJob = photosToUpload.map(
      (e) => _uploadFile(e) //llamamos al metodo de arriba
      ).toList();

    final newImages = await Future.wait(uploadJob);

    return [...photosToIgnore, ...newImages]; //retornamos las imagenes que no habia que modificar y las imagenes que vienen del dispositivo o de tomar una foto modificadas
  }



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

      //llamamos ala funcion creada arriba, cuando seleccionamos una imagen del dispositivo
      //o tomamos una Foto con el dispositivo al querer enviarlas al backend tenemos que tratar el path
      //de las imagenes ya que si son imagenes del dispositvo o tomadas con la camara si no la trataramos
      //enviaremos le url de donde se ubican en el dispoitivo
      productLike['images'] = await _uploadPhotos( productLike['images']);
      
      

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