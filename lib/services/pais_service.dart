import 'package:dio/dio.dart';
import '../models/pais_model.dart';

class PaisService {
  final Dio _dio;

  PaisService({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(
    baseUrl: 'https://restcountries.com/v3.1',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<List<Pais>> listarPaises() async {
    try {
      final response = await _dio.get(
        '/all',
        queryParameters: {
          'fields': 'name,capital,flags,population',
        },
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((paisJson) => Pais.fromJson(paisJson))
            .toList();
      } else {
        throw Exception('Erro na API: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _tratarErroDio(e);
    } catch (e) {
      throw Exception('Erro desconhecido: $e');
    }
  }

  Future<Pais?> buscarPaisPorNome(String nome) async {
    try {
      final response = await _dio.get(
        '/name/$nome',
        queryParameters: {
          'fullText': 'true',
          'fields': 'name,capital,flags,population',
        },
      );

      if (response.statusCode == 200) {
        return Pais.fromJson((response.data as List).first);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw _tratarErroDio(e);
    } catch (e) {
      throw Exception('Erro na busca: $e');
    }
  }

  String _tratarErroDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Tempo de conexão esgotado';
      case DioExceptionType.badResponse:
        return 'Erro na API (${e.response?.statusCode})';
      case DioExceptionType.connectionError:
        return 'Erro de conexão com a internet';
      default:
        return 'Erro ao acessar serviço: ${e.message}';
    }
  }
}