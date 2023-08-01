import 'package:flutter_test/flutter_test.dart';

import 'package:number_pad/number_pad.dart';

void main() {
  testWidgets('Test NumberPad', (widgetTester) async {
    await widgetTester.pumpWidget(const NumberPad());
  });
}
