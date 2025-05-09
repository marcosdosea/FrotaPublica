import 'package:flutter/services.dart';

// Formatter personalizado para CPF
class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Apenas dígitos são permitidos
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    final chars = digitsOnly.split('');
    final buffer = StringBuffer();

    // Aplica a formatação xxx.xxx.xxx-xx
    for (int i = 0; i < chars.length; i++) {
      buffer.write(chars[i]);
      if (i == 2 || i == 5) {
        if (i < chars.length - 1) {
          buffer.write('.');
        }
      } else if (i == 8) {
        if (i < chars.length - 1) {
          buffer.write('-');
        }
      }
    }

    final formattedText = buffer.toString();

    // Limita a 14 caracteres (11 dígitos + 3 separadores)
    if (formattedText.length > 14) {
      return oldValue;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
