import 'package:flutter/material.dart';
import 'services/pais_repository.dart';
import 'models/pais_model.dart';


void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Países do Mundo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  final PaisRepository _repository = PaisRepository();
  late Future<List<Pais>> _futurePaises;
  String _erro = '';

  @override
  void initState() {
    super.initState();
    _futurePaises = _carregarPaises();
  }


  Future<List<Pais>> _carregarPaises() async {
    try {
      return await _repository.getTodosPaises();
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
                  return Center(child: Text('Erro: ${snapshot.error}'));
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