import 'package:flutter/material.dart';
import 'package:paqueteria_barranco/models/cliente.dart';
import 'package:paqueteria_barranco/provider/clientes_provider.dart';

import 'package:paqueteria_barranco/utilities/forms_utils.dart';
import 'package:paqueteria_barranco/utilities/formulario_template.dart';
import 'package:paqueteria_barranco/utilities/show_dialog.dart';
import 'package:paqueteria_barranco/utilities/show_snackbar.dart';
import 'package:paqueteria_barranco/utilities/validate_extensions.dart';
import 'package:paqueteria_barranco/widget/page_loading_absorb_pointer.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<ClientesProvider>().getAll();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
      ),
      body: Selector<ClientesProvider, Tuple2<bool, List<Cliente>>>(
        selector: (_, provider) => Tuple2(provider.loading, provider.clientes),
        shouldRebuild: (_, __) => true,
        builder: (_, values, __) {
          final loading = values.item1;
          final clientes = values.item2;
          return PageLoadingAbsorbPointer(
            isLoading: loading,
            child: Column(
              children: [
                if (clientes.isEmpty)
                  IconButton(
                    onPressed: () async {
                      context.read<ClientesProvider>().populate();
                    },
                    icon: const Icon(
                      Icons.replay,
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: clientes.length,
                    itemBuilder: (_, int i) {
                      final cliente = clientes[i];
                      return _buildCard(cliente);
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
          child: const FormClienteWidget(),
        ),
        tooltip: 'Agregar',
        child: const Icon(Icons.add),
      ), // This
    );
  }

  Widget _buildCard(Cliente cliente) {
    return Card(
      child: ListTile(
        onTap: () => ShowDialog.showSimpleRightDialog(
          context,
          child: FormClienteWidget(
            cliente: cliente,
          ),
        ),
        leading: const Icon(
          Icons.person,
          size: 40,
        ),
        title: Text(cliente.nombre ?? '-'),
        subtitle: Text(cliente.num_telefono.toString()),
      ),
    );
  }
}

class FormClienteWidget extends StatefulWidget {
  final Cliente? cliente;
  const FormClienteWidget({
    super.key,
    this.cliente,
  });

  @override
  State<FormClienteWidget> createState() => _FormClienteWidgetState();
}

class _FormClienteWidgetState extends State<FormClienteWidget> {
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> _loading = ValueNotifier<bool>(false);

  ScrollController scrollController = ScrollController();

  late bool edit;
  Map<String, dynamic> data = {};
  TimeOfDay? time;

  @override
  void initState() {
    edit = widget.cliente != null;
    if (edit) {
      data = widget.cliente!.toMap();
      data.addAll(widget.cliente!.address!.toMap());
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
          titulo: "${edit ? 'Editar' : 'Nuevo'} cliente",
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
                  labelText: "Numero de teléfono",
                  initialValue: data['num_telefono'],
                  onChanged: (value) => data['num_telefono'] = value,
                  validators: (value) => value!.validatorLeesThan50,
                  isRequired: true,
                ),
                const SizedBox(height: 5),
                Forms.textField(
                  hintText: "",
                  labelText: "Email",
                  initialValue: data['email'],
                  onChanged: (value) => data['email'] = value,
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
                        title: "¿Deseas eliminar ${widget.cliente!.nombre}?",
                      );

                      if (res != true || !mounted) return;

                      _loading.value = true;

                      final successful =
                          await context.read<ClientesProvider>().eliminar(
                                id: widget.cliente!.id!,
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
      response200 = await context.read<ClientesProvider>().editar(
            id: widget.cliente!.id!,
            addressId: widget.cliente!.address!.id!,
            data: data,
            onError: () => ShowSnackBar.showError(context),
          );
    } else {
      response200 = await context.read<ClientesProvider>().agregar(
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
