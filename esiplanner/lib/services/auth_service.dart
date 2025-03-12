import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final String baseUrl = 'http://192.168.1.45:8000'; // URL base de la API usando el emulador de Android
  //final String baseUrl = 'http://127.0.0.1:8000'; // URL base de la API para el resto
  //final String baseUrl = 'http://localhost:8000'; // URL base de la API para el resto


  // Método para registrar un usuario -> register_screen
  Future<Map<String, dynamic>> register({
  required String email,
  required String username,
  required String password,
  required String name,
  required String surname,
  required String degree,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'username': username,
          'password': password,
          'name': name,
          'surname': surname,
          'degree': degree,
        }),
      );

      if (response.statusCode == 201) {
        return {'success': true};
      } else {  
        String errorMessage = 'Error';

        final errorData = jsonDecode(response.body);
        if (errorData.containsKey('detail')) {
          if(errorData['detail'] == "Email already registered"){
            errorMessage = "Email ya registrado. Introduzca otro";
          }else if (errorData['detail'] == "Username already exists"){
            errorMessage = "Usuario ya registrado. Introduzca otro";
          }else {
            errorMessage = "Email y usuario ya registrados. Introduzca otros";
          }
        }

        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  //Metodo para hacer login -> login_screen
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        // Si la autenticación es exitosa
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        // Si la respuesta es un error, extraemos el mensaje de detalle
        String errorMessage = 'Credenciales incorrectas. Inténtelo nuevamente.';
        
        // Extraer el detalle de la respuesta
        final errorData = jsonDecode(response.body);
        if (errorData.containsKey('detail')) {
          if (errorData['detail'] == "User not found"){
            errorMessage = "Tu usuario no existe. Vuelve a intentarlo";
          }else{
            errorMessage = "Tu contraseña no es correcta. Vuelve a intentarlo";
          }
        }

        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  //Metodo para obtener los grados de la esi y mostrarlos en el despegable -> login_screen
  Future<List<String>> getDegrees() async {
    final url = Uri.parse('$baseUrl/degrees/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Decodifica los bytes del cuerpo usando UTF-8
      final utf8DecodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> data = json.decode(utf8DecodedBody);

      // Mapea los grados a una lista de nombres (si tiene un campo 'name')
      return data.map<String>((degree) => degree['name'].toString()).toList();
    } else {
      throw Exception('Failed to load degrees');
    }
  }

}
