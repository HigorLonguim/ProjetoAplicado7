import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:origem/screens/login_screen.dart';
import 'package:origem/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'permite novo cadastro depois de sair sem apagar a conta ao cancelar',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final auth = AuthService();
      await auth.register(
        name: 'Conta antiga',
        email: 'antiga@teste.com',
        password: 'senha123',
      );
      await tester.pumpWidget(const MaterialApp(home: AccountScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sair da conta'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Conta salva neste dispositivo: antiga@teste.com'),
        findsOneWidget,
      );

      await tester.tap(find.text('Criar outra conta'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect((await auth.currentUser)!.email, 'antiga@teste.com');

      await tester.tap(find.text('Criar outra conta'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Conta nova');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'nova@teste.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'novasenha');
      await tester.ensureVisible(find.text('Criar minha conta'));
      await tester.tap(find.text('Criar minha conta'));
      await tester.pumpAndSettle();
      expect(find.text('nova@teste.com'), findsOneWidget);
      expect(await auth.isLoggedIn, isTrue);
      await auth.logout();
      expect(
        await auth.login(email: 'antiga@teste.com', password: 'senha123'),
        isFalse,
      );
      expect(
        await auth.login(email: 'nova@teste.com', password: 'novasenha'),
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
