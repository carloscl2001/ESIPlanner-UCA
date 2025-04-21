//PARA SERVIDOR EN LOCAL
class ApiServices {

  // static const String _devBaseUrlMovil = 'http://10.182.119.113:8000'; // Desarrollo local en movil fisico
  static const String _devBaseUrlWeb = 'http://localhost:8000'; // Para navegador
  // static const String _prodBaseUrl = 'https://api.tudominio.com'; // Producción
  // static const String _emuladorBaseUrl = 'http://10.0.2.2:8000'; // Emulador de Android
  // static const String _railwayBaseUrl = 'https://servidor-production-42cc.up.railway.app'; // Railway

  //usando la ip del pc
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: _devBaseUrlWeb,
  ); 

} 