import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:web/web.dart' as web;
import '../config/api_config.dart';
import '../models/cliente.dart';
import '../models/funcionario.dart';
import '../services/api_service.dart';
import '../widgets/ui_helpers.dart';

//tela de cliente e funcionario juntos
class PessoasPage extends StatefulWidget {
  const PessoasPage({super.key});
  @override
  State<PessoasPage> createState() => _PessoasPageState();
}

class _PessoasPageState extends State<PessoasPage> {
  final _api = ApiService();
  final _moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final _data = DateFormat('dd/MM/yyyy');
  List<Cliente> _clientes = [];
  List<Funcionario> _funcionarios = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  //busca os dois juntos
  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      final resultados = await Future.wait([_api.listarClientes(), _api.listarFuncionarios()]);
      _clientes = resultados[0] as List<Cliente>;
      _funcionarios = resultados[1] as List<Funcionario>;
    } catch (e) {
      if (mounted) mostrarMensagem(context, e.toString(), erro: true);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  //junta e ordena por nome
  List<Map<String, dynamic>> _pessoas() {
    final pessoas = <Map<String, dynamic>>[
      ..._clientes.map((c) => {'tipo': 'CLIENTE', 'nome': c.nome, 'pessoa': c}),
      ..._funcionarios.map((f) => {'tipo': 'FUNCIONARIO', 'nome': f.nome, 'pessoa': f}),
    ];
    pessoas.sort((a, b) => (a['nome'] as String).toLowerCase().compareTo((b['nome'] as String).toLowerCase()));
    return pessoas;
  }

  String? _obrigatorio(String? v) => v == null || v.trim().isEmpty ? 'Campo obrigatório.' : null;

  String? _numeroPositivo(String? v) {
    final n = double.tryParse((v ?? '').replaceAll(',', '.'));
    return n == null || n < 0 ? 'Informe um valor válido.' : null;
  }

  //le a data dd/mm/aaaa
  DateTime? _lerData(String texto) {
    try {
      return _data.parseStrict(texto.trim());
    } catch (e) {
      return null;
    }
  }

  String? _dataValida(String? v) => _lerData(v ?? '') == null ? 'Informe a data como dd/mm/aaaa.' : null;

  //sem item cadastra, com item edita
  Future<void> _abrirFormulario([Map<String, dynamic>? item]) async {
    final editando = item != null;
    //cliente e funcionario tem os mesmos campos de pessoa
    final dynamic p = item?['pessoa'];
    final f = item?['tipo'] == 'FUNCIONARIO' ? p as Funcionario : null;
    final c = item?['tipo'] == 'CLIENTE' ? p as Cliente : null;
    final formKey = GlobalKey<FormState>();
    final nome = TextEditingController(text: p?.nome ?? '');
    final cpf = TextEditingController(text: p?.cpf ?? '');
    final telefone = TextEditingController(text: p?.telefone ?? '');
    final email = TextEditingController(text: p?.email ?? '');
    final dataNascimento = TextEditingController(text: p == null ? '' : _data.format(p.dataNascimento));
    final cep = TextEditingController(text: p?.cep ?? '');
    final logradouro = TextEditingController(text: p?.logradouro ?? '');
    final numero = TextEditingController(text: p?.numero ?? '');
    final bairro = TextEditingController(text: p?.bairro ?? '');
    final cidade = TextEditingController(text: p?.cidade ?? '');
    final observacao = TextEditingController(text: c?.observacao ?? '');
    final salario = TextEditingController(text: (f?.salario ?? 0).toStringAsFixed(2).replaceAll('.', ','));
    final dataAdmissao = TextEditingController(text: f == null ? '' : _data.format(f.dataAdmissao));
    //sempre tem um marcado
    String tipo = item?['tipo'] ?? 'CLIENTE';
    String? uf = p?.uf;
    String? cargo = f?.cargo;
    bool ativo = p?.ativo ?? true;

    final salvo = await showDialog<bool>(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
                  title: Text(editando ? 'Editar pessoa' : 'Nova pessoa'),
                  content: SizedBox(
                      width: 520,
                      child: Form(
                          key: formKey,
                          child: SingleChildScrollView(
                              child: Column(mainAxisSize: MainAxisSize.min, children: [
                            SegmentedButton<String>(
                                segments: const [
                                  ButtonSegment(value: 'CLIENTE', label: Text('Cliente'), icon: Icon(Icons.person)),
                                  ButtonSegment(
                                      value: 'FUNCIONARIO', label: Text('Funcionário'), icon: Icon(Icons.badge))
                                ],
                                selected: {tipo},
                                //na edicao nao troca o tipo
                                onSelectionChanged: editando ? null : (v) => setDialogState(() => tipo = v.first)),
                            const SizedBox(height: 16),
                            TextFormField(
                                controller: nome,
                                decoration: const InputDecoration(labelText: 'Nome'),
                                validator: _obrigatorio),
                            const SizedBox(height: 12),
                            TextFormField(
                                controller: cpf,
                                decoration: const InputDecoration(labelText: 'CPF'),
                                validator: _obrigatorio),
                            const SizedBox(height: 12),
                            TextFormField(
                                controller: telefone,
                                decoration: const InputDecoration(labelText: 'Telefone'),
                                validator: _obrigatorio),
                            const SizedBox(height: 12),
                            TextFormField(
                                controller: email,
                                decoration: const InputDecoration(labelText: 'E-mail'),
                                keyboardType: TextInputType.emailAddress),
                            const SizedBox(height: 12),
                            TextFormField(
                                controller: dataNascimento,
                                decoration: const InputDecoration(labelText: 'Data de nascimento (dd/mm/aaaa)'),
                                validator: _dataValida),
                            const SizedBox(height: 12),
                            TextFormField(
                                controller: cep,
                                decoration: const InputDecoration(labelText: 'CEP'),
                                validator: _obrigatorio),
                            const SizedBox(height: 12),
                            TextFormField(
                                controller: logradouro,
                                decoration: const InputDecoration(labelText: 'Logradouro'),
                                validator: _obrigatorio),
                            const SizedBox(height: 12),
                            TextFormField(
                                controller: numero,
                                decoration: const InputDecoration(labelText: 'Número'),
                                validator: _obrigatorio),
                            const SizedBox(height: 12),
                            TextFormField(
                                controller: bairro,
                                decoration: const InputDecoration(labelText: 'Bairro'),
                                validator: _obrigatorio),
                            const SizedBox(height: 12),
                            TextFormField(
                                controller: cidade,
                                decoration: const InputDecoration(labelText: 'Cidade'),
                                validator: _obrigatorio),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                                initialValue: uf,
                                decoration: const InputDecoration(labelText: 'UF'),
                                items: ufs.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                                onChanged: (v) => setDialogState(() => uf = v),
                                validator: (v) => v == null ? 'Selecione a UF.' : null),
                            const SizedBox(height: 12),
                            //so do cliente
                            if (tipo == 'CLIENTE')
                              TextFormField(
                                  controller: observacao,
                                  decoration: const InputDecoration(labelText: 'Observação'),
                                  maxLines: 2),
                            //so do funcionario
                            if (tipo == 'FUNCIONARIO') ...[
                              DropdownButtonFormField<String>(
                                  initialValue: cargo,
                                  decoration: const InputDecoration(labelText: 'Cargo'),
                                  items: cargos.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                  onChanged: (v) => setDialogState(() => cargo = v),
                                  validator: (v) => v == null ? 'Selecione o cargo.' : null),
                              const SizedBox(height: 12),
                              TextFormField(
                                  controller: salario,
                                  decoration: const InputDecoration(labelText: 'Salário'),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: _numeroPositivo),
                              const SizedBox(height: 12),
                              TextFormField(
                                  controller: dataAdmissao,
                                  decoration: const InputDecoration(labelText: 'Data de admissão (dd/mm/aaaa)'),
                                  validator: _dataValida),
                            ],
                            SwitchListTile(
                                value: ativo,
                                onChanged: (v) => setDialogState(() => ativo = v),
                                title: const Text('Ativo')),
                          ])))),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                    FilledButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final emailTexto = email.text.trim().isEmpty ? null : email.text.trim();
                          try {
                            if (tipo == 'CLIENTE') {
                              await _api.salvarCliente(Cliente(
                                  id: c?.id,
                                  cpf: cpf.text.trim(),
                                  nome: nome.text.trim(),
                                  telefone: telefone.text.trim(),
                                  email: emailTexto,
                                  dataNascimento: _lerData(dataNascimento.text)!,
                                  cep: cep.text.trim(),
                                  logradouro: logradouro.text.trim(),
                                  numero: numero.text.trim(),
                                  bairro: bairro.text.trim(),
                                  cidade: cidade.text.trim(),
                                  uf: uf!,
                                  observacao: observacao.text.trim().isEmpty ? null : observacao.text.trim(),
                                  ativo: ativo));
                            } else {
                              await _api.salvarFuncionario(Funcionario(
                                  id: f?.id,
                                  cpf: cpf.text.trim(),
                                  nome: nome.text.trim(),
                                  telefone: telefone.text.trim(),
                                  email: emailTexto,
                                  dataNascimento: _lerData(dataNascimento.text)!,
                                  cep: cep.text.trim(),
                                  logradouro: logradouro.text.trim(),
                                  numero: numero.text.trim(),
                                  bairro: bairro.text.trim(),
                                  cidade: cidade.text.trim(),
                                  uf: uf!,
                                  salario: double.parse(salario.text.replaceAll(',', '.')),
                                  cargo: cargo!,
                                  dataAdmissao: _lerData(dataAdmissao.text)!,
                                  ativo: ativo));
                            }
                            if (context.mounted) Navigator.pop(context, true);
                          } catch (e) {
                            if (context.mounted) mostrarMensagem(context, e.toString(), erro: true);
                          }
                        },
                        child: const Text('Salvar'))
                  ],
                )));
    if (salvo == true) {
      await _carregar();
      if (mounted) mostrarMensagem(context, 'Pessoa salva com sucesso.');
    }
  }

  //exclui conforme o tipo
  Future<void> _excluir(Map<String, dynamic> item) async {
    if (!await confirmarExclusao(context, item['nome'] as String)) return;
    try {
      if (item['tipo'] == 'CLIENTE') {
        await _api.excluirCliente((item['pessoa'] as Cliente).id!);
      } else {
        await _api.excluirFuncionario((item['pessoa'] as Funcionario).id!);
      }
      await _carregar();
      if (mounted) mostrarMensagem(context, 'Pessoa excluída.');
    } catch (e) {
      if (mounted) mostrarMensagem(context, e.toString(), erro: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pessoas = _pessoas();
    return Scaffold(
      body: _carregando
          ? const LoadingView()
          : RefreshIndicator(
              onRefresh: _carregar,
              child: pessoas.isEmpty
                  ? const EmptyView('Nenhuma pessoa cadastrada.')
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: pessoas.length,
                      itemBuilder: (_, i) {
                        final item = pessoas[i];
                        final cliente = item['tipo'] == 'CLIENTE';
                        final c = cliente ? item['pessoa'] as Cliente : null;
                        final f = cliente ? null : item['pessoa'] as Funcionario;
                        final nome = item['nome'] as String;
                        final ativo = c?.ativo ?? f!.ativo;
                        return Card(
                            child: ListTile(
                          leading: CircleAvatar(child: Text(nome.isEmpty ? '?' : nome[0].toUpperCase())),
                          title: Text(nome),
                          subtitle: Text(cliente
                              ? '${c!.cpf} • ${c.telefone} • ${c.cidade}/${c.uf}'
                              : '${f!.cpf} • ${f.cargo} • ${_moeda.format(f.salario)} • ${f.cidade}/${f.uf}'),
                          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                            Chip(
                                label: Text(cliente ? 'Cliente' : 'Funcionário'),
                                backgroundColor: cliente ? Colors.blue.shade100 : Colors.purple.shade100),
                            const SizedBox(width: 8),
                            Icon(ativo ? Icons.check_circle : Icons.block,
                                color: ativo ? Colors.green : Colors.grey),
                            IconButton(onPressed: () => _abrirFormulario(item), icon: const Icon(Icons.edit_outlined)),
                            IconButton(onPressed: () => _excluir(item), icon: const Icon(Icons.delete_outline))
                          ]),
                        ));
                      },
                    ),
            ),
      floatingActionButton: Row(mainAxisSize: MainAxisSize.min, children: [
        FloatingActionButton.extended(
            heroTag: 'relatorio',
            onPressed: _abrirRelatorio,
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Relatório')),
        const SizedBox(width: 12),
        FloatingActionButton.extended(
            heroTag: 'novaPessoa',
            onPressed: () => _abrirFormulario(), icon: const Icon(Icons.add), label: const Text('Nova pessoa')),
      ]),
    );
  }

  //abre o pdf que o back gera
  void _abrirRelatorio() {
    final aba = web.window.open('${ApiConfig.baseUrl}/relatorio/pessoa', '_blank');
    if (aba == null) mostrarMensagem(context, 'Não foi possível abrir o relatório', erro: true);
  }
}
