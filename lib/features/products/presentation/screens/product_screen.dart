

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/features/products/presentation/providers/product_provider.dart';
import 'package:teslo_shop/features/shared/shared.dart';

import '../../domain/entities/product.dart';
import '../providers/forms/product_form_provider.dart';


class ProductScreen extends ConsumerWidget {

  //propiedades
  final String productId;

  //constructor
  const ProductScreen({super.key, required this.productId});

  //metodo para mostrar un snackbar con un mensaje al pulsar el boton(FloatingActionButton) de modificar/crear un producto
  void showSnackbar( BuildContext context){
    
    ScaffoldMessenger.of(context).clearSnackBars(); //usamos clearSnackBars por si volvemos a pulsar el boton que muestre la nueva y oculte la vieja

    //mostramos el Sanckbar 
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto actualizado'))
     );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final productState = ref.watch( productProvider(productId));
    
    //usamos el Widget GestureDetector y con su metodo onTap hacemos que cuando
    //el teclado aparezca y luego si perdemos el foco del teclado(hacemos click a fuera) desaparezca el teclado
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Editar Producto'),
          actions: [

            //boton icono para seleccionar una imagen del dispositivo usamos la clase creada
            //CameraGalleryServiceImp()
            IconButton(onPressed: () async{
              final photoPath = await CameraGalleryServiceImp().selectPhoto();
              if ( photoPath == null) return;

              //usamos el provider productFormProvider para añadir la imagen al array del imagenes del state
              ref.read(productFormProvider(productState.product!).notifier)
                .updateProductImage(photoPath);
    
            },
             icon: const Icon( Icons.photo_library_outlined)),

            //boton icono para hacer una foto con el dispositivo usamos la clase creada
            //CameraGalleryServiceImp()
            IconButton(onPressed: () async{
              final photoPath = await CameraGalleryServiceImp().takePhoto();
              if ( photoPath == null) return;
              
              //usamos el provider productFormProvider para añadir la imagen al array del imagenes del state
              ref.read(productFormProvider(productState.product!).notifier)
                .updateProductImage(photoPath);
   
            },
             icon: const Icon( Icons.camera_alt_outlined))
          ],    
        ),  
    
        //si ProductState es isLoading mostramos el loader en caso contrario mostramos el producto
        body: productState.isLoading
          ? const FullScreenLoader() //usamos FullScreenLoader creado en widgets
          : _ProductView(product: productState.product!,),
        
        floatingActionButton: FloatingActionButton(
          onPressed: () {
    
             if( productState.product == null) return; //si al validar no tenemos un producto salimos
             
             //llamamos al provider formProvider para que llame a la funcion onFormSubmit
             //como onFormSubmit regresa un Future de tipo booleano con .then recogemos el value(el valor booleano)
             //que usamos para hacer la condicion de mostrar o no el SnackBar diciendo producto actualizado
             //para usar el SnackBar llamamos a la funcion creada arriba showSnackBar
             ref.read(
                productFormProvider(productState.product!).notifier
              ).onFormSubmit()
               .then((value) { //si el balor boolean es false salimos en caso contrario mostramos el snackBar gracias a la funcion creada arriba showSnackBar
                if (!value) return ;
                showSnackbar(context);
              });
          },
          child: const Icon( Icons.save_as_outlined ),
        ),
      ),
    );
  }
}

//codigo copiado del gist de la seccion 29 -> Diseño de pantalla
class _ProductView extends ConsumerWidget {

  final Product product;

