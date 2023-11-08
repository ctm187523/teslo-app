


import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/features/auth/presentation/providers/providers.dart';

//creamos un provider de Riverpod, para obtener el estado(cheking, etc)
//y se lo mandamos a la clase creada abajo
final goRouterNotifierProvider = Provider((ref) {
  final authNotifier = ref.read( authProvider.notifier);
  return GoRouterNotifier(authNotifier);
});


//clase para usar el gestor de estado, usamos el ChangeNotifier, ver inicio del curso
//los primeros providers
class GoRouterNotifier extends ChangeNotifier {

  //usamosuna instancia de la clase AuthNotifier para manejar el estado(autenticado, no autenticado, etc)
  final AuthNotifier _authNotifier;

  //constructor
   GoRouterNotifier(this._authNotifier){
    //reaccionamos al cambio de estado del _authNotifier, cheking, autenticado, etc
    //usamos el set creado abajo para cambiar el estado
    _authNotifier.addListener((state) {
        authStatus = state.authStatus;
     });
   }

  AuthStatus _authStatus  = AuthStatus.checking; //cheking por defecto

 

  //obtenemos el estado
  AuthStatus get authStatus => _authStatus;

  //cuando cambiamos el estado notifica a los Listener, en este caso el Router
  set authStatus( AuthStatus value) {
    _authStatus = value;
    notifyListeners();
  }

}