

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'products_repository_provider.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';

//ESTADO
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

 //NOTIFIER
  class ProductNotifier extends StateNotifier<ProductState> {

    //propiedades
    final ProductsRepository productsRepository;
    
    //constructor, en el super del constructor ponemos el id obligatorio en el state ver arriba
    //ademas de las otras propiedades
    ProductNotifier({
      required this.productsRepository,
      required String productId,
    }):super(ProductState(id: productId)){
      loadProduct(); //llamamos en el constructor a la funcion de abajo 
    }

    //funcion para cargar un producto mediante el id del producto
    Future<void> loadProduct() async {

        try {
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

  //PROVIDER
  //usamos autodispose para limpiar cada vez que se va a utilizar y el family
  //para esperar un valor a la hora de utilizar este provider, necesitamos el id(ver la clase Productstate de este archivo)
  //recibimos los dos argumentos de siempre el Notifier(ProductNotifier en este caso y el state ProductState)
  //ademas recibimos un String que sera el id para el ProductState
  final productProvider = StateNotifierProvider.autoDispose.family<ProductNotifier,ProductState,String>(
    (ref, productId) {

        //propiedad, usamos el ref para usar el estado del productsRepositoryProvider de este mismo directorio
        final productsRepository = ref.watch(productsRepositoryProvider);

        return ProductNotifier(
          productsRepository: productsRepository,
          productId: productId
        );
  });