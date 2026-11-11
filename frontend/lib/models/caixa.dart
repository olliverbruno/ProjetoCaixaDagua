import 'marca.dart';

// Valores aceitos pelos enums Cor, Material e Formato do back-end.
const cores = ['AZUL', 'CINZA', 'PRETO'];
const materiais = ['PVC', 'FIBRA', 'POLIETILENO'];
const formatos = ['REDONDA', 'QUADRADA', 'RETANGULAR'];

class Caixa {
  final int? id;
  final Marca marca;
  final int capacidadeLitros;
  final double altura;
  final double largura;
  final String cor;
  final String material;
  final String formato;
  final double preco;
  final int estoque;

  const Caixa({
    this.id,
    required this.marca,
    required this.capacidadeLitros,
    required this.altura,
    required this.largura,
    required this.cor,
    required this.material,
    required this.formato,
    required this.preco,
    required this.estoque,
  });

  // A marca chega como outro objeto JSON dentro da caixa.
  factory Caixa.fromJson(Map<String, dynamic> json) => Caixa(
        id: json['id'] as int?,
        marca: Marca.fromJson(json['marca']),
        capacidadeLitros: json['capacidadeLitros'] ?? 0,
        altura: (json['altura'] as num).toDouble(),
        largura: (json['largura'] as num).toDouble(),
        cor: json['cor'] ?? '',
        material: json['material'] ?? '',
        formato: json['formato'] ?? '',
        preco: (json['preco'] as num).toDouble(),
        estoque: json['estoque'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'marca': marca.toJson(),
        'capacidadeLitros': capacidadeLitros,
        'altura': altura,
        'largura': largura,
        'cor': cor,
        'material': material,
        'formato': formato,
        'preco': preco,
        'estoque': estoque,
      };
}
