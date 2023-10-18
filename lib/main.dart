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

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp.router(
      routerConfig: appRouter,
      theme: AppTheme().getTheme(),
      debugShowCheckedModeBanner: false,
    );
  }
}
