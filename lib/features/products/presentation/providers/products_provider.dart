

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/features/products/domain/domain.dart';
import 'products_repository_provider.dart';

// STATE Notifier PROVIDER, Provider para lista de productos
class ProductsState {

  final bool isLastPage;
  final int limit;
  final int offset;
  final bool isLoading;
  final List<Product> products; //listado de productos que mostraremos por pantalla

  //constructor
  ProductsState({
    this.isLastPage = false, 
    this.limit = 10, 
    this.offset = 0, 
    this.isLoading = false, 
    this.products = const[]
  });

  ProductsState copyWith({
    bool? isLastPage,
    int? limit,
    int? offset,
    bool? isLoading,
    List<Product>? products,
  }) => ProductsState(
    isLastPage: isLastPage ?? this.isLastPage,
    limit: limit ?? this.limit,
    offset: offset ?? this.offset,
    isLoading: isLoading ?? this.isLoading,
    products: products ?? this.products,
  );
}


//NOTIFIER, esta clase es llamada abajo del codigo en productsProvider
class ProductsNotifier extends StateNotifier<ProductsState>{

  //propiedad para obtener los productos
  //lo usamos mas abajo para obtener el producto por id, pretenece al domain no al infrastructure para hacerlo generico
  //cuando es llamada esta clase ProductNotifier abajo del codigo en el productProvider se pasa del infrastructure ProductsRepositoryImpl
  final ProductsRepository productsRepository;
  
  //constructor, tan pronto se utilize el ProductsNotifier en cualquier lugar
  //llamamos a la funcion loadNextPage() creada abajo
  ProductsNotifier({
     required this.productsRepository
  }): super( ProductsState() ){
    loadNextPage();
  }

  //metodo para que si se actualiza o se crea un producto al volver a la pantalla
  //de Products quede actualizada, retorna un booleano en el caso de que lo haga o no
  //esta funcion es llamada en product_form_provider.dart
  Future<bool> createOrUpdateProduct( Map<String, dynamic> productLike ) async {

    try {
      
      //llamamos al metodo createUpdateProduct de la  instancia productsRepository 
      //obtenida en el constructor para crear o actualizar producto
      final product = await productsRepository.createUpdateProduct(productLike);

      //vemos si el producto que estoy editando esta en la pantalla Products, si pulsamos NuevoProducto lo creariamos
      //si pulsamos sobre uno de los productos de la pantalla Products lo editamos
      //verificamos si el product obtenido arriba esta en la lista de productos que ya tenemos, ver arriba propiedades del ProducState
      final isProducInList = state.products.any((element) => element.id == product.id);

      //si no exite lo añadimos a la lista de productos,usando el spread ...
      if ( !isProducInList) {
        state = state.copyWith(
          products: [...state.products, product]
        );
        return true; //retornamos que ha tenido exito la creación del  producto
      }

      //si existe lo actualizamos, recorremos los elementos y el que coincida con el id del product obtenido
      //lo actualizamos usando el product obtenido actualizado, si no coincide el id regresamos el mismo elemento que ya tenemos
      state = state.copyWith(
        products: state.products.map(
          (element) => (element.id == product.id) ? product : element
        ).toList()
      );
      return true;  //retornamos que ha tenido exito la modificacion del  producto

    } catch (e) {
      return false; //retornamos que no ha tenido exito la modificacion/creación del  producto
    }
  }

  //metodo para cargar nuevas paginas de productos
  Future loadNextPage() async {

    //si se cumplen las dos condiciones salimos del metodo
    if ( state.isLoading || state.isLastPage ) return;

    //ponemos el isLoading en true
    state = state.copyWith( isLoading: true);

    final products = await productsRepository
      .getProductByPage( limit:  state.limit, offset: state.offset);

    //si esta vacio cambiamos del estado el isLoading en false y isLastPage true
    if (products.isEmpty) {
      state = state.copyWith( 
        isLoading: false,
        isLastPage: true
      );
      return;
    }

    //si tenemos productos
    state = state.copyWith(
      isLastPage: false,
      isLoading: false,
      offset: state.offset + 10, //necesito los siguientes 10 
      products: [...state.products, ...products] //hacemos el spread de los productos del estado y añadimos los nuevos productos recibidos de la peticion
    );
  }

 
}


 //PROVIDER, valor mutable complejo
 final productsProvider = StateNotifierProvider<ProductsNotifier, ProductsState>((ref) {

  //usamos una instancia del Provider productsRepositoryProvider creado en este directorio
  final productsRepository = ref.watch( productsRepositoryProvider);
  
  //retornamos el ProductsNotifier creado aqui
  return ProductsNotifier(productsRepository: productsRepository);
 });
  