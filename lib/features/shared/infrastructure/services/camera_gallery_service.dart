
//creamos una clase abstracta para manejar las imagenes, creamos
//esta clase para en un futuro si queremos manejar las imagenes
//con otro paquete lo tengamos centralizado
//para manejar las imagenes usamos el paquete image_picker instalado con --> flutter pub add image_picker
//lo hemos instalado de --> https://pub.dev/packages/image_picker/install
//ver en Readme del enlace anterior las configuraciones
//para ios hay que ir al archivo /ios/Runner/Info.plist de la aplicacion(ver codigo de la linea 6 a 13) para gestionar los permisos en ios
//en Android no hace falta hacer nada 
abstract class CameraGalleryService {

  //el String contiene el path fisico de la fotografia que acabo de tomar
  Future<String?> takePhoto();
  //seleccionar una fotografia
  Future<String?> selectPhoto();

}