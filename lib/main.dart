import 'package:flutter/material.dart';
import 'package:paqueteria_barranco/pages/home_page.dart';
import 'package:paqueteria_barranco/provider/cars_provider.dart';
import 'package:paqueteria_barranco/provider/empleado_provider.dart';
import 'package:paqueteria_barranco/provider/rutas_provider.dart';
import 'package:paqueteria_barranco/services/add_addresses_service.dart';
import 'package:paqueteria_barranco/services/db_connection.dart';
import 'package:postgres/postgres.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DbConnectionService(),
      child: Consumer<DbConnectionService>(
          builder: (_, dbConnectionService, child) {
        final PostgreSQLConnection connection =
            dbConnectionService.postgreSQLConnection;
        bool loading = dbConnectionService.loading;

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (BuildContext context) => RutasProvider(connection),
            ),
            ChangeNotifierProvider(
              create: (BuildContext context) => CarsProvider(connection),
            ),
            ChangeNotifierProvider(
              create: (BuildContext context) => EmpleadoProvider(connection),
            ),
            ChangeNotifierProvider(
              create: (BuildContext context) => AddAddressesService(connection),
            ),
          ],
          child: MaterialApp(
            title: 'Flutter Demo',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blueGrey,
            ),
            home: loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : const HomePage(),
          ),
        );
      }),
    );
  }
}
