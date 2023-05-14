import 'package:flutter/material.dart';
import 'package:paqueteria_barranco/models/empleado.dart';
import 'package:paqueteria_barranco/models/ruta.dart';
import 'package:paqueteria_barranco/models/vehiculo.dart';
import 'package:paqueteria_barranco/models/viaje.dart';
import 'package:paqueteria_barranco/provider/cars_provider.dart';
import 'package:paqueteria_barranco/provider/empleado_provider.dart';
import 'package:paqueteria_barranco/provider/rutas_provider.dart';
import 'package:paqueteria_barranco/provider/viajes_provider.dart';

import 'package:paqueteria_barranco/utilities/forms_utils.dart';
import 'package:paqueteria_barranco/utilities/formulario_template.dart';
import 'package:paqueteria_barranco/utilities/show_dialog.dart';
import 'package:paqueteria_barranco/utilities/show_snackbar.dart';
import 'package:paqueteria_barranco/utilities/validate_extensions.dart';
import 'package:paqueteria_barranco/widget/page_loading_absorb_pointer.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class ViajesPage extends StatefulWidget {
  const ViajesPage({super.key});

  @override
  State<ViajesPage> createState() => _ViajesPageState();
}

class _ViajesPageState extends State<ViajesPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<ViajesProvider>().getAll();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viajes pendientes'),
      ),
      body: Selector<ViajesProvider, Tuple2<bool, List<Viaje>>>(
        selector: (_, provider) => Tuple2(provider.loading, provider.viajes),
        shouldRebuild: (_, __) => true,
        builder: (_, values, __) {
          final loading = values.item1;
          final viajes = values.item2;
          return PageLoadingAbsorbPointer(
            isLoading: loading,
            child: Column(
              children: [
                if (viajes.isEmpty)
                  IconButton(
                    onPressed: () => context.read<ViajesProvider>().populate(),
                    icon: const Icon(
                      Icons.replay,
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: viajes.length,
                    itemBuilder: (_, int i) {
                      final viaje = viajes[i];
                      return _buildCard(viaje);
                    },
                  ),
                )
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ShowDialog.showSimpleRightDialog(
          context,
          child: const FormViajeWidget(),
        ),
        tooltip: 'Agregar',
        child: const Icon(Icons.add),
      ), // This
    );
  }

  Widget _buildCard(Viaje viaje) {
    return Card(
      child: ListTile(
        // onTap: () => ShowDialog.showSimpleRightDialog(
        //   context,
        //   child: FormViajeWidget(
        //     vehiculo: vehiculo,
        //   ),
        // ),
        leading: const Icon(Icons.local_shipping, size: 30),
        title: Text(viaje.marca ?? '-'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(viaje.modelo ?? '-'),
            if (viaje.ruta != null && viaje.ruta!.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Direcciones:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ...viaje.ruta!.map((e) => Text(e.nombre!)).toList()
            ],
          ],
        ),
        trailing: Text('Paquetes: ${viaje.paquete?.length ?? '0'}'),
      ),
    );
  }
}

class FormViajeWidget extends StatefulWidget {
  const FormViajeWidget({
    super.key,
  });

  @override
  State<FormViajeWidget> createState() => _FormViajeWidgetState();
}

class _FormViajeWidgetState extends State<FormViajeWidget> {
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> _loading = ValueNotifier<bool>(false);

  ScrollController scrollController = ScrollController();

  late bool edit;
  Map<String, dynamic> data = {};
  TimeOfDay? time;

  Vehiculo? vehiculoSelected;
  List<Ruta> rutasSelected = [];
  Empleado? empleadoSelected;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _loading,
      builder: (__, bool loading, _) {
        return FormTemplate(
          scrollController: scrollController,
          loading: loading,
          titulo: "Nuevo viajes",
          onPressSave: _onPressSave,
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                Selector<CarsProvider, List<Vehiculo>>(
                  selector: (_, pro) => pro.vehiculosNoOcupados,
                  builder: (_, vehiculos, __) {
                    return Forms.dropdown(
                      context,
                      labelText: "Vehiculo",
                      value: vehiculoSelected,
                      items: vehiculos
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.modelo!),
                              ))
                          .toList(),
                      onChanged: (value) {
                        vehiculoSelected = value;
                      },
                      validators: (value) {
                        if (vehiculoSelected == null) return 'Requerido';
                        return null;
                      },
                      isRequired: true,
                    );
                  },
                ),
                Selector<RutasProvider, List<Ruta>>(
                  selector: (_, pro) => pro.rutas,
                  builder: (_, rutas, __) {
                    return Forms.dropdown<Ruta>(
                      context,
                      labelText: "Rutas",
                      value: null,
                      items: rutas
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.nombre!),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (rutasSelected
                            .any((element) => element.id == value?.id)) {
                          return;
                        }
                        rutasSelected.add(value!);
                        setState(() {});
                      },
                      validators: (value) {
                        if (rutasSelected.isEmpty) {
                          return 'No has agregado direcciones';
                        }
                        return null;
                      },
                      isRequired: true,
                    );
                  },
                ),
                if (rutasSelected.isNotEmpty)
                  ...rutasSelected
                      .map((e) => ListTile(
                            title: Text(e.nombre!),
                            trailing: IconButton(
                                onPressed: () {
                                  rutasSelected.removeWhere(
                                      (element) => element.id == e.id);
                                  setState(() {});
                                },
                                icon: const Icon(Icons.delete)),
                          ))
                      .toList(),
                const SizedBox(height: 5),
                Selector<EmpleadoProvider, List<Empleado>>(
                  selector: (_, pro) => pro.empleados,
                  builder: (_, rutas, __) {
                    return Forms.dropdown<Empleado>(
                      context,
                      labelText: "Empleado",
                      value: empleadoSelected,
                      items: rutas
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.nombre!),
                              ))
                          .toList(),
                      onChanged: (value) {
                        empleadoSelected = value;
                        setState(() {});
                      },
                      validators: (value) {
                        if (empleadoSelected == null) return 'Requerido';
                        return null;
                      },
                      isRequired: true,
                    );
                  },
                ),
                Forms.textField(
                  hintText: "",
                  labelText: "Modelo",
                  initialValue: data['modelo'],
                  onChanged: (value) => data['modelo'] = value,
                  validators: (value) => value!.validatorLeesThan50,
                  isRequired: true,
                ),
                const SizedBox(height: 5),
                Forms.textField(
                  hintText: "",
                  labelText: "Capacidad de carga",
                  initialValue: data['cap_carga'],
                  onChanged: (value) => data['cap_carga'] = value,
                  validators: (value) => value!.validatorLeesThan50,
                  isRequired: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future _onPressSave() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() != true) return;

    bool response200 = false;
    _loading.value = true;

    response200 = await context.read<ViajesProvider>().agregar(
          data: data,
          onError: () => ShowSnackBar.showError(context),
        );

    _loading.value = false;

    if (!mounted || !response200) return;
    Navigator.pop(context);
    ShowSnackBar.showSuccessful(context);
  }
}
