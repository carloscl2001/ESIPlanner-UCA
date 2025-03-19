class ApiServices {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://192.168.1.44:8000',
  ); //usando la ip del pc
  //static const String baseUrl =  String.fromEnvironment('BASE_URL', defaultValue: 'http://10.0.2.2:8000');
} 
// URL base de la API usando el emulador de Android