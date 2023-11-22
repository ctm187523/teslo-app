

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/features/products/domain/domain.dart';
import 'products_repository_provider.dart';

// STATE Notifier PROVIDER
class ProductsState {

  final bool isLastPage;
  final int limit;
  final int offset;
  final bool isLoading;
  final List<Product> products; //productos  que mostraremos por pantalla

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


//NOTIFIER
class ProductsNotifier extends StateNotifier<ProductsState>{

  final ProductsRepository productsRepository;
  
  //constructor, tan pronto se utilize el ProductsNotifier en cualquier lugar
  //llamamos a la funcion loadNextPage() creada abajo
  ProductsNotifier({
     required this.productsRepository
  }): super( ProductsState() ){
    loadNextPage();
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


 //PROVIDER
 final productsProvider = StateNotifierProvider<ProductsNotifier, ProductsState>((ref) {

  //usamos una instancia del Provider productsRepositoryProvider creado en este directorio
  final productsRepository = ref.watch( productsRepositoryProvider);
  
  //retornamos el ProductsNotifier creado aqui
  return ProductsNotifier(productsRepository: productsRepository);
 });
  