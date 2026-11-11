import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/caixa.dart';
import '../models/cliente.dart';
import '../models/funcionario.dart';
import '../models/marca.dart';
import '../models/venda.dart';

class ApiException implements Exception {
  final String mensagem;
  const ApiException(this.mensagem);
  @override
  String toString() => mensagem;
}

class ApiService {
  final http.Client _client;
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static const _headers = {'Content-Type': 'application/json; charset=UTF-8'};

  // Interpreta a resposta e transforma erros HTTP em mensagens úteis para a tela.
  // Nossa API devolve JSON nas listas e texto nas mensagens (ex.: "Marca FORTLEV já cadastrada").
  dynamic _processar(http.Response response) {
    final texto = utf8.decode(response.bodyBytes);
    dynamic body;
    try {
      body = texto.isEmpty ? null : jsonDecode(texto);
    } catch (e) {
      body = texto;
    }
    if (response.statusCode >= 200 && response.statusCode < 300) return body;
    final mensagem = body is Map ? body['message'] ?? body['error'] : body;
    throw ApiException(mensagem == null || mensagem.toString().isEmpty
        ? 'Erro HTTP ${response.statusCode}.'
        : mensagem.toString());
  }

  // ---------- Clientes ----------
  Future<List<Cliente>> listarClientes() async {
    final response = await _client.get(Uri.parse('${ApiConfig.baseUrl}/cliente/listar'));
    return (_processar(response) as List).map((e) => Cliente.fromJson(e)).toList();
  }

  Future<void> salvarCliente(Cliente cliente) async {
    _processar(await _client.post(Uri.parse('${ApiConfig.baseUrl}/cliente/salvar'),
        headers: _headers, body: jsonEncode(cliente.toJson())));
  }

  Future<void> excluirCliente(int id) async {
    _processar(await _client.delete(Uri.parse('${ApiConfig.baseUrl}/cliente/excluir/$id')));
  }

  // ---------- Funcionários ----------
  Future<List<Funcionario>> listarFuncionarios() async {
    final response = await _client.get(Uri.parse('${ApiConfig.baseUrl}/funcionario/listar'));
    return (_processar(response) as List).map((e) => Funcionario.fromJson(e)).toList();
  }

  Future<void> salvarFuncionario(Funcionario funcionario) async {
    _processar(await _client.post(Uri.parse('${ApiConfig.baseUrl}/funcionario/salvar'),
        headers: _headers, body: jsonEncode(funcionario.toJson())));
  }

  Future<void> excluirFuncionario(int id) async {
    _processar(await _client.delete(Uri.parse('${ApiConfig.baseUrl}/funcionario/excluir/$id')));
  }

  // ---------- Marcas ----------
  Future<List<Marca>> listarMarcas() async {
    final response = await _client.get(Uri.parse('${ApiConfig.baseUrl}/marca/listar'));
    return (_processar(response) as List).map((e) => Marca.fromJson(e)).toList();
  }

  // Sem id cadastra (POST); com id atualiza (PUT).
  Future<void> salvarMarca(Marca marca) async {
    final response = marca.id == null
        ? await _client.post(Uri.parse('${ApiConfig.baseUrl}/marca/salvar'),
            headers: _headers, body: jsonEncode(marca.toJson()))
        : await _client.put(Uri.parse('${ApiConfig.baseUrl}/marca/atualizar/${marca.id}'),
            headers: _headers, body: jsonEncode(marca.toJson()));
    _processar(response);
  }

  Future<void> excluirMarca(int id) async {
    _processar(await _client.delete(Uri.parse('${ApiConfig.baseUrl}/marca/excluir/$id')));
  }

  // ---------- Caixas d'água ----------
  Future<List<Caixa>> listarCaixas() async {
    final response = await _client.get(Uri.parse('${ApiConfig.baseUrl}/listar'));
    return (_processar(response) as List).map((e) => Caixa.fromJson(e)).toList();
  }

  // Busca as caixas cuja marca contém o texto informado.
  Future<List<Caixa>> buscarCaixasPorMarca(String marca) async {
    final response = await _client.get(Uri.parse('${ApiConfig.baseUrl}/marcas/${Uri.encodeComponent(marca)}'));
    return (_processar(response) as List).map((e) => Caixa.fromJson(e)).toList();
  }

  // Sem id cadastra (POST); com id atualiza (PUT).
  Future<void> salvarCaixa(Caixa caixa) async {
    final response = caixa.id == null
        ? await _client.post(Uri.parse('${ApiConfig.baseUrl}/salvar'),
            headers: _headers, body: jsonEncode(caixa.toJson()))
        : await _client.put(Uri.parse('${ApiConfig.baseUrl}/atualizar/${caixa.id}'),
            headers: _headers, body: jsonEncode(caixa.toJson()));
    _processar(response);
  }

  Future<void> excluirCaixa(int id) async {
    _processar(await _client.delete(Uri.parse('${ApiConfig.baseUrl}/excluir/$id')));
  }

  // ---------- Vendas ----------
  Future<List<Venda>> listarVendas() async {
    final response = await _client.get(Uri.parse('${ApiConfig.baseUrl}/venda/listar'));
    return (_processar(response) as List).map((e) => Venda.fromJson(e)).toList();
  }

  // O front não envia preço nem total: a API confere o estoque, soma o total e baixa o estoque.
  // Para vender 2 unidades da mesma caixa, ela aparece 2 vezes na lista.
  Future<void> criarVenda({
    required Cliente cliente,
    required Funcionario vendedor,
    Funcionario? instalador,
    required List<Caixa> caixas,
    DateTime? dataInstalacao,
  }) async {
    final response = await _client.post(Uri.parse('${ApiConfig.baseUrl}/venda/salvar'),
        headers: _headers,
        body: jsonEncode({
          'cliente': cliente.toJson(),
          'vendedor': vendedor.toJson(),
          if (instalador != null) 'instalador': instalador.toJson(),
          'caixas': caixas.map((c) => c.toJson()).toList(),
          if (dataInstalacao != null) 'dataInstalacao': dataInstalacao.toIso8601String().substring(0, 10),
        }));
    _processar(response);
  }

  // A API só altera o instalador e a data da instalação.
  Future<void> atualizarVenda(Venda venda) async {
    _processar(await _client.put(Uri.parse('${ApiConfig.baseUrl}/venda/atualizar/${venda.id}'),
        headers: _headers, body: jsonEncode(venda.toJson())));
  }

  // Excluir a venda devolve as caixas ao estoque.
  Future<void> excluirVenda(int id) async {
    _processar(await _client.delete(Uri.parse('${ApiConfig.baseUrl}/venda/excluir/$id')));
  }
}