  //constructor
  const _ProductView({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    //creamos una instancia del provider productFormProvider para poder modificar
    //los datos de los productos, le mandamos por parametro el producto
    final productForm = ref.watch( productFormProvider(product));

    final textStyles = Theme.of(context).textTheme;

    return ListView(
      children: [
    
          SizedBox(
            height: 250,
            width: 600,
            child: _ImageGallery(images: productForm.images ), //usamos la instancia creada arriab de productFormProvider para poder actualizar los productos si le hacemos cambios
          ),
    
          const SizedBox( height: 10 ),
          //usamos la instancia del provider productFormProvider para acceder al valor ponemos productForm.title.value porque es una instancia al input
          Center(
            child: Text( productForm.title.value, 
            style: textStyles.titleSmall ,
            textAlign: TextAlign.center,
            )
          ),
          const SizedBox( height: 10 ),
          _ProductInformation( product: product ),
          
        ],
    );
  }
}


class _ProductInformation extends ConsumerWidget {
  final Product product;
  const _ProductInformation({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref ) {

    //creamos una instancia del provider productFormProvider para poder modificar
    //los datos de los productos, le mandamos por parametro el producto
    final productForm = ref.watch( productFormProvider(product));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Generales'),
          const SizedBox(height: 15 ),
          CustomProductField( //Widget creado en este mismo directorio
            isTopField: true, //en true muestra bordes redondeados
            label: 'Nombre',
            initialValue: productForm.title.value, //nos establece el valor inicial
            onChanged: ref.read( productFormProvider(product).notifier).onTitleChanged, //usamos read y no watch porque hace solo referencia a la funcion
            //el onChange de arriba se podria tambien hacer de la siguiente manera, pero como mandamos la misma referencia no es necesario,lo comentamos para no hacer dos veces lo mismo
            //onChanged: (value) =>ref.read( productFormProvider(product).notifier).onTitleChanged(value),
            errorMessage: productForm.title.errorMessage,
          ),
          CustomProductField( 
            label: 'Slug',
            initialValue: productForm.slug.value,
            onChanged: ref.read( productFormProvider(product).notifier).onSlugChanged, //usamos read y no watch porque hace solo referencia a la funcion
            errorMessage: productForm.slug.errorMessage,
          ),
          CustomProductField( 
            isBottomField: true,
            label: 'Precio',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            initialValue: productForm.price.value.toString(),
            onChanged: (value) 
              => ref.read( productFormProvider(product).notifier)
              .onPriceChanged( double.tryParse(value) ?? -1), //tratamos de convertir a double que es lo que pide la funcion onPriceCahnged si no mandamos -1 para que al ser un numero negativo muestre el error
            errorMessage: productForm.price.errorMessage,
          ),

          const SizedBox(height: 15 ),
          const Text('Extras'),

          //usamos la clase _SizeSelector creada abajo
          _SizeSelector(
            selectedSizes: productForm.sizes,
            onSizesChanged:ref.read( productFormProvider(product).notifier).onSizeChanged,
          ),
          
          const SizedBox(height: 5 ),
          //usamos la clase _GenderSelector creada abajo
          _GenderSelector( 
            selectedGender: productForm.gender,
            onGenderChanged: ref.read( productFormProvider(product).notifier).onGenderChanged,
          ),
          

          const SizedBox(height: 15 ),
          CustomProductField( 
            isTopField: true,
            label: 'Existencias',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            initialValue: productForm.inStock.value.toString(),
            onChanged: (value) => 
            ref.read( productFormProvider(product).notifier)
            .onStockChanged( int.tryParse(value) ?? -1), //la funcion onStochChanged pide un int, tratamos de pasarlo de string a int en caso contrario mandamos -1 para que muestre el error 
            errorMessage: productForm.inStock.errorMessage,
          ),

          CustomProductField( 
            maxLines: 6,
            label: 'Descripción',
            keyboardType: TextInputType.multiline,
            initialValue: product.description,
            //mandamos los cambios producidos en el provider
            onChanged: ref.read( productFormProvider(product).notifier).onDescriptionChanged,
          ),

          CustomProductField( 
            isBottomField: true,
            maxLines: 2,
            label: 'Tags (Separados por coma)',
            keyboardType: TextInputType.multiline,
            initialValue: product.tags.join(', '),
            //mandamos los cambios producidos en el provider
            onChanged: ref.read( productFormProvider(product).notifier).onTagsChanged,
          ),


          const SizedBox(height: 100 ),
        ],
      ),
    );
  }
}


class _SizeSelector extends StatelessWidget {
  final List<String> selectedSizes;
  final List<String> sizes = const['XS','S','M','L','XL','XXL','XXXL'];

