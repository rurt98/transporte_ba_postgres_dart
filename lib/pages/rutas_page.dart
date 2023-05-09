import 'package:flutter/material.dart';
import 'package:paqueteria_barranco/models/ruta.dart';
import 'package:paqueteria_barranco/provider/rutas_provider.dart';
import 'package:paqueteria_barranco/utilities/forms_utils.dart';
import 'package:paqueteria_barranco/utilities/formulario_template.dart';
import 'package:paqueteria_barranco/utilities/show_dialog.dart';
import 'package:paqueteria_barranco/utilities/show_snackbar.dart';
import 'package:paqueteria_barranco/utilities/validate_extensions.dart';
import 'package:paqueteria_barranco/widget/page_loading_absorb_pointer.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class RutasPages extends StatefulWidget {
  const RutasPages({super.key});

  @override
  State<RutasPages> createState() => _RutasPagesState();
}

class _RutasPagesState extends State<RutasPages> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<RutasProvider>().getAll();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutas'),
      ),

      body: Selector<RutasProvider, Tuple2<bool, List<Ruta>>>(
        selector: (_, provider) => Tuple2(provider.loading, provider.rutas),
        shouldRebuild: (_, __) => true,
        builder: (_, values, __) {
          final loading = values.item1;
          final rutas = values.item2;
          return PageLoadingAbsorbPointer(
            isLoading: loading,
            child: Column(
              children: [
                if (rutas.isEmpty)
                  IconButton(
                    onPressed: () =>
                        context.read<RutasProvider>().populateRutas(),
                    icon: const Icon(
                      Icons.replay,
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: rutas.length,
                    itemBuilder: (_, int i) {
                      final ruta = rutas[i];
                      return _buildCard(ruta);
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
          child: const FormRutaWidget(),
        ),
        tooltip: 'Agregar',
        child: const Icon(Icons.add),
      ), // This
    );
  }

  Widget _buildCard(Ruta ruta) {
    return Card(
      child: ListTile(
        onTap: () => ShowDialog.showSimpleRightDialog(
          context,
          child: FormRutaWidget(
            ruta: ruta,
          ),
        ),
        leading: const Icon(Icons.location_on, size: 30),
        title: Text(ruta.nombre),
        subtitle: Text('${ruta.tiempo} hrs'),
        trailing: Text(ruta.distancia),
      ),
    );
  }
}

class FormRutaWidget extends StatefulWidget {
  final Ruta? ruta;
  const FormRutaWidget({
    super.key,
    this.ruta,
  });

  @override
  State<FormRutaWidget> createState() => _FormRutaWidgetState();
}

class _FormRutaWidgetState extends State<FormRutaWidget> {
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> _loading = ValueNotifier<bool>(false);

  ScrollController scrollController = ScrollController();

  late bool edit;
  Map<String, dynamic> data = {};
  TimeOfDay? time;

  @override
  void initState() {
    edit = widget.ruta != null;
    if (edit) {
      data = widget.ruta!.toMap();
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
          titulo: "${edit ? 'Editar' : 'Nuevo'} ruta",
          onPressSave: _onPressSave,
          body: Form(
            key: _formKey,
            child: Column(
              children: [
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
                  labelText: "Distancia",
                  initialValue: data['distancia'],
                  onChanged: (value) => data['distancia'] = value,
                  validators: (value) => value!.validatorLeesThan50,
                  isRequired: true,
                ),
                const SizedBox(height: 5),
                Forms.textField(
                  hintText: "xx:xx:xx",
                  labelText: "Tiempo",
                  initialValue: data['tiempo'],
                  onChanged: (value) => data['tiempo'] = value,
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
                        title: "¿Deseas eliminar ${widget.ruta!.nombre}?",
                      );

                      if (res != true || !mounted) return;

                      _loading.value = true;

                      final successful =
                          await context.read<RutasProvider>().eliminar(
                                id: widget.ruta!.id,
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
      response200 = await context.read<RutasProvider>().editar(
            id: widget.ruta!.id,
            data: data,
            onError: () => ShowSnackBar.showError(context),
          );
    } else {
      response200 = await context.read<RutasProvider>().agregar(
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
