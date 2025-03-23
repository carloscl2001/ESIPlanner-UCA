import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_services.dart'; // Importa ApiServices

class AuthService {
  final String baseUrl = ApiServices.baseUrl; // Usa la URL base de ApiServices

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
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Extraer el token de la respuesta
        final token = responseData['token'];

        if (token == null) {
          return {'success': false, 'message': 'Token no recibido en la respuesta'};
        }

        return {
          'success': true,
          'token': token,  // Devolver el token
        };
      } else {
        String errorMessage = 'Error';
        final errorData = jsonDecode(response.body);

        if (errorData.containsKey('detail')) {
          if (errorData['detail'] == "Email already registered") {
            errorMessage = "Email ya registrado. Introduzca otro";
          } else if (errorData['detail'] == "Username already exists") {
            errorMessage = "Usuario ya registrado. Introduzca otro";
          } else {
            errorMessage = "Email y usuario ya registrados. Introduzca otros";
          }
        }

        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Método para hacer login -> login_screen
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        body: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        String errorMessage = 'Credenciales incorrectas. Inténtelo nuevamente.';
        final errorData = jsonDecode(response.body);

        if (errorData.containsKey('detail')) {
          if (errorData['detail'] == "User not found") {
            errorMessage = "Tu usuario no existe. Vuelve a intentarlo";
          } else {
            errorMessage = "Tu contraseña no es correcta. Vuelve a intentarlo";
          }
        }

        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Método para obtener los grados de la ESI y mostrarlos en el desplegable -> login_screen
  Future<List<String>> getDegrees() async {
    final url = Uri.parse('$baseUrl/degrees/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final utf8DecodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> data = json.decode(utf8DecodedBody);

      return data.map<String>((degree) => degree['name'].toString()).toList();
    } else {
      throw Exception('Failed to load degrees');
    }
  }
}
