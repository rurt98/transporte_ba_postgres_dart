import 'package:flutter/material.dart';
import 'package:paqueteria_barranco/models/empleado.dart';
import 'package:paqueteria_barranco/provider/empleado_provider.dart';
import 'package:paqueteria_barranco/services/add_addresses_service.dart';

import 'package:paqueteria_barranco/utilities/forms_utils.dart';
import 'package:paqueteria_barranco/utilities/formulario_template.dart';
import 'package:paqueteria_barranco/utilities/show_dialog.dart';
import 'package:paqueteria_barranco/utilities/show_snackbar.dart';
import 'package:paqueteria_barranco/utilities/validate_extensions.dart';
import 'package:paqueteria_barranco/widget/page_loading_absorb_pointer.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class EmpleadosScreen extends StatefulWidget {
  const EmpleadosScreen({super.key});

  @override
  State<EmpleadosScreen> createState() => _EmpleadosScreenState();
}

class _EmpleadosScreenState extends State<EmpleadosScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<EmpleadoProvider>().getAll();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Empleados'),
      ),
      body: Selector<EmpleadoProvider, Tuple2<bool, List<Empleado>>>(
        selector: (_, provider) => Tuple2(provider.loading, provider.empleados),
        shouldRebuild: (_, __) => true,
        builder: (_, values, __) {
          final loading = values.item1;
          final empleados = values.item2;
          return PageLoadingAbsorbPointer(
            isLoading: loading,
            child: Column(
              children: [
                if (empleados.isEmpty)
                  IconButton(
                    onPressed: () async {
                      await context.read<AddAddressesService>().populate();
                      if (!mounted) return;
                      context.read<EmpleadoProvider>().populate();
                    },
                    icon: const Icon(
                      Icons.replay,
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: empleados.length,
                    itemBuilder: (_, int i) {
                      final empleado = empleados[i];
                      return _buildCard(empleado);
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
          child: const FormEmpleadoWidget(),
        ),
        tooltip: 'Agregar',
        child: const Icon(Icons.add),
      ), // This
    );
  }

  Widget _buildCard(Empleado empleado) {
    return Card(
      child: ListTile(
        onTap: () => ShowDialog.showSimpleRightDialog(
          context,
          child: FormEmpleadoWidget(
            empleado: empleado,
          ),
        ),
        leading: const Icon(
          Icons.person,
          size: 40,
        ),
        title: Text(empleado.nombre ?? '-'),
        subtitle: Text(empleado.num_licencia.toString()),
      ),
    );
  }
}

class FormEmpleadoWidget extends StatefulWidget {
  final Empleado? empleado;
  const FormEmpleadoWidget({
    super.key,
    this.empleado,
  });

  @override
  State<FormEmpleadoWidget> createState() => _FormEmpleadoWidgetState();
}

class _FormEmpleadoWidgetState extends State<FormEmpleadoWidget> {
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> _loading = ValueNotifier<bool>(false);

  ScrollController scrollController = ScrollController();

  late bool edit;
  Map<String, dynamic> data = {};
  TimeOfDay? time;

  @override
  void initState() {
    edit = widget.empleado != null;
    if (edit) {
      data = widget.empleado!.toMap();
      data.addAll(widget.empleado!.address!.toMap());
    }
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
          titulo: "${edit ? 'Editar' : 'Nuevo'} empleado",
          onPressSave: _onPressSave,
          body: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Información personal',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Forms.textField(
                  hintText: "",
                  labelText: "Nombre",
                  initialValue: data['nombre'],
                  onChanged: (value) => data['nombre'] = value,
                  validators: (value) => value!.validatorLeesThan50,
                  isRequired: true,
                ),
                const SizedBox(height: 5),
                Forms.textField(
                  hintText: "",
                  labelText: "Numero de licencia",
                  initialValue: data['num_licencia']?.toString() ?? "",
                  onChanged: (value) => data['num_licencia'] = int.parse(value),
                  validators: (value) => value!.validatorLeesThan50,
                  isRequired: true,
                ),
                const SizedBox(height: 5),
                Forms.textField(
                  hintText: "",
                  labelText: "Salario",
                  initialValue: data['salario']?.toString() ?? "",
                  onChanged: (value) => data['salario'] = double.parse(value),
                  validators: (value) => value!.validatorLeesThan50,
                  isRequired: true,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Dirección',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 5),
                Forms.textField(
                  hintText: "",
                  labelText: "Nombre del fraccionamiento",
                  initialValue: data['frac_nombre'],
                  onChanged: (value) => data['frac_nombre'] = value,
                  validators: (value) => value!.validatorLeesThan50,
                  isRequired: true,
                ),
                const SizedBox(height: 5),
                Forms.textField(
                  hintText: "",
                  labelText: "Calle",
                  initialValue: data['calle'],
                  onChanged: (value) => data['calle'] = value,
                  validators: (value) => value!.validatorLeesThan50,
                  isRequired: true,
                ),
                const SizedBox(height: 5),
                Forms.textField(
                  hintText: "",
                  labelText: "Cp",
                  initialValue: data['cp'],
                  onChanged: (value) => data['cp'] = value,
                  validators: (value) => value!.validatorLeesThan50,
                  isRequired: true,
                ),
                const SizedBox(height: 5),
                Forms.textField(
                  hintText: "",
                  labelText: "Colonia",
                  initialValue: data['colonia'],
                  onChanged: (value) => data['colonia'] = value,
                  validators: (value) => value!.validatorLeesThan50,
                  isRequired: true,
                ),
                const SizedBox(height: 5),
                Forms.textField(
                  hintText: "",
                  labelText: "Estado",
                  initialValue: data['estado'],
                  onChanged: (value) => data['estado'] = value,
                  validators: (value) => value!.validatorLeesThan50,
                  isRequired: true,
                ),
                const SizedBox(height: 5),
                Forms.textField(
                  hintText: "",
                  labelText: "Municipio",
                  initialValue: data['municipio'],
                  onChanged: (value) => data['municipio'] = value,
                  validators: (value) => value!.validatorLeesThan50,
                  isRequired: true,
                ),
                const SizedBox(height: 15),
                if (edit)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors
                          .red, // Cambia el color de fondo del botón a rojo
                    ),
                    onPressed: () async {
                      final res = await ShowDialog.showConfirmDialog(
                        context,
                        title: "¿Deseas eliminar ${widget.empleado!.nombre}?",
                      );

                      if (res != true || !mounted) return;

                      _loading.value = true;

                      final successful =
                          await context.read<EmpleadoProvider>().eliminar(
                                id: widget.empleado!.id!,
                                onError: () => ShowSnackBar.showError(context),
                              );

                      _loading.value = false;

                      if (!successful || !mounted) return;
                      Navigator.pop(context);
                      ShowSnackBar.showSuccessful(context);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text("Eliminar"),
                    ),
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

    if (edit) {
      response200 = await context.read<EmpleadoProvider>().editar(
            id: widget.empleado!.id!,
            addressId: widget.empleado!.address!.id!,
            data: data,
            onError: () => ShowSnackBar.showError(context),
          );
    } else {
      response200 = await context.read<EmpleadoProvider>().agregar(
            data: data,
            onError: () => ShowSnackBar.showError(context),
          );
    }

    _loading.value = false;

    if (!mounted || !response200) return;
    Navigator.pop(context);
    ShowSnackBar.showSuccessful(context);
  }
}
