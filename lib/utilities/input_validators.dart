class InputValidators {
  static String? isNotNull(Object? value) {
    if (value == null) {
      return 'El campo es obligatorio';
    } else {
      return null;
    }
  }

  static String? isNotEmpty(String? value) {
    if (value == null || value.isEmpty) {
      return 'El valor es nulo o vacío';
    } else {
      return null;
    }
  }

  static String? isNumeric(String? value) {
    final parsedValue = double.tryParse(value ?? "");
    if (parsedValue == null) {
      return 'El valor no es numérico';
    } else {
      return null;
    }
  }

  static String? isInteger(String? value) {
    final parsedValue = int.tryParse(value ?? "");
    if (parsedValue == null) {
      return 'El valor no es numérico';
    } else {
      return null;
    }
  }

  static String? isEmail(String? value) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value ?? "")) {
      return 'El valor no es un correo electrónico válido';
    } else {
      return null;
    }
  }

  static String? isPhoneNumber(String? value) {
    if (isInteger(value) != null) {
      return 'El valor no es un número de teléfono válido';
    } else if (value?.length != 10) {
      return 'El teléfono debe tener 10 dígitos';
    } else {
      return null;
    }
  }

  static String? isPassword(String? value) {
    if (value!.length < 6) {
      return 'Debe tener al menos 6 carácteres';
    } else {
      return null;
    }
  }

  static String? isOnlyText(String? value) {
    final nameRegex = RegExp(r'^[a-zA-ZÀ-ÖØ-öø-ÿ\s]+$');
    if (!nameRegex.hasMatch(value ?? "")) {
      return 'El valor no es un nombre válido para una persona';
    } else {
      return null;
    }
  }

  static String? maxLenght(String? text, int maxLenght) {
    if ((text ?? '').length > maxLenght) {
      return 'El campo no debe exceder de $maxLenght carácteres';
    } else {
      return null;
    }
  }

  static String? isOnlyLetterAndNumbers(String? vin) {
    RegExp r = RegExp(r'^[a-zA-Z0-9]+$');
    if (!r.hasMatch(vin ?? "")) {
      return 'Sólo debe contener letras y números';
    } else {
      return null;
    }
  }

  static String? isNumeroSerieVehiculo(String? vin) {
    RegExp r = RegExp(r'^[A-HJ-NPR-Z0-9]{17}$');
    if (!r.hasMatch(vin ?? "")) {
      return 'No es un número de serie válido';
    } else {
      return null;
    }
  }
}
