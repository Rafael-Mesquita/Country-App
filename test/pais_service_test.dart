import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:country_app/services/pais_service.dart';

@GenerateMocks([Dio])
import 'pais_service_test.mocks.dart';

void main() {
  late MockDio mockDio;
  late PaisService paisService;

  setUp(() {
    mockDio = MockDio();
    paisService = PaisService(dio: mockDio);
  });

  test('Deve retornar lista de países quando a API responde com sucesso', () async {
    when(mockDio.get(
      '/all',
      queryParameters: anyNamed('queryParameters'),
    )).thenAnswer((_) async => Response(
      data: [
        {
          'name': {'common': 'Brasil'},
          'capital': ['Brasília'],
          'flags': {'png': 'https://flagcdn.com/br.png'},
          'population': 213993437
        }
      ],
      statusCode: 200,
      requestOptions: RequestOptions(path: '/all'),
    ));

    final paises = await paisService.listarPaises();

    expect(paises, isNotEmpty);
    expect(paises.first.nome, 'Brasil');
    expect(paises.first.capital, ['Brasília']);
    expect(paises.first.bandeiraUrl, isNotNull);
  });

  test('Deve lançar exceção quando a API retorna erro 400', () async {
    when(mockDio.get(
      '/all',
      queryParameters: anyNamed('queryParameters'),
    )).thenThrow(DioException(
      requestOptions: RequestOptions(path: '/all'),
      response: Response(
        statusCode: 400,
        requestOptions: RequestOptions(path: '/all'),
      ),
    ));

    expect(() => paisService.listarPaises(), throwsA(isA<Exception>()));
  });

  test('Deve retornar país quando buscar por nome existente', () async {
    when(mockDio.get(
      '/name/Brasil',
      queryParameters: anyNamed('queryParameters'),
    )).thenAnswer((_) async => Response(
      data: [
        {
          'name': {'common': 'Brasil'},
          'capital': ['Brasília'],
          'flags': {'png': 'https://flagcdn.com/br.png'},
          'population': 213993437
        }
      ],
      statusCode: 200,
      requestOptions: RequestOptions(path: '/name/Brasil'),
    ));

    final pais = await paisService.buscarPaisPorNome('Brasil');
    
    expect(pais, isNotNull);
    expect(pais?.nome, 'Brasil');
  });

  test('Deve retornar null quando buscar por nome inexistente', () async {
    when(mockDio.get(
      '/name/Atlantida',
      queryParameters: anyNamed('queryParameters'),
    )).thenThrow(DioException(
      requestOptions: RequestOptions(path: '/name/Atlantida'),
      response: Response(
        statusCode: 404,
        requestOptions: RequestOptions(path: '/name/Atlantida'),
      ),
    ));

    final pais = await paisService.buscarPaisPorNome('Atlantida');
    expect(pais, isNull);
  });

  test('Deve chamar o método listarPaises() uma vez', () async {
    when(mockDio.get(
      '/all',
      queryParameters: anyNamed('queryParameters'),
    )).thenAnswer((_) async => Response(
      data: [],
      statusCode: 200,
      requestOptions: RequestOptions(path: '/all'),
    ));

    await paisService.listarPaises();
    verify(mockDio.get(
      '/all',
      queryParameters: anyNamed('queryParameters'),
    )).called(1);
  });
}