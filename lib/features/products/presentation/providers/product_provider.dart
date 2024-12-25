

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'products_repository_provider.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';

//ESTADO, Provider para un producto, individual
class ProductState {

  //propiedades
  final String id;
  final Product? product;
  final bool isLoading;
  final bool isSaving;

  //constructor
  ProductState({
    required this.id, 
    this.product, 
    this.isLoading = true, 
    this.isSaving = false
  });

  ProductState copyWidth({
    String? id,
    Product? product,
    bool? isLoading,
    bool? isSaving,
  }) => ProductState(
    id: id ?? this.id,
    product: product ?? this.product,
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
  );

}

 //NOTIFIER, como parámetro tenemos un objeto de la clase creada arriba ProductState
  class ProductNotifier extends StateNotifier<ProductState> {

    //propiedades
    //lo usamos mas abajo para obtener el producto por id, pretenece al domain no al infrastructure para hacerlo generico
    //cuando es llamada esta clase ProductNotifier abajo del codigo en el productProvider se pasa del infrastructure ProductsRepositoryImpl
    final ProductsRepository productsRepository;  
    
    //constructor, en el super del constructor ponemos el id obligatorio en el state ver arriba
    //ademas de las otras propiedades
    ProductNotifier({
      required this.productsRepository,
      required String productId,
    }):super(ProductState(id: productId)){
      loadProduct(); //llamamos en el constructor a la funcion de abajo 
    }

    //metodo para crear un nuevo producto
    Product newEmptyProduct(){

      return Product(
        id: 'new',
        title: '',
        price: 0,
        description: '',
        slug: '',
        stock: 0,
        sizes: [], 
        gender: 'men',
        tags: [], 
        images: [],
      );
    }
    //funcion para cargar un producto mediante el id del producto
    Future<void> loadProduct() async {

        try {

          //si el state.id es 'new' quiere decir que queremos crear un nuevo producto
          //llamamos a la funcion de arriba para crear un Producto vacio y isLoading lo ponemos en false
          //obtenemos el state del producto ya que ProductNotifier extends StateNotifier<ProductState>, ProductState es el argumento, objeto de la clase creada arriba
          if ( state.id == 'new'){
            
            state = state.copyWidth(
              isLoading: false,
              product: newEmptyProduct(),
            );
            return;    
          }
          //si el state.id no es 'new' obtenemos el producto por id
          final product = await productsRepository.getProductById(state.id);

          //modificamos el state del ProductState cada vez que cerremos la pantalla
          //del producto como tenemos el autodispose perderemos la informacion, es lo que queremos
          //y tendremos las propiedades con sus valores por defecto
          state = state.copyWidth(
            isLoading: false,
            product: product
          );
        } catch (e) {
          // 404 product not found
          print(e);
        }
    }
  }

  //PROVIDER StateNotifierProvider, usamos el StateNotifier llamado ProductNotifier creado arriba y la clase ProductState creada arriba
  //usamos autodispose para limpiar cada vez que se va a utilizar y el family
  //para esperar un valor a la hora de utilizar este provider, necesitamos el id(ver la clase Productstate de este archivo)
  //recibimos los dos argumentos de siempre el Notifier(ProductNotifier creado arriba y el state ProductState clase creada arriba)
  //ademas recibimos un String que sera el id para el ProductState
  final productProvider = StateNotifierProvider.autoDispose.family<ProductNotifier,ProductState,String>(
    (ref, productId) {

        //propiedad, usamos el ref para usar el estado del productsRepositoryProvider de este mismo directorio
        final productsRepository = ref.watch(productsRepositoryProvider);

        //retornamos llamando al StateNotifier llamado ProductNotifier creado arriba y pasandole los parametros que solicita
        //el productsRepository donde tenemos el repositorio creado en products_repository_provider de este directorio
        //y el productId en que puede ser new para crear nuevos productos o un id para su busqueda
        return ProductNotifier(
          productsRepository: productsRepository,
          productId: productId
        );
  });