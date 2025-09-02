import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardAwareWidget extends StatelessWidget {
  final Widget child;
  final bool enableUnfocusOnTap;

  const KeyboardAwareWidget({
    super.key,
    required this.child,
    this.enableUnfocusOnTap = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enableUnfocusOnTap
          ? () {
              // Fechar teclado quando tocar fora dos campos
              FocusScope.of(context).unfocus();
              // Esconder teclado do sistema
              SystemChannels.textInput.invokeMethod('TextInput.hide');
            }
          : null,
      child: child,
    );
  }
}

class KeyboardAwareScrollView extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool enableUnfocusOnTap;

  const KeyboardAwareScrollView({
    super.key,
    required this.child,
    this.padding,
    this.physics,
    this.enableUnfocusOnTap = true,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardAwareWidget(
      enableUnfocusOnTap: enableUnfocusOnTap,
      child: SingleChildScrollView(
        padding: padding,
        physics: physics ?? const AlwaysScrollableScrollPhysics(),
        child: child,
      ),
    );
  }
}
