class Pais {
  final String nome;
  final List<String>? capital;
  final String? bandeiraUrl;
  final int? populacao;


  Pais({
    required this.nome,
    this.capital,
    this.bandeiraUrl,
    this.populacao,
  });


  factory Pais.fromJson(Map<String, dynamic> json) {
    return Pais(
      nome: json['name']?['common'] ?? 'País desconhecido',
      capital: json['capital'] is List ? List<String>.from(json['capital']) : null,
      bandeiraUrl: json['flags']?['png'],
      populacao: json['population'],
    );
  }
  

  String get capitalFormatada {
    return capital?.join(', ') ?? 'Capital não informada';
  }
}