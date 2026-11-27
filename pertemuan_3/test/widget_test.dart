```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum3_flutter_20240801120_anggiantdwiraka/main.dart';

void main() {
testWidgets('Menampilkan kartu profil mahasiswa',
(WidgetTester tester) async {
await tester.pumpWidget(const MyApp());

expect(find.text('Kartu Praktikan'), findsOneWidget);
expect(find.text('Anggiant Dwi Raka'), findsOneWidget);
expect(find.text('NIM: 20240801120'), findsOneWidget);
expect(find.text('Hobi: Berenang'), findsOneWidget);
expect(find.text('Skor Aktivitas: 70'), findsOneWidget);
});
}
```
