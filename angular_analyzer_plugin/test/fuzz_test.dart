import 'dart:async';

import 'package:angular_analyzer_plugin/src/model.dart';

import 'abstract_angular.dart';
import 'fuzz_util.dart';

void main() {
  new FuzzTest().test_fuzz_continually();
}

class FuzzTest extends AbstractAngularTest {
  final FuzzCaseProducer fuzzProducer = new FuzzCaseProducer();

  // ignore: non_constant_identifier_names
  Future test_fuzz_continually() async {
    const iters = 1000000;
    for (var i = 0; i < iters; ++i) {
      final nextCase = fuzzProducer.nextCase;
      print("Fuzz $i: ${nextCase.transformCount} transforms");
      await checkNoCrash(nextCase.dart, nextCase.html);
    }
  }

  Future checkNoCrash(String dart, String html) {
    final zoneCompleter = new Completer<Null>();
    var complete = false;
    final reason =
        '<<==DART CODE==>>\n$dart\n<<==HTML CODE==>>\n$html\n<<==DONE==>>';

    runZoned(() {
      super.setUp();
      newSource('/test.dart', dart);
      newSource('/test.html', html);
      final resultFuture =
          angularDriver.resolveDart('/test.dart').then((result) {
        if (result.directives.isNotEmpty) {
          final directive = result.directives.first;
          if (directive is Component &&
              directive.view?.templateUriSource?.fullName == '/test.html') {
            return angularDriver.resolveHtml('/test.html');
          }
        }
      });
      Future.wait([resultFuture]).then((_) {
        zoneCompleter.complete();
        complete = true;
      });
    }, onError: (e, stacktrace) {
      print("Fuzz Failure \n$reason\n$e\n$stacktrace");
      if (!complete) {
        zoneCompleter.complete();
        complete = true;
      }
    });

    return zoneCompleter.future;
  }
}
