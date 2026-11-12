class Marca {
  final int? id;
  final String nome;

  const Marca({this.id, required this.nome});

  // Converte o JSON recebido da API em um objeto Dart.
  factory Marca.fromJson(Map<String, dynamic> json) =>
      Marca(id: json['id'] as int?, nome: json['nome'] ?? '');

  //manda o id se ja existir
  Map<String, dynamic> toJson() => {if (id != null) 'id': id, 'nome': nome};
}