  //funcion que recebimos en el constructor cuando las talles cambien
  //y se vean reflejadas en los botones al seleccionar una talla se queda marcada
  //cojemos la informacion del FormProvider
  final void Function(List<String> selectedSizes) onSizesChanged;
  
  
  //constructor
  const _SizeSelector({
    required this.selectedSizes,
    required this.onSizesChanged,
  });


  @override
  Widget build(BuildContext context) {
    return SegmentedButton( //SegemntedButton lo vimos en la aplicacion de Widgets
      emptySelectionAllowed: true, //lo ponemos porque puede que no haya ninguna talla
      showSelectedIcon: false,
      segments: sizes.map((size) {
        return ButtonSegment(
          value: size, 
          label: Text(size, style: const TextStyle(fontSize: 10))
        );
      }).toList(), 
      selected: Set.from( selectedSizes ),
      onSelectionChanged: (newSelection) {
        FocusScope.of(context).unfocus(); //al tomar del Foco ocultamos el teclado
        //usamos List.from porque newSlection no es un listado de Stirngs es un set por tanto lo convertimos a un listado de String
        //Un set es una colección no ordenada de elementos únicos.(ver guia de atajos Dart)
        onSizesChanged( List.from(newSelection)); //usamos la funcion recibida en el constructor
      },
      multiSelectionEnabled: true,
    );
  }
}

class _GenderSelector extends StatelessWidget {
  final String selectedGender;
  final List<String> genders = const['men','women','kid'];
  final List<IconData> genderIcons = const[
    Icons.man,
    Icons.woman,
    Icons.boy,
  ];

  //funcion para que al cambiar el genero se quede reflejado resaltando el boton, le pasmos la informacion del FormProvider
  final void Function(String selectedGender) onGenderChanged;

  //Constructor
  const _GenderSelector({
    required this.selectedGender,
    required this.onGenderChanged
  });


  @override
  Widget build(BuildContext context) {
    return Center(
      child: SegmentedButton(
        multiSelectionEnabled: false,
        showSelectedIcon: false,
        style: const ButtonStyle(visualDensity: VisualDensity.compact ),
        segments: genders.map((size) {
          return ButtonSegment(
            icon: Icon( genderIcons[ genders.indexOf(size) ] ),
            value: size, 
            label: Text(size, style: const TextStyle(fontSize: 12))
          );
        }).toList(), 
        selected: { selectedGender },
        onSelectionChanged: (newSelection) {
          FocusScope.of(context).unfocus(); //al salir tomar el Foco ocultamos el teclado
          onGenderChanged(newSelection.first);
        },
      ),
    );
  }
}


class _ImageGallery extends StatelessWidget {
  final List<String> images;
  const _ImageGallery({required this.images});

  @override
  Widget build(BuildContext context) {

    if ( images.isEmpty ){
      return ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        child: Image.asset('assets/images/no-image.jpg', fit: BoxFit.cover )
        ); 
    }

    
    return PageView(
      scrollDirection: Axis.horizontal,
      controller: PageController(
        viewportFraction: 0.7
      ),
      children: images.map((image){

        //discriminamos las imagenes que tenemos en la base de datos y las que tenemos
        //en el dispositivo y aun no estan en la base de datos obtenidas de la galeria de
        //archivos del dispositivo o de haber tomado una foto con el dispositivo, son fotos temporales hasta que no se suban a la base de datos
        //usamos la calse ImageProvider de Flutter
        late ImageProvider imageProvider;
        //si viene de la base de datos, de la nube
        if( image.startsWith('http')){
          imageProvider= NetworkImage(image);
        //si viene del dispositivo usamos la clase FileImage y File de Flutter  
        }else{
          imageProvider = FileImage( File(image));
        }
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            child: FadeInImage(
              fit: BoxFit.cover,
              image: imageProvider,
              placeholder: const AssetImage('assets/loaders/bottle-loader.gif'),
            )
          ),
        );
      }).toList(),
    );
  }
}