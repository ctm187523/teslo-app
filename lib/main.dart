import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/config/config.dart';
import 'package:teslo_shop/config/router/app_router.dart';

//main
void main() {
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
