import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/architecture/architecture_checker.dart';

void main() {
  late Directory project;

  setUp(() {
    project = Directory.systemTemp.createTempSync('app_arch_test_');
  });

  tearDown(() {
    project.deleteSync(recursive: true);
  });

  void write(String path, String source) {
    final file = File.fromUri(project.uri.resolve(path));
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(source);
  }

  List<ArchitectureViolation> check() => ArchitectureChecker(
    projectRoot: project,
    packageName: 'app_flutter',
  ).check();

  test('accepts allowed boundaries and ignores comments/generated files', () {
    write('lib/shared/value.dart', 'class Value {}');
    write('lib/features/home/home.dart', '''
// import 'package:app_flutter/app/app.dart';
import 'package:app_flutter/shared/value.dart';
export 'presentation/home_view.dart';
''');
    write('lib/features/home/presentation/home_view.dart', 'class HomeView {}');
    write(
      'lib/features/home/ignored.g.dart',
      "import 'package:app_flutter/app/app.dart';",
    );

    expect(check(), isEmpty);
  });

  test('ARCH001 catches package imports and exports', () {
    write('lib/features/home/home.dart', '''
import 'package:app_flutter/app/app.dart';
export 'package:app_flutter/app/theme/app_theme.dart';
''');

    expect(check().map((v) => v.code), ['ARCH001', 'ARCH001']);
  });

  test('ARCH001 also catches relative imports across the boundary', () {
    write(
      'lib/features/home/presentation/home_view.dart',
      "import '../../../app/app.dart';",
    );

    expect(check().single.code, 'ARCH001');
  });

  test('ARCH002 catches shared depending on app or features', () {
    write('lib/shared/example.dart', '''
import 'package:app_flutter/app/app.dart';
export 'package:app_flutter/features/home/home.dart';
''');

    expect(check().map((v) => v.code), ['ARCH002', 'ARCH002']);
  });

  test('ARCH003 catches direct GetIt dependency', () {
    write(
      'lib/features/home/home.dart',
      "import 'package:get_it/get_it.dart';",
    );

    expect(check().single.code, 'ARCH003');
  });

  test('ARCH004 catches a relative path leaving lib/', () {
    write('lib/features/home/home.dart', "import '../../../outside.dart';");

    expect(check().single.code, 'ARCH004');
  });

  test(
    'ARCH005 allows another feature public API via package or relative URI',
    () {
      write(
        'lib/features/billing/billing.dart',
        "export 'domain/invoice.dart';",
      );
      write('lib/features/billing/domain/invoice.dart', 'class Invoice {}');
      write('lib/features/home/presentation/views/home_view.dart', '''
import 'package:app_flutter/features/billing/billing.dart';
export '../../../billing/billing.dart';
''');

      expect(check(), isEmpty);
    },
  );

  test('ARCH005 allows private imports inside the same feature', () {
    write('lib/features/home/home.dart', '''
import 'presentation/views/home_view.dart';
export 'domain/home_service.dart';
''');
    write('lib/features/home/presentation/views/home_view.dart', '''
import 'package:app_flutter/features/home/domain/home_service.dart';
''');

    expect(check(), isEmpty);
  });

  test('ARCH005 rejects cross-feature package imports and exports', () {
    write('lib/features/home/home.dart', '''
import 'package:app_flutter/features/billing/data/invoice_api.dart';
export 'package:app_flutter/features/billing/presentation/invoice_view.dart';
''');

    final violations = check();
    expect(violations.map((v) => v.code), ['ARCH005', 'ARCH005']);
    expect(violations.map((v) => v.line), [1, 2]);
    expect(violations.first.path, 'lib/features/home/home.dart');
    expect(violations.first.message, contains('features/billing/billing.dart'));
  });

  test('ARCH005 rejects relative imports into another feature internals', () {
    write('lib/features/home/presentation/home_view.dart', '''
import '../../billing/data/invoice_api.dart';
''');

    expect(check().single.code, 'ARCH005');
  });

  test('ARCH005 requires the canonical barrel, not just a root-level file', () {
    write(
      'lib/features/home/home.dart',
      "import 'package:app_flutter/features/billing/invoice.dart';",
    );

    expect(check().single.code, 'ARCH005');
  });

  test('ARCH005 checks conditional cross-feature imports and exports', () {
    write('lib/features/home/home.dart', '''
import 'package:app_flutter/features/billing/billing.dart'
    if (dart.library.io) 'package:app_flutter/features/billing/data/invoice_api.dart';
export 'package:app_flutter/features/billing/billing.dart'
    if (dart.library.html) 'package:app_flutter/features/billing/presentation/invoice_view.dart';
''');

    expect(check().map((v) => v.code), ['ARCH005', 'ARCH005']);
  });

  test('ARCH005 resolves normalized relative paths before checking', () {
    write(
      'lib/features/home/presentation/home_view.dart',
      "import '../../billing/domain/../data/invoice_api.dart';",
    );

    expect(check().single.code, 'ARCH005');
  });

  test(
    'ARCH006 allows Domain to use Domain, shared and another public API',
    () {
      write('lib/features/billing/billing.dart', 'class Billing {}');
      write('lib/features/orders/domain/order.dart', '''
import 'package:app_flutter/features/orders/domain/order_id.dart';
import 'package:app_flutter/shared/result.dart';
import 'package:app_flutter/features/billing/billing.dart';
''');

      expect(check(), isEmpty);
    },
  );

  test(
    'ARCH006 rejects Domain imports and exports of local Data/Presentation',
    () {
      write('lib/features/orders/domain/order.dart', '''
import 'package:app_flutter/features/orders/data/order_store.dart';
export 'package:app_flutter/features/orders/presentation/order_view.dart';
''');

      final violations = check();
      expect(violations.map((v) => v.code), ['ARCH006', 'ARCH006']);
      expect(violations.map((v) => v.line), [1, 2]);
      expect(violations.first.message, contains('data/'));
      expect(violations.last.message, contains('presentation/'));
    },
  );

  test('ARCH006 rejects normalized relative paths from Domain into Data', () {
    write(
      'lib/features/orders/domain/entities/order.dart',
      "import '../../domain/../data/order_store.dart';",
    );

    expect(check().single.code, 'ARCH006');
  });

  test('ARCH006 checks conditional imports into Presentation', () {
    write('lib/features/orders/domain/order.dart', '''
import 'package:app_flutter/shared/result.dart'
    if (dart.library.io) 'package:app_flutter/features/orders/presentation/order_view.dart';
''');

    expect(check().single.code, 'ARCH006');
  });

  test('ARCH007 allows Data to depend on Domain and its own Data', () {
    write('lib/features/orders/data/order_store.dart', '''
import 'package:app_flutter/features/orders/domain/order.dart';
export 'package:app_flutter/features/orders/data/datasource.dart';
''');

    expect(check(), isEmpty);
  });

  test('ARCH007 rejects Data imports and exports of local Presentation', () {
    write('lib/features/orders/data/order_store.dart', '''
import 'package:app_flutter/features/orders/presentation/order_view.dart';
export 'package:app_flutter/features/orders/presentation/widgets/order_tile.dart';
''');

    final violations = check();
    expect(violations.map((v) => v.code), ['ARCH007', 'ARCH007']);
    expect(violations.map((v) => v.line), [1, 2]);
  });

  test(
    'ARCH007 rejects normalized relative paths from Data to Presentation',
    () {
      write(
        'lib/features/orders/data/sources/order_store.dart',
        "import '../../data/../presentation/order_view.dart';",
      );

      expect(check().single.code, 'ARCH007');
    },
  );

  test('ARCH007 checks conditional exports into Presentation', () {
    write('lib/features/orders/data/order_store.dart', '''
export 'package:app_flutter/features/orders/domain/order.dart'
    if (dart.library.io) 'package:app_flutter/features/orders/presentation/order_view.dart';
''');

    expect(check().single.code, 'ARCH007');
  });

  test('ARCH005 takes precedence for cross-feature private layer imports', () {
    write(
      'lib/features/orders/domain/order.dart',
      "import 'package:app_flutter/features/billing/data/billing_store.dart';",
    );

    expect(check().map((v) => v.code), ['ARCH005']);
  });

  test(
    'ARCH008 allows MobX in feature Presentation and shared Presentation',
    () {
      write('lib/features/home/presentation/views/home_view.dart', '''
import 'package:mobx/mobx.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
''');
      write(
        'lib/shared/presentation/ui_state.dart',
        "import 'package:mobx/mobx.dart';",
      );

      expect(check(), isEmpty);
    },
  );

  test('ARCH008 allows MobX in app/theme and app/app.dart', () {
    write(
      'lib/app/theme/theme_view_model.dart',
      "import 'package:mobx/mobx.dart';",
    );
    write(
      'lib/app/app.dart',
      "import 'package:flutter_mobx/flutter_mobx.dart';",
    );

    expect(check(), isEmpty);
  });

  test(
    'ARCH008 rejects MobX in feature Domain, Data and the public barrel',
    () {
      write(
        'lib/features/orders/domain/order.dart',
        "import 'package:mobx/mobx.dart';",
      );
      write(
        'lib/features/orders/data/order_store.dart',
        "import 'package:flutter_mobx/flutter_mobx.dart';",
      );
      write(
        'lib/features/orders/orders.dart',
        "export 'package:mobx/mobx.dart';",
      );

      expect(check().map((v) => v.code), ['ARCH008', 'ARCH008', 'ARCH008']);
    },
  );

  test('ARCH008 rejects MobX in shared Domain and application bootstrap', () {
    write('lib/shared/domain/entity.dart', "import 'package:mobx/mobx.dart';");
    write(
      'lib/app/bootstrap/bootstrap.dart',
      "import 'package:flutter_mobx/flutter_mobx.dart';",
    );

    expect(check().map((v) => v.code), ['ARCH008', 'ARCH008']);
  });

  test('ARCH008 rejects MobX in lib/main.dart', () {
    write('lib/main.dart', "import 'package:mobx/mobx.dart';");

    expect(check().single.code, 'ARCH008');
  });

  test('ARCH008 checks conditional imports and exports', () {
    write('lib/features/orders/domain/order.dart', '''
import 'dart:io' if (dart.library.html) 'package:mobx/mobx.dart';
export 'package:flutter_mobx/flutter_mobx.dart';
''');

    final violations = check();
    expect(violations.map((v) => v.code), ['ARCH008', 'ARCH008']);
    expect(violations.map((v) => v.line), [1, 2]);
  });

  test('ARCH008/009 ignore commented imports and generated sources', () {
    write('lib/app/app.dart', '''
// import 'package:get_it/get_it.dart';
const fake = "import 'package:get_it/get_it.dart';";
''');
    write('lib/features/orders/data/ignored.g.dart', '''
import 'package:mobx/mobx.dart';
import 'package:get_it/get_it.dart';
''');
    write(
      'lib/app/generated.config.dart',
      "import 'package:get_it/get_it.dart';",
    );

    expect(check(), isEmpty);
  });

  test('ARCH009 allows GetIt imports only in app bootstrap and DI', () {
    write(
      'lib/app/bootstrap/bootstrap.dart',
      "import 'package:get_it/get_it.dart';",
    );
    write(
      'lib/app/di/dependency_injection.dart',
      "import 'package:get_it/get_it.dart';",
    );

    expect(check(), isEmpty);
  });

  test('ARCH009 rejects GetIt imports outside the composition root', () {
    write(
      'lib/app/theme/theme_view_model.dart',
      "import 'package:get_it/get_it.dart';",
    );
    write('lib/app/app.dart', "import 'package:get_it/get_it.dart';");
    write('lib/main.dart', "import 'package:get_it/get_it.dart';");

    expect(check().map((v) => v.code), ['ARCH009', 'ARCH009', 'ARCH009']);
  });

  test('ARCH009 forbids re-exporting GetIt even from composition root', () {
    write(
      'lib/app/di/dependency_injection.dart',
      "export 'package:get_it/get_it.dart';",
    );

    expect(check().single.code, 'ARCH009');
  });

  test('ARCH009 catches conditional GetIt imports in app', () {
    write('lib/app/environment/app_environment.dart', '''
import 'dart:io'
    if (dart.library.html) 'package:get_it/get_it.dart';
''');

    expect(check().single.code, 'ARCH009');
  });

  test('ARCH003 retains precedence for GetIt in features and shared', () {
    write(
      'lib/features/orders/presentation/order_view.dart',
      "import 'package:get_it/get_it.dart';",
    );
    write(
      'lib/shared/services/locator.dart',
      "export 'package:get_it/get_it.dart';",
    );

    expect(check().map((v) => v.code), ['ARCH003', 'ARCH003']);
  });

  test('checks conditional imports even when the condition is inactive', () {
    write('lib/features/home/home.dart', '''
import 'package:app_flutter/shared/value.dart'
    if (dart.library.io) 'package:app_flutter/app/app.dart';
''');

    expect(check().single.code, 'ARCH001');
  });
}
