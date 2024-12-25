

//hemos instalado dotenv para manejar las variables de entorno con --> flutter pub add flutter_dotenv
//en el archivo pubspec.yaml hemos incluido al final en el apartado de los assets: - .env
//en el main lo hacemos asincrono y ponemos --> await Environment.initEmvironment(); para iniciar las variables de entorno
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {

  //iniciamos el environment codigo sacado de --> https://pub.dev/packages/flutter_dotenv
  static initEmvironment() async{
    await dotenv.load(fileName: '.env');
  }

  static String apiUrl = dotenv.env['API_URL'] ?? 'No esta configurado el API_URL';
}