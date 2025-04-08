//PARA SERVIDOR EN LOCAL
class ApiServices {
  //usando la ip del pc
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://192.168.1.46:8000',
  ); 

  //usando el emulador de Android
  //static const String baseUrl =  String.fromEnvironment('BASE_URL', defaultValue: 'http://10.0.2.2:8000');
} 


// PARA RAILWAY
// class ApiServices {
//   static const String baseUrl = 'https://servidor-production-42cc.up.railway.app';
//   //static const String baseUrl =  String.fromEnvironment('BASE_URL', defaultValue: 'http://10.0.2.2:8000');
// } 