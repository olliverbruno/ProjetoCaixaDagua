import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/cliente.dart';
import '../services/api_service.dart';
import '../widgets/ui_helpers.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});
  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  final _api = ApiService();
  final _data = DateFormat('dd/MM/yyyy');
  List<Cliente> _clientes = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      _clientes = await _api.listarClientes();
    } catch (e) {
      if (mounted) mostrarMensagem(context, e.toString(), erro: true);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  String? _obrigatorio(String? v) => v == null || v.trim().isEmpty ? 'Campo obrigatório.' : null;

  // Lê a data digitada no formato dd/mm/aaaa. Devolve null se estiver errada.
  DateTime? _lerData(String texto) {
    try {
      return _data.parseStrict(texto.trim());
    } catch (e) {
      return null;
    }
  }

  String? _dataValida(String? v) => _lerData(v ?? '') == null ? 'Informe a data como dd/mm/aaaa.' : null;

  // O back-end não tem rota de atualizar cliente, por isso o formulário só cadastra.
  Future<void> _abrirFormulario() async {
    final formKey = GlobalKey<FormState>();
    final nome = TextEditingController();
    final cpf = TextEditingController();
    final telefone = TextEditingController();
    final email = TextEditingController();
    final dataNascimento = TextEditingController();
    final cep = TextEditingController();
    final logradouro = TextEditingController();
    final numero = TextEditingController();
    final bairro = TextEditingController();
    final cidade = TextEditingController();
    final observacao = TextEditingController();
    String? uf;
    bool ativo = true;

    final salvo = await showDialog<bool>(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
                  title: const Text('Novo cliente'),
                  content: SizedBox(
                      width: 520,
                      child: Form(
                          key: formKey,
                          child: SingleChildScrollView(
                              child: Column(mainAxisSize: MainAxisSize.min, children: [
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
                            TextFormField(
                                controller: observacao,
                                decoration: const InputDecoration(labelText: 'Observação'),
                                maxLines: 2),
                            SwitchListTile(
                                value: ativo,
                                onChanged: (v) => setDialogState(() => ativo = v),
                                title: const Text('Cliente ativo')),
                          ])))),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                    FilledButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          try {
                            await _api.salvarCliente(Cliente(
                                cpf: cpf.text.trim(),
                                nome: nome.text.trim(),
                                telefone: telefone.text.trim(),
                                email: email.text.trim().isEmpty ? null : email.text.trim(),
                                dataNascimento: _lerData(dataNascimento.text)!,
                                cep: cep.text.trim(),
                                logradouro: logradouro.text.trim(),
                                numero: numero.text.trim(),
                                bairro: bairro.text.trim(),
                                cidade: cidade.text.trim(),
                                uf: uf!,
                                observacao: observacao.text.trim().isEmpty ? null : observacao.text.trim(),
                                ativo: ativo));
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
      if (mounted) mostrarMensagem(context, 'Cliente salvo com sucesso.');
    }
  }

  Future<void> _excluir(Cliente cliente) async {
    if (!await confirmarExclusao(context, cliente.nome)) return;
    try {
      await _api.excluirCliente(cliente.id!);
      await _carregar();
      if (mounted) mostrarMensagem(context, 'Cliente excluído.');
    } catch (e) {
      if (mounted) mostrarMensagem(context, e.toString(), erro: true);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: _carregando
            ? const LoadingView()
            : RefreshIndicator(
                onRefresh: _carregar,
                child: _clientes.isEmpty
                    ? const EmptyView('Nenhum cliente cadastrado.')
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _clientes.length,
                        itemBuilder: (_, i) {
                          final c = _clientes[i];
                          return Card(
                              child: ListTile(
                            leading: CircleAvatar(child: Text(c.nome.isEmpty ? '?' : c.nome[0].toUpperCase())),
                            title: Text(c.nome),
                            subtitle: Text('${c.cpf} • ${c.telefone} • ${c.cidade}/${c.uf}'),
                            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(c.ativo ? Icons.check_circle : Icons.block,
                                  color: c.ativo ? Colors.green : Colors.grey),
                              IconButton(onPressed: () => _excluir(c), icon: const Icon(Icons.delete_outline))
                            ]),
                          ));
                        },
                      ),
              ),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _abrirFormulario(), icon: const Icon(Icons.add), label: const Text('Novo cliente')),
      );
}
