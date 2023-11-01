
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teslo_shop/features/shared/infrastructure/services/key_value_storage_service.dart';


//implementamos la clase abstracta creado en este mismo directorio,
//con sus 3 metodos
class KeyValueStorageServiceImpl extends KeyValueStorageService {
  
  //creamos un metodo para usar las SharedPreferences, para manejar el guardar y obtener
  //los datos guardados en el disco duro, ver en la clase KeyValueStorageService
  //el proceso de instalacion y uso en los comentarios al inicio de la clase
  Future<SharedPreferences> getSharedPrefes() async {
    return await SharedPreferences.getInstance();
  }

  //Sobreescribimos los 3 metodos de la clase KeyValueStorageService
  @override
  Future<T?> getValue<T>(String key) async{
    
     //usamos el metodo creado arriba para crear una instancia de SharedPreferences
    final prefs = await  getSharedPrefes();

    //discriminamos el tipo de valor generico T que retornamos con un switch

    switch (T) {
      case int:
        return prefs.getInt(key) as T?;
       
      case String:
        return prefs.getString(key) as T?;
        
      default:
        throw UnimplementedError('Get not implemented for type ${T.runtimeType} ');
    }
  }

  //clase para borrar los valores almacenados
  @override
  Future<bool> removeValue(String key) async{
    
    //usamos el metodo creado arriba para crear una instancia de SharedPreferences
    final prefs = await  getSharedPrefes();
    return await prefs.remove(key);
  }

  //establecemos un valor en el disco duro
  @override
  Future<void> setKeyValue<T>(String key, T value) async{
    
    //usamos el metodo creado arriba para crear una instancia de SharedPreferences
    final prefs = await  getSharedPrefes();

    //discriminamos el tipo de valor generico T que recibimos por parametro con un switch

    switch (T) {
      case int:
        prefs.setInt(key, value as int);
        break;
       
      case String:
        prefs.setString(key, value as String);
        break;

      default:
        throw UnimplementedError('Set not implemented for type ${T.runtimeType} ');
    }
  }

}