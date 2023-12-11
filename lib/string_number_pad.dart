library number_pad;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Show a number pad dialog.
Future<String?> showStringNumberPad(
  BuildContext context, {
  FocusNode? focusNode,
  String? initialValue,
  String? hintText,
  BoxConstraints? constraints,
  int? maxLength,
}) {
  return showAdaptiveDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return Theme(
            data: ThemeData(useMaterial3: true),
            child: Dialog(
              child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: StringNumberPad(
                    focusNode: focusNode,
                    initialValue: initialValue,
                    hintText: hintText,
                    constraints: constraints,
                    maxLength: maxLength,
                  )),
            ));
      });
}

const _constraints = BoxConstraints(maxWidth: 500, maxHeight: 500);

/// A number pad dialog.
class StringNumberPad extends StatefulWidget {
  const StringNumberPad({
    super.key,
    this.focusNode,
    this.initialValue,
    this.hintText,
    this.constraints = _constraints,
    this.maxLength,
  });

  final FocusNode? focusNode;
  final String? initialValue;
  final String? hintText;
  final BoxConstraints? constraints;
  final int? maxLength;

  @override
  State<StringNumberPad> createState() => _StringNumberPadState();
}

class _StringNumberPadState extends State<StringNumberPad> {
  late final controller = TextEditingController(text: widget.initialValue);
  late final keyboardFocusNode = widget.focusNode ?? FocusNode();
  final inputFocusNode = FocusNode();
  late String? _initialValue = widget.initialValue;

  @override
  void initState() {
    super.initState();

    /// When the dialog is opened, request focus on the keyboard listener.
    keyboardFocusNode.requestFocus();

    /// When inputFocusNode loses focus, focus keyboardFocusNode.
    inputFocusNode.addListener(() {
      if (!inputFocusNode.hasFocus) {
        keyboardFocusNode.requestFocus();
      }
    });

    controller.addListener(() {
      if (controller.text.length >= widget.maxLength!) {
        pop();
      }
    });
  }

  clearInitialValue() {
    if (_initialValue != null) {
      controller.text = '';
      _initialValue = null;
    }
  }

  /// Add a number to the text field.
  addNumber(num value) {
    clearInitialValue();
    controller.text += value.toString();
  }

  /// Add a dot to the text field.
  addDot() {
    clearInitialValue();

    /// If the text field is empty, add a zero before the dot.
    if (controller.text.isEmpty) {
      controller.text += '0';
    }

    /// If the text field does not contain a dot, add a dot.
    if (!controller.text.contains('.')) {
      controller.text += '.';
    }
  }

  /// Remove the last character from the text field.
  delete() {
    if (controller.text.isNotEmpty) {
      controller.text =
          controller.text.substring(0, controller.text.length - 1);
    }
  }

  /// Close the dialog and return the value.
  pop() {
    Navigator.of(context).maybePop(controller.text);
  }

  /// The number button adds a number to the text field.
  Widget numberButton(num value) {
    return InkWell(
      onTap: () => addNumber(value),
      child: Center(
        child: Text(
          value.toString(),
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  /// The dot button adds a dot to the text field.
  Widget dotButton() {
    return InkWell(
      onTap: addDot,
      child: const Center(
        child: Text(
          '.',
          style: TextStyle(fontSize: 30),
        ),
      ),
    );
  }

  /// The delete button removes the last character from the text field.
  Widget deleteButton() {
    return InkWell(
      onTap: delete,
      child: const Center(
        child: Icon(Icons.backspace),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    keyboardFocusNode.dispose();
    inputFocusNode.dispose();
    inputFocusNode.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Constrain the size of the dialog.
    return ConstrainedBox(
      constraints: _constraints,
      child: KeyboardListener(
          focusNode: keyboardFocusNode,
          onKeyEvent: (event) {
            if (inputFocusNode.hasFocus) return;

            if (event is KeyUpEvent) return;

            /// If the user presses number keys, add the number to the text field.
            if (event.character?.contains(RegExp(r'\d+')) ?? false) {
              addNumber(num.parse(event.character!));
            }

            /// If the user presses the dot key, add the dot to the text field.
            if (event.character == '.') addDot();

            /// If the user presses the backspace key, remove the last character
            if (event.logicalKey == LogicalKeyboardKey.backspace) delete();

            /// If the user presses the enter key, close the dialog
            /// and return the value.
            if ((event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.numpadEnter)) pop();
          },
          child: Column(
            children: [
              Expanded(
                child: Row(children: [
                  Expanded(
                      child: TextField(
                    focusNode: inputFocusNode,
                    controller: controller,
                    inputFormatters: [
                      /// Only allow numbers and one dot.
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    style: const TextStyle(fontSize: 50),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: widget.hintText ?? '0',
                      hintStyle: const TextStyle(fontSize: 50),
                      suffixIconConstraints:
                          BoxConstraints.tight(const Size(40, 40)),
                    ),
                  )),
                  IconButton(
                      onPressed: pop,
                      icon: const Icon(
                        Icons.check,
                        size: 40,
                      ))
                ]),
              ),

              /// Generate the number buttons.
              ...List.generate(3, (y) {
                return Expanded(
                    child: Row(
                  children: [
                    ...List.generate(3, (x) {
                      final value = x + y * 3 + 1;
                      return Expanded(child: numberButton(value));
                    }),
                  ],
                ));
              }),

              /// Generate the dot, zero and delete buttons.
              Expanded(
                  child: Row(
                children: [
                  const Spacer(),
                  Expanded(child: numberButton(0)),
                  Expanded(child: deleteButton()),
                ],
              ))
            ],
          )),
    );
  }
}
