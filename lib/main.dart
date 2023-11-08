import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/config/config.dart';

//main
void main() async{

  //ponemos el codigo necesario para manejar las variables de entorno, lo tenemos que hacer asincrono
  await Environment.initEmvironment();
  runApp(
    //ponemos el Provider Riverpood en el lugar mas alto de la aplicacion para que todos puedan usarlo
    const ProviderScope(child: MainApp())
  ); 
}

//usamos un ConsumerWidget ya que para usar goRouter lo estamos usando a traves
//de un provider VER CLASE app_router
class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    //Usamos el provider creado en la clase app_router en lib/config/router
    //en un build usamos un watch
    final appRouter = ref.watch( goRouterProvider);

    return MaterialApp.router(
      routerConfig: appRouter, //usamos la instancia al provider creado para usar el goRouter
      theme: AppTheme().getTheme(),
      debugShowCheckedModeBanner: false,
    );
  }
}
