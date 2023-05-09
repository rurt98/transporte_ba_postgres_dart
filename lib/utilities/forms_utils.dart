import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paqueteria_barranco/utilities/input_validators.dart';

import 'package:flutter/services.dart';

// CLASE PARA MANEJAR WIDGETS PARA FORMULARIOS
class Forms {
  static Widget textField({
    TextEditingController? controller,
    String? labelText,
    String? hintText,
    String? initialValue,
    int maxLines = 1,
    int? maxLenght,
    String? Function(String?)? validators,
    Function(String?)? onSaved,
    int flex = 1,
    bool inRow = false,
    bool isRequired = false,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    bool enabled = true,
    bool showLabel = true,
    Function(String)? onChanged,
  }) {
    final tf = Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showLabel)
              _labelWithRequired(labelText ?? hintText ?? '', isRequired),
            TextFormField(
              enabled: enabled,
              controller: controller,
              initialValue: initialValue,
              maxLength: maxLenght,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                alignLabelWithHint: true,
                hintText: hintText ?? labelText,
                floatingLabelStyle: const TextStyle(color: Colors.transparent),
              ),
              buildCounter: maxLenght != null ? _buildCounter : null,
              inputFormatters: inputFormatters,
              onSaved: onSaved,
              maxLines: maxLines,
              onChanged: onChanged,
              validator: (s) {
                if (isRequired) {
                  final res = InputValidators.isNotEmpty(s);
                  if (res != null) {
                    return res;
                  }
                }
                if (validators != null) {
                  return validators(s);
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
    if (!inRow) {
      return Row(
        children: [tf],
      );
    }
    return tf;
  }

  static Widget textFieldCount({
    required TextEditingController controller,
    String? labelText,
    String? hintText,
    String? initialValue,
    String? Function(String?)? validators,
    Function(int?)? onSaved,
    int flex = 1,
    bool inRow = false,
    bool isRequired = false,
  }) {
    final tf = Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _labelWithRequired(labelText ?? hintText ?? '', isRequired),
            TextFormField(
              controller: controller,
              initialValue: initialValue,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                alignLabelWithHint: true,
                hintText: hintText,
                suffixIcon: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        if (controller.text.isEmpty) controller.text = '0';

                        int count = int.parse(controller.text);

                        controller.text = (++count).toString();
                      },
                      child: const Icon(Icons.keyboard_arrow_up_rounded),
                    ),
                    InkWell(
                      onTap: () {
                        if (controller.text.isEmpty || controller.text == '0') {
                          return;
                        }

                        int count = int.parse(controller.text);

                        controller.text = (--count).toString();
                      },
                      child: const Icon(Icons.keyboard_arrow_down_rounded),
                    ),
                  ],
                ),
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(
                    RegExp(r'[0-9]')), // Solo permite caracteres numéricos
              ],
              onSaved: (v) {
                if (onSaved != null && v != null) onSaved(int.parse(v));
              },
              validator: (s) {
                if (!isRequired) {
                  final res = InputValidators.isNotEmpty(s);
                  if (res != null) {
                    return res;
                  }
                }
                if (validators != null) {
                  return validators(s);
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
    if (!inRow) {
      return Row(
        children: [tf],
      );
    }
    return tf;
  }

  static Widget timePicker(
    BuildContext context, {
    String? labelText,
    int flex = 1,
    bool isRequired = false,
    bool inRow = false,
    TimeOfDay? initialTime,
    required ValueChanged<TimeOfDay> timeChanged,
  }) {
    final tf = Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _labelWithRequired(labelText ?? '', isRequired),
            TextFormField(
              readOnly: true,
              onTap: () async {
                final TimeOfDay? timeOfDay = await showTimePicker(
                  context: context,
                  initialTime: initialTime ?? TimeOfDay.now(),
                );

                if (timeOfDay == null || timeOfDay == initialTime) return;

                timeChanged(timeOfDay);
              },
              decoration: InputDecoration(
                hintText:
                    initialTime == null ? 'HH:mm' : initialTime.format(context),
              ),
              validator: (_) {
                if (isRequired && initialTime == null) {
                  return 'El valor es nulo o vacío';
                }

                return null;
              },
            ),
          ],
        ),
      ),
    );
    if (!inRow) {
      return Row(
        children: [tf],
      );
    }
    return tf;
  }

  static Widget datePicker(
    BuildContext context, {
    String? labelText,
    int flex = 1,
    bool isRequired = false,
    DateTime? firstDate,
    bool inRow = false,
    DateTime? initialDate,
    bool enabled = true,
    required ValueChanged<DateTime> dateChanged,
  }) {
    final tf = Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _labelWithRequired(labelText ?? 'Fecha', isRequired),
            TextFormField(
              readOnly: true,
              onTap: () async {
                if (!enabled) return;
                final DateTime? date = await showDatePicker(
                  context: context,
                  initialDate: initialDate ?? DateTime(DateTime.now().year),
                  firstDate: firstDate ?? DateTime(DateTime.now().year),
                  lastDate: DateTime(2050),
                );

                if (date == null || date == initialDate) return;

                dateChanged(date);
              },
              decoration: InputDecoration(
                  hintText: initialDate == null
                      ? 'dd/MM/aaaa'
                      : DateFormat('dd/MM/yyyy').format(initialDate)),
              validator: (_) {
                if (isRequired && initialDate == null) {
                  return 'El valor es nulo o vacío';
                }

                return null;
              },
            ),
          ],
        ),
      ),
    );
    if (!inRow) {
      return Row(
        children: [tf],
      );
    }
    return tf;
  }

  static Widget chip(
          {required String label,
          required bool selected,
          Function(bool)? onTap}) =>
      Padding(
        padding: const EdgeInsets.all(5.0),
        child: StatefulBuilder(
          builder: (_, setstate) => ChoiceChip(
            onSelected: (s) {
              selected = !selected;
              setstate(() {});
            },
            label: Text(label),
            selected: selected,
          ),
        ),
      );

  static Widget dropdown<T>(
    BuildContext context, {
    required T? value,
    required String? labelText,
    required List<DropdownMenuItem<T>> items,
    String? Function(Object?)? validators,
    Function(T?)? onSaved,
    Function(T?)? onChanged,
    bool isRequired = false,
    int flex = 1,
    bool inRow = false,
  }) {
    final w = Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _labelWithRequired(labelText ?? '', isRequired),
            DropdownButtonFormField<T>(
              focusColor: Colors.transparent,
              isExpanded: true,
              hint: Text(
                labelText ?? '',
                style: TextStyle(
                  color:
                      Theme.of(context).inputDecorationTheme.hintStyle?.color,
                ),
              ),
              items: items,
              value: value,
              onChanged: (s) {
                if (s != null) {
                  value = s;
                }
                if (onChanged != null) onChanged(s);
              },
              onSaved: onSaved,
              validator: (s) {
                if (isRequired) {
                  if (s == null) {
                    return "El campo es obligatorio";
                  }
                }
                if (validators != null) {
                  validators(s);
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
    if (!inRow) {
      return Row(
        children: [w],
      );
    }
    return w;
  }

  // static Widget multiDropdown<T>(
  //   BuildContext context, {
  //   required List<T> selecteds,
  //   required String? labelText,
  //   String? hintText,
  //   required List<T> items,
  //   String? Function(Object?)? validators,
  //   Function(List<T>?)? onSaved,
  //   required String Function(T) itemToString,
  //   bool isRequired = false,
  //   int flex = 1,
  //   bool inRow = false,
  // }) {
  //   final w = Expanded(
  //     flex: flex,
  //     child: Padding(
  //       padding: const EdgeInsets.all(3.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           _labelWithRequired(labelText ?? '', isRequired),
  //           FormField(
  //             autovalidateMode: AutovalidateMode.onUserInteraction,
  //             builder: (s) => Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Container(
  //                   decoration: const BoxDecoration(
  //                       color: Colors.red,
  //                       borderRadius: BorderRadius.all(Radius.circular(12))),
  //                   child: Padding(
  //                     padding: EdgeInsets.all(s.hasError ? 1.5 : 0),
  //                     child: DropDownMultiSelect<T>(
  //                       selectedValues: selecteds,
  //                       options: items,
  //                       menuItembuilder: (option) => Row(
  //                         children: [
  //                           Icon(selecteds.contains(option)
  //                               ? Icons.check_box
  //                               : Icons.check_box_outline_blank),
  //                           const SizedBox(
  //                             width: 5,
  //                           ),
  //                           Text(itemToString(option)),
  //                         ],
  //                       ),
  //                       childBuilder: (selecteds) => Padding(
  //                         padding: const EdgeInsets.symmetric(horizontal: 15),
  //                         child: Text(selecteds.isEmpty
  //                             ? (labelText ?? 'Selecciona opción')
  //                             : (selecteds
  //                                 .map((e) => itemToString(e))
  //                                 .toList()
  //                                 .toString())),
  //                       ),
  //                       onChanged: (s) {
  //                         selecteds = s;
  //                       },
  //                     ),
  //                   ),
  //                 ),
  //                 if (s.hasError)
  //                   Padding(
  //                     padding: const EdgeInsets.symmetric(
  //                         vertical: 8.0, horizontal: 14),
  //                     child: Text(
  //                       s.errorText ?? "Error de validación",
  //                       style: TextStyle(
  //                         color: Colors.red[600],
  //                         fontSize: 12,
  //                       ),
  //                     ),
  //                   ),
  //               ],
  //             ),
  //             onSaved: onSaved,
  //             validator: (s) {
  //               if (isRequired) {
  //                 if (selecteds.isEmpty == true) {
  //                   return "El campo es obligatorio";
  //                 }
  //               }
  //               if (validators != null) {
  //                 validators(selecteds);
  //               }
  //               return null;
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  //   if (!inRow) {
  //     return Row(
  //       children: [w],
  //     );
  //   }
  //   return w;
  // }

  static Widget autocomplete<T extends Object>({
    required List<String> items,
    T? initialValue,
    String? labelText,
    String? Function(Object?)? validators,
    Function(T)? onSaved,
    int flex = 1,
    bool inRow = false,
    bool isRequired = false,
  }) {
    final w = Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Column(
          children: [
            _labelWithRequired(labelText ?? '', isRequired),
            Autocomplete<T>(
              initialValue: initialValue == null
                  ? null
                  : TextEditingValue(text: initialValue.toString()),
              optionsBuilder: (text) async => List.from(
                items
                    .where((e) =>
                        e.toLowerCase().contains(text.text.toLowerCase()))
                    .map((e) => e),
              ),
            ),
          ],
        ),
      ),
    );
    if (!inRow) {
      return Row(
        children: [w],
      );
    }
    return w;
  }

  static ExpansionPanel expansionPanel<T>(
          {required String title, required List<T> options}) =>
      ExpansionPanel(
          headerBuilder: (context, isExpanded) {
            return Text(title);
          },
          body: Column(
            children: [...options.map((e) => Text(e.toString()))],
          ));

  static Widget title(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
        child: Text(
          text,
          textScaleFactor: 1.05,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );

  static Widget subtitle(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: Text(
          text,
        ),
      );

  static Widget _labelWithRequired(String labelText, bool isRequired) =>
      Padding(
        padding: const EdgeInsets.all(3.0),
        child: Row(
          children: [
            Expanded(
              flex: isRequired ? 0 : 1,
              child: Text(
                labelText,
              ),
            ),
            if (isRequired)
              Text(
                " *",
                style: TextStyle(
                  color: Colors.red[300],
                ),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      );

  // Función para validar los forms
  static String? isValid(List<String?>? validators) {
    if (validators != null) {
      if (validators.isNotEmpty == true) {
        for (final v in validators) {
          if (v != null) {
            return v;
          }
        }
      }
    }
    return null;
  }
}

List<IconData> icons = [
  Icons.ac_unit,
  Icons.access_alarm,
  Icons.accessibility,
  Icons.add_alert,
  Icons.airline_seat_flat,
  Icons.airplanemode_active,
  Icons.attach_file,
  Icons.backup,
  Icons.bookmark,
  Icons.cake,
  Icons.call,
  Icons.camera,
  Icons.directions_car,
  Icons.email,
  Icons.favorite,
  Icons.home,
  Icons.image,
  Icons.laptop,
  Icons.music_note,
  Icons.notifications,
  Icons.palette,
  Icons.person,
  Icons.search,
  Icons.shopping_cart,
  Icons.star,
  Icons.thumb_up,
  Icons.work,
];

Widget? _buildCounter(BuildContext context,
    {required int currentLength,
    required int? maxLength,
    required bool isFocused}) {
  return const SizedBox();
}
