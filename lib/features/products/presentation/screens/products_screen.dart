import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:teslo_shop/features/products/presentation/providers/products_provider.dart';
import 'package:teslo_shop/features/products/presentation/widgets/widgets.dart';
import 'package:teslo_shop/features/shared/shared.dart';


//he instalado un layout de tipo Masonry que es como un gridView pero desordenado
//lo he instalado con --> flutter pub add flutter_staggered_grid_view
//de la web --> https://pub.dev/packages/flutter_staggered_grid_view


class ProductsScreen extends StatelessWidget {

  //constructor
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      drawer: SideMenu( scaffoldKey: scaffoldKey ),
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            onPressed: (){}, 
            icon: const Icon( Icons.search_rounded)
          )
        ],
      ),
      body: const _ProductsView(),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Nuevo producto'),
        icon: const Icon( Icons.add ),
        onPressed: () {
          //usamos app_router al pulsar el boton, donde en lugar de mandar un id
          //mandamos new para crear un nuevo producto
          context.push('/product/new');
        },
      ),
    );
  }
}


//lo hacemos que herede de StatefulWidget para manejar
//el infinite scroll, lo ponemos finalmente ConsumerStatefulWidget
//para usar los providers
class _ProductsView extends ConsumerStatefulWidget {

  //constructor
  const _ProductsView();

  @override
  _ProductsViewState createState() => _ProductsViewState();
}

class _ProductsViewState extends ConsumerState{

  //usamos ScrollController para manejar el infinite scroll
  final ScrollController scrollController = ScrollController();

  //metodo al heredar de StatefulWidget
  @override
  void initState() {
    super.initState();

    //creamos un listener al objeto ScrollControler creado arriba
    scrollController.addListener(() {

      //si no hay mas paginas que cargar salimos, ver propiedades del ProductsState del archivo products_provider
      //LO COMENTAMOS PORQUE YA LO VALIDAMOS EN el archivo products_provider
      //if( ref.read(productsProvider).isLastPage == true ) return;

      //si isLastPage es false cargamos la siguiente pagina, ponemos la condicion de que si
      //la posicion del scroll + 400 pixeles es mayor o igual posicion del maximo scroll carguemos la siguiente pagina
      if( (scrollController.position.pixels +400) >= scrollController.position.maxScrollExtent){
        ref.read(productsProvider.notifier).loadNextPage();
      }
    });
    
  }

  //metodo al heredar de StatefulWidget
  @override
  void dispose() {
    
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    //usamos el provider, ponemos con watch a la escucha el productsProvider
    //cualquier cambio sera notificado
    final productState = ref.watch(productsProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: MasonryGridView.count( //usamos el widget MasonryGridView instalado ver arriba
        controller: scrollController,  //ponemos el objeto scrollController creado arriba y en el metodo de arriba initState le hemos puesto un listner para realizar el infiniteScroll
        physics: const BouncingScrollPhysics(),
        crossAxisCount: 2,          //queremos dos columnas
        mainAxisSpacing: 20,
        crossAxisSpacing: 35,
        itemCount: productState.products.length,    //usamos el length de los products del provider     
        
        itemBuilder: (context, index) {
           
            //la variable product apunta a la posicion de memoria de cada uno de los productos
            //los objetos en Dart pasan por referencia, no es un nuevo espacio en memoria de cada uno de los articulos
            //simplemente crea el espacio en memoria que apunta a ese objeto
            final product = productState.products[index];
            //usamos el widget GestureDetector para que al ser pulsada la tarjeta nos dirija a la informacion de una 
            //tarjeta en concreto, usamos la propiedad onTap para que a traves de GoRouter nos redirija pasando el id como argumento
            return GestureDetector(
              onTap: () => context.push('/product/${ product.id }'),
              child: ProductCard(product: product));
         },
      ),
    );
  }
}