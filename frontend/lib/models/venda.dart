import 'caixa.dart';
import 'cliente.dart';
import 'funcionario.dart';

class Venda {
  final int id;
  final DateTime dataVenda;
  final Cliente cliente;
  final Funcionario vendedor;
  final Funcionario? instalador;
  final List<Caixa> caixas;
  final double valorTotal;
  final DateTime? dataInstalacao;

  const Venda({
    required this.id,
    required this.dataVenda,
    required this.cliente,
    required this.vendedor,
    this.instalador,
    required this.caixas,
    required this.valorTotal,
    this.dataInstalacao,
  });

  // Uma venda contém outros objetos (cliente, vendedor, instalador) e uma lista de caixas.
  factory Venda.fromJson(Map<String, dynamic> json) => Venda(
        id: json['id'],
        dataVenda: DateTime.parse(json['dataVenda']),
        cliente: Cliente.fromJson(json['cliente']),
        vendedor: Funcionario.fromJson(json['vendedor']),
        instalador: json['instalador'] == null ? null : Funcionario.fromJson(json['instalador']),
        caixas: (json['caixas'] as List).map((e) => Caixa.fromJson(e)).toList(),
        valorTotal: (json['valorTotal'] as num).toDouble(),
        dataInstalacao: json['dataInstalacao'] == null ? null : DateTime.parse(json['dataInstalacao']),
      );

  // Usado no PUT de atualizar: a API pede a venda completa.
  Map<String, dynamic> toJson() => {
        'id': id,
        'dataVenda': dataVenda.toIso8601String().substring(0, 10),
        'cliente': cliente.toJson(),
        'vendedor': vendedor.toJson(),
        if (instalador != null) 'instalador': instalador!.toJson(),
        'caixas': caixas.map((c) => c.toJson()).toList(),
        'valorTotal': valorTotal,
        if (dataInstalacao != null) 'dataInstalacao': dataInstalacao!.toIso8601String().substring(0, 10),
      };
}
