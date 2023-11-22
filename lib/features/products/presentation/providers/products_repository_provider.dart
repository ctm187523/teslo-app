
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/features/auth/presentation/providers/auth_provider.dart';
import 'package:teslo_shop/features/products/domain/repositories/products_repository.dart';
import 'package:teslo_shop/features/products/infrastructure/datasources/products_datasource_impl.dart';
import '../../infrastructure/repositories/products_repository_impl.dart';

//tipo de informacion <ProductRepository>
final  productsRepositoryProvider = Provider<ProductsRepository>((ref) {

  //para acceder al token que pide por parametro ProductsDatasourceImp,implementado abajo
  //debemos usar otro provider de Riverpod, podemos usar el parametro ref recibido arriba para acceder
  //a qualquier provider de la aplicacion, usamos authProvider usamos watch para actualizar qualquier cambio
  //en el state en caso de que no venga mandamos un String vacio
  final accessToken = ref.watch( authProvider).user?.token ?? '';
  
  final productsRepository = ProductsRepositoryImpl(
    ProductsDatasourceImpl(accesToken: accessToken) //usamos la varaible accesToken creada arriba
   );

  return productsRepository;
});