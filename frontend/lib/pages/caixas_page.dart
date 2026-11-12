import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/caixa.dart';
import '../models/marca.dart';
import '../services/api_service.dart';
import '../widgets/ui_helpers.dart';

class CaixasPage extends StatefulWidget {
  const CaixasPage({super.key});
  @override
  State<CaixasPage> createState() => _CaixasPageState();
}

class _CaixasPageState extends State<CaixasPage> {
  final _api = ApiService();
  final _moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final _busca = TextEditingController();
  List<Caixa> _itens = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      //se tiver texto busca pela marca
      final marca = _busca.text.trim();
      _itens = marca.isEmpty ? await _api.listarCaixas() : await _api.buscarCaixasPorMarca(marca);
    } catch (e) {
      if (mounted) mostrarMensagem(context, e.toString(), erro: true);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  String? _numeroPositivo(String? v) {
    final n = double.tryParse((v ?? '').replaceAll(',', '.'));
    return n == null || n < 0 ? 'Informe um valor válido.' : null;
  }

  String? _inteiroNaoNegativo(String? v) {
    final n = int.tryParse(v ?? '');
    return n == null || n < 0 ? 'Informe um número inteiro válido.' : null;
  }

  //sem caixa cadastra, com caixa edita
  Future<void> _formulario([Caixa? caixa]) async {
    //marcas pro combo
    List<Marca> marcas;
    try {
      marcas = await _api.listarMarcas();
    } catch (e) {
      if (mounted) mostrarMensagem(context, e.toString(), erro: true);
      return;
    }
    if (!mounted) return;
    if (marcas.isEmpty) {
      mostrarMensagem(context, 'Cadastre uma marca antes de cadastrar a caixa.', erro: true);
      return;
    }

    final key = GlobalKey<FormState>();
    final capacidade = TextEditingController(text: caixa?.capacidadeLitros.toString());
    final altura = TextEditingController(text: caixa?.altura.toStringAsFixed(2).replaceAll('.', ','));
    final largura = TextEditingController(text: caixa?.largura.toStringAsFixed(2).replaceAll('.', ','));
    final preco = TextEditingController(text: caixa?.preco.toStringAsFixed(2).replaceAll('.', ','));
    final estoque = TextEditingController(text: caixa?.estoque.toString() ?? '0');
    int? marcaId = caixa?.marca.id ?? marcas.first.id;
    String cor = caixa?.cor ?? cores.first;
    String material = caixa?.material ?? materiais.first;
    String formato = caixa?.formato ?? formatos.first;

    final salvo = await showDialog<bool>(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, setLocal) => AlertDialog(
                  title: Text(caixa == null ? 'Nova caixa d\'água' : 'Editar caixa d\'água'),
                  content: SizedBox(
                      width: 500,
                      child: Form(
                          key: key,
                          child: SingleChildScrollView(
                              child: Column(mainAxisSize: MainAxisSize.min, children: [
                            DropdownButtonFormField<int>(
                                initialValue: marcaId,
                                decoration: const InputDecoration(labelText: 'Marca'),
                                items: marcas.map((m) => DropdownMenuItem(value: m.id, child: Text(m.nome))).toList(),
                                onChanged: (v) => setLocal(() => marcaId = v)),
                            const SizedBox(height: 12),
                            TextFormField(
                                controller: capacidade,
                                decoration: const InputDecoration(labelText: 'Capacidade (litros)'),
                                keyboardType: TextInputType.number,
                                validator: _inteiroNaoNegativo),
                            const SizedBox(height: 12),
                            TextFormField(
                                controller: altura,
                                decoration: const InputDecoration(labelText: 'Altura (m)'),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: _numeroPositivo),
                            const SizedBox(height: 12),
                            TextFormField(
                                controller: largura,
                                decoration: const InputDecoration(labelText: 'Largura ou diâmetro (m)'),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: _numeroPositivo),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                                initialValue: formato,
                                decoration: const InputDecoration(labelText: 'Formato'),
                                items: formatos.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                                onChanged: (v) => setLocal(() => formato = v!)),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                                initialValue: cor,
                                decoration: const InputDecoration(labelText: 'Cor'),
                                items: cores.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                onChanged: (v) => setLocal(() => cor = v!)),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                                initialValue: material,
                                decoration: const InputDecoration(labelText: 'Material'),
                                items: materiais.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                                onChanged: (v) => setLocal(() => material = v!)),
                            const SizedBox(height: 12),
                            TextFormField(
                                controller: preco,
                                decoration: const InputDecoration(labelText: 'Preço'),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: _numeroPositivo),
                            const SizedBox(height: 12),
                            TextFormField(
                                controller: estoque,
                                decoration: const InputDecoration(labelText: 'Estoque'),
                                keyboardType: TextInputType.number,
                                validator: _inteiroNaoNegativo),
                          ])))),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                    FilledButton(
                        onPressed: () async {
                          if (!key.currentState!.validate()) return;
                          try {
                            await _api.salvarCaixa(Caixa(
                                id: caixa?.id,
                                marca: marcas.firstWhere((m) => m.id == marcaId),
                                capacidadeLitros: int.parse(capacidade.text),
                                altura: double.parse(altura.text.replaceAll(',', '.')),
                                largura: double.parse(largura.text.replaceAll(',', '.')),
                                cor: cor,
                                material: material,
                                formato: formato,
                                preco: double.parse(preco.text.replaceAll(',', '.')),
                                estoque: int.parse(estoque.text)));
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
      if (mounted) mostrarMensagem(context, 'Caixa d\'água salva.');
    }
  }

  Future<void> _excluir(Caixa c) async {
    if (!await confirmarExclusao(context, '${c.marca.nome} ${c.capacidadeLitros}L')) return;
    try {
      await _api.excluirCaixa(c.id!);
      await _carregar();
    } catch (e) {
      if (mounted) mostrarMensagem(context, e.toString(), erro: true);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: TextField(
                  controller: _busca,
                  decoration: InputDecoration(
                      labelText: 'Buscar por marca',
                      suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: _carregar)),
                  onSubmitted: (_) => _carregar())),
          Expanded(child: _lista()),
        ]),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _formulario(), icon: const Icon(Icons.add), label: const Text('Nova caixa')),
      );

  Widget _lista() => _carregando
      ? const LoadingView()
      : _itens.isEmpty
          ? const EmptyView('Nenhuma caixa d\'água encontrada.')
          : RefreshIndicator(
              onRefresh: _carregar,
              child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _itens.length,
                        itemBuilder: (_, i) {
                          final c = _itens[i];
                          return Card(
                              child: ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.water_drop)),
                            title: Text('${c.marca.nome} ${c.capacidadeLitros}L'),
                            subtitle: Text('${c.formato} • ${c.cor} • ${c.material}\n'
                                '${_moeda.format(c.preco)} • Estoque: ${c.estoque}'),
                            isThreeLine: true,
                            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                              IconButton(onPressed: () => _formulario(c), icon: const Icon(Icons.edit)),
                              IconButton(onPressed: () => _excluir(c), icon: const Icon(Icons.delete_outline))
                            ]),
                          ));
                        }));
}
