import 'package:flutter/material.dart';
import 'package:paqueteria_barranco/models/vehiculo.dart';
import 'package:paqueteria_barranco/provider/cars_provider.dart';

import 'package:paqueteria_barranco/utilities/forms_utils.dart';
import 'package:paqueteria_barranco/utilities/formulario_template.dart';
import 'package:paqueteria_barranco/utilities/show_dialog.dart';
import 'package:paqueteria_barranco/utilities/show_snackbar.dart';
import 'package:paqueteria_barranco/utilities/validate_extensions.dart';
import 'package:paqueteria_barranco/widget/page_loading_absorb_pointer.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class CarsPage extends StatefulWidget {
  const CarsPage({super.key});

  @override
  State<CarsPage> createState() => _CarsPageState();
}

class _CarsPageState extends State<CarsPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<CarsProvider>().getAll();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehículos'),
      ),
      body: Selector<CarsProvider, Tuple2<bool, List<Vehiculo>>>(
        selector: (_, provider) => Tuple2(provider.loading, provider.vehiculos),
        shouldRebuild: (_, __) => true,
        builder: (_, values, __) {
          final loading = values.item1;
          final vehiculos = values.item2;
          return PageLoadingAbsorbPointer(
            isLoading: loading,
            child: Column(
              children: [
                if (vehiculos.isEmpty)
                  IconButton(
                    onPressed: () => context.read<CarsProvider>().populate(),
                    icon: const Icon(
                      Icons.replay,
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: vehiculos.length,
                    itemBuilder: (_, int i) {
                      final vehiculo = vehiculos[i];
                      return _buildCard(vehiculo);
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
          child: const FormCarWidget(),
        ),
        tooltip: 'Agregar',
        child: const Icon(Icons.add),
      ), // This
    );
  }

  Widget _buildCard(Vehiculo vehiculo) {
    return Card(
      child: ListTile(
        onTap: () => ShowDialog.showSimpleRightDialog(
          context,
          child: FormCarWidget(
            vehiculo: vehiculo,
          ),
        ),
        leading: const Icon(Icons.local_shipping, size: 30),
        title: Text(vehiculo.marca ?? '-'),
        subtitle: Text(vehiculo.modelo ?? '-'),
        trailing: Text(vehiculo.cap_carga ?? '-'),
      ),
    );
  }
}

class FormCarWidget extends StatefulWidget {
  final Vehiculo? vehiculo;
  const FormCarWidget({
    super.key,
    this.vehiculo,
  });

  @override
  State<FormCarWidget> createState() => _FormCarWidgetState();
}

class _FormCarWidgetState extends State<FormCarWidget> {
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> _loading = ValueNotifier<bool>(false);

  ScrollController scrollController = ScrollController();

  late bool edit;
  Map<String, dynamic> data = {};
  TimeOfDay? time;

  @override
  void initState() {
    edit = widget.vehiculo != null;
    if (edit) {
      data = widget.vehiculo!.toMap();
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
          titulo: "${edit ? 'Editar' : 'Nuevo'} vehículo",
          onPressSave: _onPressSave,
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                Forms.textField(
                  hintText: "",
                  labelText: "Marca",
                  initialValue: data['marca'],
                  onChanged: (value) => data['marca'] = value,
                  validators: (value) => value!.validatorLeesThan50,
                  isRequired: true,
                ),
                const SizedBox(height: 5),
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
                        title: "¿Deseas eliminar ${widget.vehiculo!.modelo}?",
                      );

                      if (res != true || !mounted) return;

                      _loading.value = true;

                      final successful =
                          await context.read<CarsProvider>().eliminar(
                                id: widget.vehiculo!.id!,
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
      response200 = await context.read<CarsProvider>().editar(
            id: widget.vehiculo!.id!,
            data: data,
            onError: () => ShowSnackBar.showError(context),
          );
    } else {
      response200 = await context.read<CarsProvider>().agregar(
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
