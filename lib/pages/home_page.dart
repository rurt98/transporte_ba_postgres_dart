import 'package:flutter/material.dart';
import 'package:paqueteria_barranco/pages/cars_page.dart';
import 'package:paqueteria_barranco/pages/clientes_screen.dart';
import 'package:paqueteria_barranco/pages/empleados_screen.dart';
import 'package:paqueteria_barranco/pages/rutas_page.dart';
import 'package:paqueteria_barranco/pages/viajes_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Image.asset(
            'assets/img/camion.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  _buildCard(
                    txt: 'Rutas',
                    subtitle: 'Rutas registradas',
                    icon: Icons.location_on,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RutasPages(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCard(
                    txt: 'Vehículos',
                    subtitle: 'Vehículos registrados',
                    icon: Icons.local_shipping,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CarsPage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCard(
                    txt: 'Empleados',
                    subtitle: 'Empleados registrados',
                    icon: Icons.engineering,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EmpleadosScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCard(
                    txt: 'Clientes',
                    subtitle: 'Clientes registrados',
                    icon: Icons.groups,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ClientesScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCard(
                    txt: 'Viajes',
                    subtitle: 'Viajes registrados',
                    icon: Icons.send,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ViajesPage(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String txt,
    required IconData icon,
    required String subtitle,
    required Function() onTap,
  }) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          size: 40,
        ),
        title: Text(txt),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
