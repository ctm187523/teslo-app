import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teslo_shop/features/auth/presentation/providers/auth_provider.dart';
import 'app_router_notifier.dart';
import 'package:teslo_shop/features/auth/auth.dart';
import 'package:teslo_shop/features/products/products.dart';

//envolvemos el goRouter en un Provider, para la comprobacion de si el usuario esta autenticado
//usamos abajo del codigo la propiedad redirect para la autenticacion
final goRouterProvider = Provider((ref) {

  //usamos el provider creado en la clase app_router_notifier, para usarla
  //en la propiedad de abajo refreshListenable
  final goRouterNotifier = ref.read(goRouterNotifierProvider);

  //devolvemos el objeto GoRouter
  return GoRouter(
    initialLocation: '/splash',
    //la propiedad refreshListenable evalua si el estado cambia(checking, authenticated, etc) y si este cambia
    //vuelve a evaluar la propiedad redirect usada abajo del codigo, pide un objeto de tipo ChangeNotifier(usado en videos anteriores)
    refreshListenable: goRouterNotifier,
    routes: [
      ///* Primera pantalla
      GoRoute(
        path: '/splash',
        builder: (context, state) => const CheckAuthStatusScree(),
      ),

      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      ///* Product Routes
      GoRoute(
        path: '/',
        builder: (context, state) => const ProductsScreen(),
      ),

      GoRoute(
        path: '/product/:id',
        builder: (context, state) => ProductScreen(
          productId: state.params['id'] ?? 'no-id', //recibimos el id por parametro de la ruta
        ),
      ),
    ],
    
    //usamos el redirect para comprovar si el usuario esta autenticado
    //usamos como parametro el context y el state donde tenemos el estado del router
    redirect: (context, state ){

      final isGointTo = state.subloc;  //rescatamos la ruta con subloc, del lugar donde se quiere dirigir el usuario
      final authStatus = goRouterNotifier.authStatus; //obtenemos el estado de la autenticacion usamos la instancia creada arriba linea 13

      //evaluamos si nos dirigimos al screen splash donde se encuentra el CircularProgressIndicator
      //si el estado es cheking no regresamos nada(lo dejamos pasar),mostramos solo el splash screen si el status es checking
      if ( isGointTo == '/splash' && authStatus == AuthStatus.checking) return null;

      //determinamos los lugares donde se puede dirigir el usuario sin estar autenticado
      if ( authStatus == AuthStatus.notAuthenticated ){
          if ( isGointTo == '/login' || isGointTo == '/register') return null;

          //si no son esas rutas y no esta autenticado lo regresamos al login
          return '/login';
      }

      if ( authStatus == AuthStatus.authenticated ){
        //si el usuario ya esta autenticado lo mandamos a la ruta de los productos
        if ( isGointTo == '/login' || isGointTo == '/register' || isGointTo == '/splash') {
          return '/';
        }
      }

      //de aqui para abajo todas las rutas que pongamos estaran autenticadas ya que si no lo fueran
      //ya hubieran salido con un return del metodo

      return null;
    }
  );
});
