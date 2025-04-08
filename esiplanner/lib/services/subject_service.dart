import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_services.dart';

class SubjectService {
  //Funcion que hace la solictud HTTP para obtener los datos de una asignatura
  Future<Map<String, dynamic>> getSubjectData({
    required String codeSubject,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiServices.baseUrl}/subjects/$codeSubject'),
      );

      if (response.statusCode == 200) {
        // Asegúrate de que el cuerpo de la respuesta se decodifique en UTF-8
        String responseBody = utf8.decode(response.bodyBytes);

        // Decodifica el JSON de la respuesta
        return json.decode(responseBody);
      } else {
        return {'success': false, 'message': 'Asignatura no encontrada'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al realizar la solicitud: $e',
      };
    }
  }

  //Funcion que hace la solictud HTTP para obtener los datos de un grado
  Future<Map<String, dynamic>> getDegreeData({
    required String degreeName,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiServices.baseUrl}/degrees/$degreeName'),
      );

      if (response.statusCode == 200) {
        // Asegúrate de que el cuerpo de la respuesta se decodifique en UTF-8
        String responseBody = utf8.decode(response.bodyBytes);

        // Decodifica el JSON de la respuesta
        return json.decode(responseBody);
      } else {
        return {'success': false, 'message': 'Degree no encontrado'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al realizar la solicitud: $e',
      };
    }
  }

  Future<List<String>> getAllDegrees() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiServices.baseUrl}/degrees/names/'),
      );

      if (response.statusCode == 200) {
        // Decodificar el cuerpo de la respuesta en UTF-8
        String responseBody = utf8.decode(response.bodyBytes);
        
        // Decodificar el JSON y convertirlo a List<String>
        List<dynamic> degreesJson = json.decode(responseBody);
        List<String> degrees = degreesJson.map((degree) => degree.toString()).toList();
        
        return degrees;
      } else {
        throw Exception('Error al obtener los grados: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en la solicitud: $e');
    }
  }


}
