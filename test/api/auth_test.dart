import 'package:flutter_test/flutter_test.dart';
import 'package:gakujo_gui/api/gakujo_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Authenticate', () {
    final api = GakujoApi(
      username: '',
      password: '',
      year: 2023,
      semester: 3,
    );

    test('initialize', () async {
      await api.initialize(null);
    });

    test('login', () async {
      await api.fetchLogin();
    });
  });
}
