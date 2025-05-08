//PARA SERVIDOR EN LOCAL
class ApiServices {

  // static const String _devBaseUrl = 'http://10.182.119.113:8000'; // Desarrollo local en movil fisico UCA
  // static const String _devBaseUrl = 'http://192.168.1.41:8000'; // Desarrollo local en movil fisico CASA
  static const String _devBaseUrl = 'http://localhost:8000'; // Para navegador
  // static const String _devBaseUrl = 'https://api.tudominio.com'; // Producción
  // static const String _devBaseUrl = 'http://10.0.2.2:8000'; // Emulador de Android
  // static const String _devBaseUrl = 'https://servidor-production-42cc.up.railway.app'; // Railway

  //usando la ip del pc
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: _devBaseUrl,
  ); 

} 