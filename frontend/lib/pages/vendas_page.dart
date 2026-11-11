import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/caixa.dart';
import '../models/cliente.dart';
import '../models/funcionario.dart';
import '../models/venda.dart';
import '../services/api_service.dart';
import '../widgets/ui_helpers.dart';

class VendasPage extends StatefulWidget {
  const VendasPage({super.key});
  @override
  State<VendasPage> createState() => _VendasPageState();
}

class _VendasPageState extends State<VendasPage> {
  final _api = ApiService();
  final _moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final _data = DateFormat('dd/MM/yyyy');
  List<Venda> _vendas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      _vendas = await _api.listarVendas();
    } catch (e) {
      if (mounted) mostrarMensagem(context, e.toString(), erro: true);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  // Lê a data digitada no formato dd/mm/aaaa. Devolve null se estiver errada.
  DateTime? _lerData(String texto) {
    try {
      return _data.parseStrict(texto.trim());
    } catch (e) {
      return null;
    }
  }

  // Junta as caixas repetidas da venda para mostrar a quantidade de cada uma.
  Map<int, int> _quantidades(List<Caixa> caixas) {
    final quantidades = <int, int>{};
    for (final c in caixas) {
      quantidades[c.id!] = (quantidades[c.id!] ?? 0) + 1;
    }
    return quantidades;
  }

  Future<void> _novaVenda() async {
    try {
      final resultados =
          await Future.wait([_api.listarClientes(), _api.listarFuncionarios(), _api.listarCaixas()]);
      final clientes = (resultados[0] as List<Cliente>).where((c) => c.ativo).toList();
      final funcionarios = (resultados[1] as List<Funcionario>).where((f) => f.ativo).toList();
      final caixas = resultados[2] as List<Caixa>;
      final vendedores = funcionarios.where((f) => f.cargo == 'VENDEDOR').toList();
      final instaladores = funcionarios.where((f) => f.cargo == 'INSTALADOR').toList();
      if (!mounted) return;
      if (clientes.isEmpty || vendedores.isEmpty || caixas.isEmpty) {
        mostrarMensagem(context, 'Cadastre um cliente, um vendedor e pelo menos uma caixa d\'água.', erro: true);
        return;
      }

      int? clienteId = clientes.first.id;
      int? vendedorId = vendedores.first.id;
      int? instaladorId;
      int? caixaId = caixas.first.id;
      final quantidade = TextEditingController(text: '1');
      final dataInstalacao = TextEditingController();
      final itens = <Map<String, dynamic>>[];

      final criada = await showDialog<bool>(
          context: context,
          builder: (context) => StatefulBuilder(
              builder: (context, setLocal) => AlertDialog(
                    title: const Text('Nova venda'),
                    content: SizedBox(
                        width: 600,
                        child: SingleChildScrollView(
                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                          DropdownButtonFormField<int>(
                              initialValue: clienteId,
                              decoration: const InputDecoration(labelText: 'Cliente'),
                              items: clientes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nome))).toList(),
                              onChanged: (v) => setLocal(() => clienteId = v)),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int>(
                              initialValue: vendedorId,
                              decoration: const InputDecoration(labelText: 'Vendedor'),
                              items:
                                  vendedores.map((f) => DropdownMenuItem(value: f.id, child: Text(f.nome))).toList(),
                              onChanged: (v) => setLocal(() => vendedorId = v)),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int?>(
                              initialValue: instaladorId,
                              decoration: const InputDecoration(labelText: 'Instalador'),
                              items: [
                                const DropdownMenuItem<int?>(value: null, child: Text('Definir depois')),
                                ...instaladores.map((f) => DropdownMenuItem<int?>(value: f.id, child: Text(f.nome)))
                              ],
                              onChanged: (v) => setLocal(() => instaladorId = v)),
                          const SizedBox(height: 12),
                          TextFormField(
                              controller: dataInstalacao,
                              decoration: const InputDecoration(labelText: 'Data da instalação (dd/mm/aaaa)')),
                          const Divider(height: 28),
                          DropdownButtonFormField<int>(
                              initialValue: caixaId,
                              decoration: const InputDecoration(labelText: 'Caixa d\'água'),
                              items: caixas
                                  .map((c) => DropdownMenuItem(
                                      value: c.id,
                                      child: Text('${c.marca.nome} ${c.capacidadeLitros}L • ${c.cor} • '
                                          '${_moeda.format(c.preco)} • Estoque: ${c.estoque}')))
                                  .toList(),
                              onChanged: (v) => setLocal(() => caixaId = v)),
                          const SizedBox(height: 12),
                          TextFormField(
                              controller: quantidade,
                              decoration: const InputDecoration(labelText: 'Quantidade'),
                              keyboardType: TextInputType.number),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                              onPressed: caixaId == null
                                  ? null
                                  : () {
                                      final q = int.tryParse(quantidade.text);
                                      if (q == null || q < 1) return;
                                      setLocal(() => itens.add(
                                          {'caixa': caixas.firstWhere((c) => c.id == caixaId), 'quantidade': q}));
                                    },
                              icon: const Icon(Icons.add_shopping_cart),
                              label: const Text('Adicionar item')),
                          const Divider(height: 28),
                          ...itens.asMap().entries.map((e) {
                            final caixa = e.value['caixa'] as Caixa;
                            return ListTile(
                                dense: true,
                                title: Text('${caixa.marca.nome} ${caixa.capacidadeLitros}L • ${caixa.cor}'),
                                subtitle: Text('Quantidade: ${e.value['quantidade']}'),
                                trailing: IconButton(
                                    icon: const Icon(Icons.close), onPressed: () => setLocal(() => itens.removeAt(e.key))));
                          }),
                        ]))),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                      FilledButton(
                          onPressed: itens.isEmpty
                              ? null
                              : () async {
                                  final data = _lerData(dataInstalacao.text);
                                  if (dataInstalacao.text.trim().isNotEmpty && data == null) {
                                    mostrarMensagem(context, 'Informe a data como dd/mm/aaaa.', erro: true);
                                    return;
                                  }
                                  // A API recebe a mesma caixa uma vez para cada unidade vendida.
                                  final caixasVendidas = <Caixa>[];
                                  for (final item in itens) {
                                    for (var i = 0; i < (item['quantidade'] as int); i++) {
                                      caixasVendidas.add(item['caixa'] as Caixa);
                                    }
                                  }
                                  try {
                                    await _api.criarVenda(
                                        cliente: clientes.firstWhere((c) => c.id == clienteId),
                                        vendedor: vendedores.firstWhere((f) => f.id == vendedorId),
                                        instalador: instaladorId == null
                                            ? null
                                            : instaladores.firstWhere((f) => f.id == instaladorId),
                                        caixas: caixasVendidas,
                                        dataInstalacao: data);
                                    if (context.mounted) Navigator.pop(context, true);
                                  } catch (e) {
                                    if (context.mounted) mostrarMensagem(context, e.toString(), erro: true);
                                  }
                                },
                          child: const Text('Concluir venda'))
                    ],
                  )));
      if (criada == true) {
        await _carregar();
        if (mounted) mostrarMensagem(context, 'Venda registrada com sucesso.');
      }
    } catch (e) {
      if (mounted) mostrarMensagem(context, e.toString(), erro: true);
    }
  }

  // Define ou troca o instalador e a data da instalação (PUT /venda/atualizar).
  Future<void> _definirInstalacao(Venda venda) async {
    try {
      final funcionarios = await _api.listarFuncionarios();
      final instaladores = funcionarios.where((f) => f.ativo && f.cargo == 'INSTALADOR').toList();
      if (!mounted) return;
      if (instaladores.isEmpty) {
        mostrarMensagem(context, 'Cadastre um funcionário com cargo INSTALADOR.', erro: true);
        return;
      }

      final key = GlobalKey<FormState>();
      int? instaladorId = instaladores.any((f) => f.id == venda.instalador?.id)
          ? venda.instalador!.id
          : instaladores.first.id;
      final dataInstalacao =
          TextEditingController(text: venda.dataInstalacao == null ? '' : _data.format(venda.dataInstalacao!));

      final salvo = await showDialog<bool>(
          context: context,
          builder: (context) => StatefulBuilder(
              builder: (context, setLocal) => AlertDialog(
                    title: Text('Instalação da venda #${venda.id}'),
                    content: SizedBox(
                        width: 400,
                        child: Form(
                            key: key,
                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                              DropdownButtonFormField<int>(
                                  initialValue: instaladorId,
                                  decoration: const InputDecoration(labelText: 'Instalador'),
                                  items: instaladores
                                      .map((f) => DropdownMenuItem(value: f.id, child: Text(f.nome)))
                                      .toList(),
                                  onChanged: (v) => setLocal(() => instaladorId = v)),
                              const SizedBox(height: 12),
                              TextFormField(
                                  controller: dataInstalacao,
                                  decoration: const InputDecoration(labelText: 'Data da instalação (dd/mm/aaaa)'),
                                  validator: (v) =>
                                      _lerData(v ?? '') == null ? 'Informe a data como dd/mm/aaaa.' : null),
                            ]))),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                      FilledButton(
                          onPressed: () async {
                            if (!key.currentState!.validate()) return;
                            try {
                              await _api.atualizarVenda(Venda(
                                  id: venda.id,
                                  dataVenda: venda.dataVenda,
                                  cliente: venda.cliente,
                                  vendedor: venda.vendedor,
                                  instalador: instaladores.firstWhere((f) => f.id == instaladorId),
                                  caixas: venda.caixas,
                                  valorTotal: venda.valorTotal,
                                  dataInstalacao: _lerData(dataInstalacao.text)));
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
        if (mounted) mostrarMensagem(context, 'Instalação definida.');
      }
    } catch (e) {
      if (mounted) mostrarMensagem(context, e.toString(), erro: true);
    }
  }

  // Excluir a venda devolve as caixas ao estoque.
  Future<void> _excluir(Venda venda) async {
    if (!await confirmarExclusao(context, 'venda #${venda.id}')) return;
    try {
      await _api.excluirVenda(venda.id);
      await _carregar();
      if (mounted) mostrarMensagem(context, 'Venda excluída e estoque devolvido.');
    } catch (e) {
      if (mounted) mostrarMensagem(context, e.toString(), erro: true);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: _carregando
            ? const LoadingView()
            : _vendas.isEmpty
                ? const EmptyView('Nenhuma venda registrada.')
                : RefreshIndicator(
                    onRefresh: _carregar,
                    child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _vendas.length,
                        itemBuilder: (_, i) {
                          final v = _vendas[i];
                          final semInstalador = v.instalador == null;
                          return Card(
                              child: ExpansionTile(
                            leading: CircleAvatar(child: Text('#${v.id}')),
                            title: Text(v.cliente.nome),
                            subtitle: Text('${_data.format(v.dataVenda)} • ${_moeda.format(v.valorTotal)}'),
                            trailing: Chip(
                                label: Text(semInstalador
                                    ? 'Instalação a definir'
                                    : 'Instalação ${v.dataInstalacao == null ? '' : _data.format(v.dataInstalacao!)}'),
                                backgroundColor: semInstalador ? Colors.orange.shade100 : Colors.green.shade100),
                            children: [
                              ListTile(
                                  dense: true,
                                  title: Text('Vendedor: ${v.vendedor.nome}'),
                                  subtitle: Text('Instalador: ${v.instalador?.nome ?? 'a definir'}')),
                              ..._quantidades(v.caixas).entries.map((e) {
                                final caixa = v.caixas.firstWhere((c) => c.id == e.key);
                                return ListTile(
                                    dense: true,
                                    title: Text('${caixa.marca.nome} ${caixa.capacidadeLitros}L • ${caixa.cor}'),
                                    subtitle: Text('${e.value} × ${_moeda.format(caixa.preco)}'),
                                    trailing: Text(_moeda.format(caixa.preco * e.value)));
                              }),
                              Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                    OutlinedButton.icon(
                                        onPressed: () => _definirInstalacao(v),
                                        icon: const Icon(Icons.handyman),
                                        label: const Text('Definir instalação')),
                                    const SizedBox(width: 8),
                                    OutlinedButton.icon(
                                        onPressed: () => _excluir(v),
                                        icon: const Icon(Icons.delete_outline),
                                        label: const Text('Excluir venda')),
                                  ])),
                            ],
                          ));
                        })),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: _novaVenda, icon: const Icon(Icons.add), label: const Text('Nova venda')),
      );
}
