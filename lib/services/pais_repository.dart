import '../models/pais_model.dart';
import 'pais_service.dart';


class PaisRepository {
  final PaisService _service;

  PaisRepository({PaisService? service}) : _service = service ?? PaisService();

  Future<List<Pais>> getTodosPaises() async {
    return await _service.listarPaises();
  }


  Future<Pais?> buscarPorNome(String nome) async {
    return await _service.buscarPaisPorNome(nome);
  }
}