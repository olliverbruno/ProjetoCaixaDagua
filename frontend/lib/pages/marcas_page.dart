import 'package:flutter/material.dart';
import '../models/marca.dart';
import '../services/api_service.dart';
import '../widgets/ui_helpers.dart';

class MarcasPage extends StatefulWidget {
  const MarcasPage({super.key});
  @override
  State<MarcasPage> createState() => _MarcasPageState();
}

class _MarcasPageState extends State<MarcasPage> {
  final _api = ApiService();
  List<Marca> _marcas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      _marcas = await _api.listarMarcas();
    } catch (e) {
      if (mounted) mostrarMensagem(context, e.toString(), erro: true);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  // Sem marca abre para cadastrar (POST); com marca abre para editar (PUT).
  // O back-end grava o nome em maiúsculas e não aceita marca repetida.
  Future<void> _abrirFormulario([Marca? marca]) async {
    final formKey = GlobalKey<FormState>();
    final nome = TextEditingController(text: marca?.nome);

    final salvo = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(marca == null ? 'Nova marca' : 'Editar marca'),
              content: SizedBox(
                  width: 400,
                  child: Form(
                      key: formKey,
                      child: TextFormField(
                          controller: nome,
                          decoration: const InputDecoration(labelText: 'Nome'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Informe o nome.' : null))),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                FilledButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      try {
                        await _api.salvarMarca(Marca(id: marca?.id, nome: nome.text.trim()));
                        if (context.mounted) Navigator.pop(context, true);
                      } catch (e) {
                        if (context.mounted) mostrarMensagem(context, e.toString(), erro: true);
                      }
                    },
                    child: const Text('Salvar'))
              ],
            ));
    if (salvo == true) {
      await _carregar();
      if (mounted) mostrarMensagem(context, 'Marca salva com sucesso.');
    }
  }

  // Se a marca estiver em uso, a API devolve a mensagem explicando quantas caixas usam a marca.
  Future<void> _excluir(Marca marca) async {
    if (!await confirmarExclusao(context, marca.nome)) return;
    try {
      await _api.excluirMarca(marca.id!);
      await _carregar();
      if (mounted) mostrarMensagem(context, 'Marca excluída.');
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
                child: _marcas.isEmpty
                    ? const EmptyView('Nenhuma marca cadastrada.')
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _marcas.length,
                        itemBuilder: (_, i) {
                          final m = _marcas[i];
                          return Card(
                              child: ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.label)),
                            title: Text(m.nome),
                            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                              IconButton(onPressed: () => _abrirFormulario(m), icon: const Icon(Icons.edit)),
                              IconButton(onPressed: () => _excluir(m), icon: const Icon(Icons.delete_outline))
                            ]),
                          ));
                        },
                      ),
              ),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _abrirFormulario(), icon: const Icon(Icons.add), label: const Text('Nova marca')),
      );
}
