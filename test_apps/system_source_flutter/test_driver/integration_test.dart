// Runs integration_test on the web: flutter drive --driver=test_driver/integration_test.dart
// --target=integration_test/system_source_test.dart -d web-server
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
