import 'package:flutter/material.dart';
import 'package:paqueteria_barranco/models/address.dart';
import 'package:paqueteria_barranco/models/cliente.dart';
import 'package:paqueteria_barranco/models/empleado.dart';
import 'package:paqueteria_barranco/models/ruta.dart';
import 'package:paqueteria_barranco/models/vehiculo.dart';
import 'package:paqueteria_barranco/models/viaje.dart';
import 'package:paqueteria_barranco/provider/cars_provider.dart';
import 'package:paqueteria_barranco/provider/clientes_provider.dart';
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
import 'package:uuid/uuid.dart';

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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Paquetes:"),
                    ElevatedButton.icon(
                      onPressed:
                          rutasSelected.isEmpty || vehiculoSelected == null
                              ? null
                              : () {
                                  if (data['paquetes'] == null) {
                                    data['paquetes'] = [
                                      {
                                        "uuid": const Uuid().v4(),
                                        "id_vehiculo": vehiculoSelected!.id
                                      }
                                    ];
                                  } else {
                                    data['paquetes'].add({
                                      "uuid": const Uuid().v4(),
                                      "id_vehiculo": vehiculoSelected!.id
                                    });
                                  }
                                  setState(() {});
                                },
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar'),
                    ),
                  ],
                ),
                if (rutasSelected.isEmpty || vehiculoSelected == null)
                  const Text(
                    "Se necesita seleccionar Rutas y Vehiculo",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                if (data['paquetes'] != null &&
                    (data['paquetes'] as List).isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: (data['paquetes'] as List).length,
                    itemBuilder: (_, int i) {
                      return _paquetesForma(
                        (data['paquetes'] as List)[i],
                        i,
                        ValueKey((data['paquetes'] as List)[i]['uuid']),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _paquetesForma(
    Map<String, dynamic> body,
    int index,
    Key key,
  ) {
    List<Address> address = [];
    for (var ruta in rutasSelected) {
      address.addAll(ruta.direcciones!);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      key: key,
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              'Paquete ${index + 1}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            IconButton(
              onPressed: () {
                (data['paquetes'] as List).removeAt(index);
                setState(() {});
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Forms.textField(
          hintText: "",
          labelText: "Descripción",
          initialValue: body['descripcion'],
          onChanged: (value) => body['descripcion'] = value,
          validators: (value) => value!.validatorLeesThan50,
          isRequired: true,
        ),
        const SizedBox(height: 5),
        Forms.textField(
          hintText: "",
          labelText: "Peso",
          onChanged: (value) => body['peso'] = int.tryParse(value),
          validators: (value) => value!.validatorLeesThan50,
          isRequired: true,
        ),
        const SizedBox(height: 5),
        Forms.textField(
          hintText: "",
          labelText: "Tamaño",
          onChanged: (value) => body['tamanio'] = int.tryParse(value),
          validators: (value) => value!.validatorLeesThan50,
          isRequired: true,
        ),
        const SizedBox(height: 5),
        Forms.datePicker(
          context,
          initialDate: body['f_ent_est'] != null
              ? DateTime.parse(body['f_ent_est'])
              : null,
          labelText: "Estimación de fecha de entrega",
          dateChanged: (value) => body['f_ent_est'] = value.toString(),
          isRequired: true,
        ),
        Forms.datePicker(
          context,
          initialDate:
              body['f_envio'] != null ? DateTime.parse(body['f_envio']) : null,
          labelText: "Fecha de envió",
          dateChanged: (value) => body['f_envio'] = value.toString(),
          isRequired: true,
        ),
        const SizedBox(height: 5),
        Selector<ClientesProvider, List<Cliente>>(
          selector: (_, pro) => pro.clientes,
          builder: (_, clientes, __) {
            return Forms.dropdown<Cliente>(
              context,
              labelText: "Cliente",
              value: null,
              items: clientes
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.nombre!),
                      ))
                  .toList(),
              onChanged: (value) {
                body['id_cliente'] = value?.id.toString();
              },
              validators: (value) {
                if (body['id_cliente'] == null) return 'Requerido';
                return null;
              },
              isRequired: true,
            );
          },
        ),
        const SizedBox(height: 15),
        Forms.dropdown<Address>(
          context,
          labelText: "Direccion",
          value: null,
          items: address
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(e.toString()),
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            body['id_direccion'] = value?.id.toString();
          },
          validators: (value) {
            if (body['id_direccion'] == null) return 'Requerido';
            return null;
          },
          isRequired: true,
        )
      ],
    );
  }

  Future _onPressSave() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() != true) return;

    _formKey.currentState?.save();

    data["car_viaja"] = [];

    for (var ruta in rutasSelected) {
      data["car_viaja"].add({
        "id_ruta": ruta.id,
        "id_vehiculo": vehiculoSelected!.id,
      });
    }

    for (var element in data["paquetes"]) {
      element["id_cliente"] = element["id_cliente"];
      element['id_direccion'] = element["id_direccion"];
    }

    final now = DateTime.now();

    data['empleado_maneja'] = {
      "id_vehiculo": vehiculoSelected!.id,
      "id_empleado": empleadoSelected!.id,
      "fecha_m": now.add(const Duration(days: 1)),
      "hr_salida": now.add(const Duration(days: 1)),
      "hr_llegada": now.add(const Duration(days: 4)),
    };

    bool response200 = false;
    _loading.value = true;

    response200 = await context.read<ViajesProvider>().agregar(
          row: data,
          vehiculoID: vehiculoSelected!.id!,
          onError: () => ShowSnackBar.showError(context),
        );

    _loading.value = false;

    if (!mounted || !response200) return;
    Navigator.pop(context);
    ShowSnackBar.showSuccessful(context);
  }
}
