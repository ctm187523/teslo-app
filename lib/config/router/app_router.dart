import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_router_notifier.dart';
import 'package:teslo_shop/features/auth/auth.dart';
import 'package:teslo_shop/features/products/products.dart';

//envolvemos el goRouter en un Provider, para la comprovacion de si el usuario esta autenticado
//usamos abajo del codigo la propiedad redirect para la autenticacion
final goRouterProvider = Provider((ref) {

  //usamos el provider creado en la clase app_router_notifier, para usarla
  //en la propiedad de abajo refreshListenable
  final goRouterNotifier = ref.read(goRouterNotifierProvider);

  //devolvemos el objeto GoRouter
  return GoRouter(
    initialLocation: '/login',
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
    ],
    
    //usamos el redirect para comprovar su el usuario esta autenticado
    //usamos como parametro el context y el state donde tenemos el estado del router
    redirect: (context, state ){

      print( state.subloc);
      //return '/login';
    }
  );
});
