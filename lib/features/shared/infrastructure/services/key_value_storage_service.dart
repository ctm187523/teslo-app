

//he instalado shared_preferences con --> flutter pub add shared_preferences
//de pub.dev --> https://pub.dev/packages/shared_preferences
//este paquete envuelve el almacenamiento persistente específico de la plataforma para datos simples 
//(NSUserDefaults en iOS y macOS, SharedPreferences en Android, etc.). Los datos pueden persistir en el disco de forma asíncrona,
// y no hay garantía de que las escrituras persistan en el disco después de regresar, por lo que este complemento no debe usarse para almacenar datos críticos.


//clase para regir las implementaciones, al ser abstracta, en este caso usaremos shared_preferences
//pero podriamos usar otras como isar,etc. para mantener datos en el disco duro
abstract class KeyValueStorageService {

  Future<void> setKeyValue<T>(String key, T value); //el parametro value hacemos que sea un generico T para recibir cualquier tipo de dato, no devuelve nada(void)
  Future<T?>  getValue<T>(String key); //devuelve un generico T, opcional
  Future<bool> removeValue(String key); //devuelve un booleano
}