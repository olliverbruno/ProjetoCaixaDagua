//valores do enum
const ufs = [
  'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA',
  'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO',
];

class Cliente {
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
  final DateTime? dataCadastro;
  final String? observacao;
  final bool ativo;

  const Cliente({
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
    this.dataCadastro,
    this.observacao,
    this.ativo = true,
  });

  // Converte o JSON recebido da API em um objeto Dart.
  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
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
        dataCadastro: json['dataCadastro'] == null ? null : DateTime.parse(json['dataCadastro']),
        observacao: json['observacao'],
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
        'observacao': observacao,
        'ativo': ativo,
      };
}
