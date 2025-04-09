//PARA SERVIDOR EN LOCAL
class ApiServices {

  static const String _devBaseUrl = 'http://10.182.119.113:8000'; // Desarrollo local
  // static const String _prodBaseUrl = 'https://api.tudominio.com'; // Producción
  // static const String _emuladorBaseUrl = 'http://10.0.2.2:8000'; // Emulador de Android
  // static const String _railwayBaseUrl = 'https://servidor-production-42cc.up.railway.app'; // Railway

  //usando la ip del pc
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: _devBaseUrl,
  ); 

} 