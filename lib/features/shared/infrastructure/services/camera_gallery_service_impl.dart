//para manejar las imagenes usamos el paquete image_picker instalado con --> flutter pub add image_picker
//lo hemos instalado de --> https://pub.dev/packages/image_picker/install
//ver en Readme del enlace anterior las configuraciones
//para ios hay que ir al archivo /ios/Runner/Info.plist de la aplicacion(ver codigo de la linea 6 a 13) para gestionar los permisos en ios
//en Android no hace falta hacer nada 
import 'package:image_picker/image_picker.dart';
import 'camera_gallery_service.dart';

//clase que hereda de la clase abstracta creada en este directorio CameraGalleryService
//para manejar la camara
class CameraGalleryServiceImp extends CameraGalleryService {
  

  //creamos un bojeto clase del paquete image picker importado arriba para manejar las imagenes, lo hacemos privado _
  final ImagePicker _picker = ImagePicker();

  //metodos heredados de la clase abstracta sin implementar

  //obtenemos una imagen del dispositivo
  @override
  Future<String?> selectPhoto() async{
    
    final XFile? photo = await _picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 80,
   );

   if( photo == null ) return null;

   print('Tenemos una imagen ${ photo.path}');

   //retornamos en path de la imagen
   return photo.path;
  }

  //obtener una imagen desde la camara
  @override
  Future<String?> takePhoto() async{
   
   final XFile? photo = await _picker.pickImage(
    source: ImageSource.camera,
    imageQuality: 80,
    preferredCameraDevice: CameraDevice.rear //le decimos que use la camara trasera por defecto
   );

   if( photo == null ) return null;

   print('Tenemos una imagen ${ photo.path}');

   //retornamos en path de la imagen
   return photo.path;
  }

}