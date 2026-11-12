//valores do enum
const cargos = ['VENDEDOR', 'INSTALADOR'];

class Funcionario {
  final int? id;
  final String cpf;
  final String nome;
  final String telefone;
  final String? email;
  final DateTime dataNascimento;
  final String cep;
  final String logradouro;
  final String numero;
  final String bairro;
  final String cidade;
  final String uf;
  final double salario;
  final String cargo;
  final DateTime dataAdmissao;
  final bool ativo;

  const Funcionario({
    this.id,
    required this.cpf,
    required this.nome,
    required this.telefone,
    this.email,
    required this.dataNascimento,
    required this.cep,
    required this.logradouro,
    required this.numero,
    required this.bairro,
    required this.cidade,
    required this.uf,
    required this.salario,
    required this.cargo,
    required this.dataAdmissao,
    this.ativo = true,
  });

  // Converte o JSON recebido da API em um objeto Dart.
  factory Funcionario.fromJson(Map<String, dynamic> json) => Funcionario(
        id: json['id'] as int?,
        cpf: json['cpf'] ?? '',
        nome: json['nome'] ?? '',
        telefone: json['telefone'] ?? '',
        email: json['email'],
        dataNascimento: DateTime.parse(json['dataNascimento']),
        cep: json['cep'] ?? '',
        logradouro: json['logradouro'] ?? '',
        numero: json['numero'] ?? '',
        bairro: json['bairro'] ?? '',
        cidade: json['cidade'] ?? '',
        uf: json['uf'] ?? '',
        salario: (json['salario'] as num).toDouble(),
        cargo: json['cargo'] ?? '',
        dataAdmissao: DateTime.parse(json['dataAdmissao']),
        ativo: json['ativo'] ?? true,
      );

  //data no formato aaaa-mm-dd
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'cpf': cpf,
        'nome': nome,
        'telefone': telefone,
        'email': email,
        'dataNascimento': dataNascimento.toIso8601String().substring(0, 10),
        'cep': cep,
        'logradouro': logradouro,
        'numero': numero,
        'bairro': bairro,
        'cidade': cidade,
        'uf': uf,
        'salario': salario,
        'cargo': cargo,
        'dataAdmissao': dataAdmissao.toIso8601String().substring(0, 10),
        'ativo': ativo,
      };
}
