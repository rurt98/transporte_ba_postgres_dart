import 'package:flutter/material.dart';
import 'package:paqueteria_barranco/utilities/show_dialog.dart';

class FormTemplate extends StatefulWidget {
  final String titulo;
  final Widget body;
  final String? titleOnSave;

  final void Function()? onPressSave;
  final bool Function()? onBack;
  final List<Widget>? backActions;
  final bool loading;
  final ScrollController? scrollController;

  const FormTemplate({
    super.key,
    required this.titulo,
    this.loading = false,
    required this.body,
    this.titleOnSave,
    this.onBack,
    required this.onPressSave,
    required this.scrollController,
    this.backActions,
  });

  @override
  State<FormTemplate> createState() => _FormTemplateState();
}

class _FormTemplateState extends State<FormTemplate> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _body(context),
        if (widget.loading)
          Container(
            color: Colors.white.withOpacity(0.5),
            width: double.infinity,
            height: double.infinity,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
      ],
    );
  }

  Widget _body(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.onBack == null) return true;

        if (widget.onBack!() == true) return true;

        final res =
            await ShowDialog.showConfirmDialog(context, title: "Deseas salir?");

        if (res != true) return false;

        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: FittedBox(
            child: Text(
              widget.titulo,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: widget.scrollController,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: widget.body,
                ),
              ),
              if (widget.backActions != null) ...widget.backActions!,
              const SizedBox(
                height: 15,
              ),

              // Botón guardar
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.onPressSave,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(widget.titleOnSave ?? "Guardar cambios"),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
