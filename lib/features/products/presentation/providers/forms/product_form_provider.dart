import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:teslo_shop/features/products/domain/domain.dart';
import 'package:teslo_shop/features/products/presentation/providers/providers.dart';
import 'package:teslo_shop/features/shared/shared.dart';

import '../../../../../config/constants/environment.dart';


//STATE
class ProductFormState {
  final bool isFormValid;
  final String? id;
  final Title title;
  final Slug slug;
  final Price price;
  final List<String> sizes;
  final String gender;
  final Stock inStock;
  final String description;
  final String tags;
  final List<String> images;

  ProductFormState(
    {
      this.isFormValid = false,
      this.id,
      this.title = const Title.dirty(''),
      this.slug = const Slug.dirty(''),
      this.price = const Price.dirty(0),
      this.sizes = const [],
      this.gender = 'men',
      this.inStock = const Stock.dirty(0),
      this.description = '',
      this.tags = '',
      this.images = const []
    });

  ProductFormState coyWidth({
    bool? isFormValid,
    String? id,
    Title? title,
    Slug? slug,
    Price? price,
    List<String>? sizes,
    String? gender,
    Stock? inStock,
    String? description,
    String? tags,
    List<String>? images,
  }) =>
      ProductFormState(
        isFormValid: isFormValid ?? this.isFormValid,
        id: id ?? this.id,
        title: title ?? this.title,
        slug: slug ?? this.slug,
        price: price ?? this.price,
        sizes: sizes ?? this.sizes,
        gender: gender ?? this.gender,
        inStock: inStock ?? this.inStock,
        description: description ?? this.description,
        tags: tags ?? this.tags,
        images: images ?? this.images,
      );
}

//NOTIFIER
class ProductFormNotifier extends StateNotifier<ProductFormState> {

  //le hemos puesto productLike al nombre del Map que tiene como atributo la funcion, porque es como un producto
  //pero no exactamente un producto ya que es state ProductFormState tiene atributos propiedades diferentes al producto
  final Future<Product> Function( Map<String, dynamic> productLike)? onSubmitCallback; //funcion para validar el formulario y mandar al backend la infromacion

  //constructor
  ProductFormNotifier({
    this.onSubmitCallback,
    required Product product
  }):super(  //creamos el stado inicial del ProductFormState
    ProductFormState(
      id: product.id,
      title: Title.dirty(product.title),
      slug: Slug.dirty(product.slug),
      price: Price.dirty(product.price),
      inStock: Stock.dirty( product.stock ),
      sizes: product.sizes,
      gender: product.gender,
      description: product.description,
      tags: product.tags.join(', '), //unimos los tags por comas
      images: product.images,
    )
  );

  //metodo para hacer el submit
  Future<bool> onFormSubmit() async {
    _touchedEverything(); //llama al metodo de abajo para "ensuciar" los campos con validaciones

    if ( !state.isFormValid ) return false;

    if( onSubmitCallback == null ) return false; //si no recibe la funcion salimos

    //productLike es el objeto que tiene que lucir como pide el backend
    final productLike = {
      'id' : state.id,
      'title' : state.title.value,
      'price': state.price.value,
      'description' : state.description,
      'slug': state.slug.value,
      'stock' : state.inStock.value,
      'sizes' : state.sizes,
      'gender' : state.gender,
      'tags' : state.tags.split(','), //cortamos con split los tags separados por comas
      'images' : state.images.map(
        (image) => image.replaceAll('${ Environment.apiUrl }/files/product/', '')
        ).toList()
    };

    //mandamos el producto a la funcion recibida abajo en el productFormProvider
    //para que el producto se cree o se actualize dependiendo si tenemos un id  o no
    try {
      
      await onSubmitCallback!( productLike);
      return true;
    } catch (e) {
        return false;
    }
  }

  //al hacer submit tocamos cada uno de los campos con validaciones, forzamos que haya sido manipulado(ensuciamos)
  void _touchedEverything(){


    state = state.coyWidth(
      isFormValid: Formz.validate([
        Title.dirty(state.title.value),
        Slug.dirty(state.slug.value),
        Price.dirty(state.price.value),
        Stock.dirty(state.inStock.value),
      ]),
    );
  }


  //METODOS PARA CAMBIAR EL ESTADO CON VALIDACIONES
  void onTitleChanged ( String value) {
    
    state = state.coyWidth(
      title: Title.dirty(value),
      //validamos los inputs de lib/features/shared/infrastructure/inputs
      isFormValid: Formz.validate([
        Title.dirty(value),
        Slug.dirty(state.slug.value),
        Price.dirty(state.price.value),
        Stock.dirty(state.inStock.value),
      ])
    );
  }

  void onSlugChanged ( String value) {
    
    state = state.coyWidth(
      slug: Slug.dirty(value),
      //validamos los inputs de lib/features/shared/infrastructure/inputs
      isFormValid: Formz.validate([
        Title.dirty(state.title.value),
        Slug.dirty(value),
        Price.dirty(state.price.value),
        Stock.dirty(state.inStock.value),
      ])
    );
  }

  void onPriceChanged ( double value) {
    
    state = state.coyWidth(
      price: Price.dirty(value),
      //validamos los inputs de lib/features/shared/infrastructure/inputs
      isFormValid: Formz.validate([
        Title.dirty(state.title.value),
        Slug.dirty(state.slug.value),
        Price.dirty(value),
        Stock.dirty(state.inStock.value),
      ])
    );
  }

  void onStockChanged ( int value) {
    
    state = state.coyWidth(
      inStock: Stock.dirty(value),
      //validamos los inputs de lib/features/shared/infrastructure/inputs
      isFormValid: Formz.validate([
        Title.dirty(state.title.value),
        Slug.dirty(state.slug.value),
        Price.dirty(state.price.value),
        Stock.dirty(value),
      ])
    );
  }

  //METODOS PARA CAMBIAR EL ESTADO SIN VALIDACIONES
  void onSizeChanged( List<String> sizes){
    state = state.coyWidth(
      sizes: sizes
    );
  }

  void onGenderChanged( String gender){
    state = state.coyWidth(
      gender: gender
    );
  }

  void onDescriptionChanged( String description){
    state = state.coyWidth(
      description: description
    );
  }

  void onTagsChanged( String tags){
    state = state.coyWidth(
      tags: tags
    );
  }
}

//PROVIDER, es autoDispoe (al regresar a la anterior pantalla vuelve al estado por defecto, se limpia cuando no se necesita)
//y family(recibimos por parametro el producto)

final productFormProvider = StateNotifierProvider.autoDispose.family<ProductFormNotifier, ProductFormState, Product>(
  (ref, product){

    //usamos el provider productsRepositoryProvider para acceder al metdodo createUpdateProduct
    //que es el metodo que nos permite crear o actualizar productos dependiendo si recibe un id o no
    final createUpdateCallback = ref.watch( productsRepositoryProvider).createUpdateProduct;

    return ProductFormNotifier(
      product: product,
      onSubmitCallback: createUpdateCallback,
    );
  }
  
);