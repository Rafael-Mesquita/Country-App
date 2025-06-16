import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:country_app/models/pais_model.dart';
import 'package:country_app/services/pais_repository.dart';

// Mock manual do PaisRepository
class MockPaisRepository extends PaisRepository {
  final List<Pais> paises;
  MockPaisRepository(this.paises);

  @override
  Future<List<Pais>> getTodosPaises() async {
    return paises;
  }
}

void main() {
  final fakePaises = [
    Pais(
      nome: 'Brasil',
      capital: ['Brasília'],
      bandeiraUrl: 'https://flagcdn.com/br.png',
      populacao: 211000000,
    ),
    Pais(
      nome: 'Argentina',
      capital: ['Buenos Aires'],
      bandeiraUrl: 'https://flagcdn.com/ar.png',
      populacao: 45000000,
    ),
  ];

  testWidgets('Cenário 01 – Verifica se o nome do país é carregado', (tester) async {
    await mockNetworkImagesFor(() async {
      // Substitui o repositório globalmente
      final homePage = HomePageTestable(repository: MockPaisRepository(fakePaises));
      await tester.pumpWidget(MaterialApp(home: homePage));
      await tester.pumpAndSettle();
      expect(find.text('Brasil'), findsOneWidget);
      expect(find.text('Argentina'), findsOneWidget);
    });
  });

  testWidgets('Cenário 02 – Verifica se a bandeira é exibida', (tester) async {
    await mockNetworkImagesFor(() async {
      final homePage = HomePageTestable(repository: MockPaisRepository(fakePaises));
      await tester.pumpWidget(MaterialApp(home: homePage));
      await tester.pumpAndSettle();
      final image = find.byType(Image);
      expect(image, findsWidgets);
    });
  });
}

mockNetworkImagesFor(Future<Null> Function() param0) {
}

// Widget de teste que permite injetar o repositório mockado
class HomePageTestable extends StatefulWidget {
  final PaisRepository repository;
  const HomePageTestable({required this.repository, Key? key}) : super(key: key);

  @override
  State<HomePageTestable> createState() => _HomePageTestableState();
}

class _HomePageTestableState extends State<HomePageTestable> {
  late Future<List<Pais>> _futurePaises;
  String _erro = '';

  @override
  void initState() {
    super.initState();
    _futurePaises = _carregarPaises();
  }

  Future<List<Pais>> _carregarPaises() async {
    try {
      return await widget.repository.getTodosPaises();
    } catch (e) {
      setState(() {
        _erro = e.toString();
      });
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Países')),
      body: _erro.isNotEmpty
          ? Center(child: Text(_erro))
          : FutureBuilder<List<Pais>>(
              future: _futurePaises,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: [200m${snapshot.error}[0m'));
                }
                final paises = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: paises.length,
                  itemBuilder: (context, index) {
                    final pais = paises[index];
                    return ListTile(
                      leading: pais.bandeiraUrl != null
                          ? Image.network(pais.bandeiraUrl!, width: 40)
                          : const Icon(Icons.flag),
                      title: Text(pais.nome),
                      subtitle: Text(pais.capitalFormatada),
                      trailing: Text(pais.populacao?.toString() ?? 'N/D'),
                    );
                  },
                );
              },
            ),
    );
  }
}