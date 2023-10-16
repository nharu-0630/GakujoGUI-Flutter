import 'package:flutter_test/flutter_test.dart';
import 'package:gakujo_gui/api/gakujo_api.dart';
import 'package:otp/otp.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Authenticate', () {
    final api = GakujoApi(
      username: '',
      password: '',
      secret: '',
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
