library number_pad;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Show a number pad dialog.
Future<num?> showNumberPad(
  BuildContext context, {
  FocusNode? focusNode,
  num? initialValue,
  String? hintText,
}) {
  return showDialog(
      context: context,
      builder: (context) {
        return Theme(
            data: ThemeData(useMaterial3: true),
            child: Dialog(
              child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: NumberPad(
                    focusNode: focusNode,
                    initialValue: initialValue,
                    hintText: hintText,
                  )),
            ));
      });
}

/// A number pad dialog.
class NumberPad extends StatefulWidget {
  const NumberPad(
      {super.key, this.focusNode, this.initialValue, this.hintText});

  final FocusNode? focusNode;
  final num? initialValue;
  final String? hintText;

  @override
  State<NumberPad> createState() => _NumberPadState();
}

class _NumberPadState extends State<NumberPad> {
  late final controller =
      TextEditingController(text: widget.initialValue?.toString());
  late final keyboardFocusNode = widget.focusNode ?? FocusNode();
  final inputFocusNode = FocusNode();

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
  }

  /// Add a number to the text field.
  addNumber(num value) {
    controller.text += value.toString();
  }

  /// Add a dot to the text field.
  addDot() {
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
    Navigator.of(context).maybePop(num.tryParse(controller.text));
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
      constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
      child: KeyboardListener(
          focusNode: keyboardFocusNode,
          onKeyEvent: (value) {
            if (inputFocusNode.hasFocus) return;

            /// If the user presses number keys, add the number to the text field.
            if (value.character?.contains(RegExp(r'\d+')) ?? false) {
              addNumber(num.parse(value.character!));
            }

            /// If the user presses the dot key, add the dot to the text field.
            if (value.character == '.') addDot();

            /// If the user presses the backspace key, remove the last character
            if (value.logicalKey == LogicalKeyboardKey.backspace) delete();

            /// If the user presses the enter key, close the dialog
            /// and return the value.
            if ((value.logicalKey == LogicalKeyboardKey.enter ||
                value.logicalKey == LogicalKeyboardKey.numpadEnter)) pop();
          },
          child: Column(
            children: [
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
                      suffixIcon: IconButton(
                          onPressed: pop,
                          icon: const Icon(
                            Icons.check,
                            size: 40,
                          ))),
                ),
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
                  Expanded(child: dotButton()),
                  Expanded(child: numberButton(0)),
                  Expanded(child: deleteButton()),
                ],
              ))
            ],
          )),
    );
  }
}
