import 'package:flutter/material.dart';
import 'caixas_page.dart';
import 'clientes_page.dart';
import 'funcionarios_page.dart';
import 'marcas_page.dart';
import 'vendas_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _indice = 0;
  final _paginas = const [ClientesPage(), FuncionariosPage(), MarcasPage(), CaixasPage(), VendasPage()];
  final _titulos = const ['Clientes', 'Funcionários', 'Marcas', 'Caixas d\'água', 'Vendas'];
  final _destinos = const [
    NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Clientes'),
    NavigationDestination(icon: Icon(Icons.badge_outlined), selectedIcon: Icon(Icons.badge), label: 'Funcionários'),
    NavigationDestination(icon: Icon(Icons.label_outline), selectedIcon: Icon(Icons.label), label: 'Marcas'),
    NavigationDestination(
        icon: Icon(Icons.water_drop_outlined), selectedIcon: Icon(Icons.water_drop), label: 'Caixas'),
    NavigationDestination(
        icon: Icon(Icons.point_of_sale_outlined), selectedIcon: Icon(Icons.point_of_sale), label: 'Vendas'),
  ];

  @override
  Widget build(BuildContext context) {
    final largura = MediaQuery.sizeOf(context).width;
    final desktop = largura >= 800;
    return Scaffold(
      appBar: AppBar(title: Text('Caixas d\'Água • ${_titulos[_indice]}')),
      body: Row(children: [
        if (desktop)
          NavigationRail(
            selectedIndex: _indice,
            onDestinationSelected: (valor) => setState(() => _indice = valor),
            labelType: NavigationRailLabelType.all,
            destinations: _destinos
                .map((d) =>
                    NavigationRailDestination(icon: d.icon, selectedIcon: d.selectedIcon, label: Text(d.label)))
                .toList(),
          ),
        Expanded(child: IndexedStack(index: _indice, children: _paginas)),
      ]),
      bottomNavigationBar: desktop
          ? null
          : NavigationBar(
              selectedIndex: _indice,
              onDestinationSelected: (valor) => setState(() => _indice = valor),
              destinations: _destinos),
    );
  }
}
