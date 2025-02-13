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
  final Future<bool> Function( Map<String, dynamic> productLike)? onSubmitCallback; //funcion para validar el formulario y mandar al backend la información

  /*
     La razón principal para marcar un objeto como "sucio"(dirty) en Flutter es desencadenar una reconstrucción del widget.
      Cuando un widget se marca como sucio, Flutter se da cuenta de que su representación en pantalla necesita ser 
      actualizada para reflejar los nuevos cambios. Esto garantiza que la interfaz de usuario siempre esté sincronizada 
      con el estado de la aplicación.
   */

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
      'id' : (state.id == 'new' ) ? null : state.id, //si recibimos en el id new quiere decir que queremos crear un nuevo producto entonce ponemos el id como null
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

    //mandamos el producto a la funcion recibida por parámetro
    //para que el producto se cree o se actualize dependiendo si tenemos un id  o no
    try {
      
      return await onSubmitCallback!( productLike);

    } catch (e) {
        return false;
    }
  }

  /*
    -----------------------    FORMZ   ---------------------------------
    Formz es un paquete de Dart diseñado específicamente para simplificar la gestión y validación de formularios en aplicaciones Flutter.
    Proporciona una forma estructurada y eficiente de representar y manejar el estado de los campos de un formulario, 
    así como de implementar reglas de validación personalizadas.

    ¿Por qué usar Formz?
    Simplificación: Formz abstrae la complejidad de gestionar el estado de los campos de un formulario, las reglas de validación y la visualización de errores.
    Validación declarativa: Permite definir reglas de validación de forma concisa y legible, utilizando una sintaxis similar a las expresiones regulares.
    Estado de los campos: Cada campo tiene su propio estado (válido, inválido, puro, sucio), lo que facilita el manejo de errores y la actualización de la interfaz de usuario.
    Extensibilidad: Es altamente personalizable y permite crear validadores personalizados para adaptarse a diferentes tipos de campos y requisitos.
    validamos los inputs de lib/features/shared/infrastructure/inputs
   */

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

  //método para añadir nuevas imagenes al listado de imagenes(List<String> images)
  //imagenes tomadas de la galeria o de tomar una foto con la camara del dispositivo
  void updateProductImage(String path){
    state = state.coyWidth(
      images: [...state.images, path] //colocamos la imagen al final para ponerla al principio seria path, ...state.images
    );
  }

  //METODOS PARA CAMBIAR EL ESTADO CON VALIDACIONES
  void onTitleChanged ( String value) {
    
    state = state.coyWidth(
      title: Title.dirty(value),
      //validamos los inputs de lib/features/shared/infrastructure/inputs, ver arriba en los comentarios de Formz
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
      //validamos los inputs de lib/features/shared/infrastructure/inputs, ver arriba en los comentarios de Formz
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
      //validamos los inputs de lib/features/shared/infrastructure/inputs, ver arriba en los comentarios de Formz
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
      //validamos los inputs de lib/features/shared/infrastructure/inputs, ver arriba en los comentarios de Formz
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

    //usamos el provider productsProvider para acceder al metdodo createOrUpdateProduct
    final createUpdateCallback = ref.watch( productsProvider.notifier).createOrUpdateProduct;

    return ProductFormNotifier(
      product: product,
      onSubmitCallback: createUpdateCallback,
    );
  }
);