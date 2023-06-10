
import 'package:rushcash/services/bazaar_service.dart';
import 'package:rushcash/services/person_service.dart';
import 'package:rushcash/services/saved_qr_service.dart';

class InitService {
  static bool isInited = false;
  static bool isIniting = false;

  static Future init({bool force = false}) async {
    if ((isIniting || isInited) && !force) {
      return;
    }
    isIniting = true;
    await PersonService.initPerson();
    DateTime now = DateTime.now();
    List<Future> toDo = [
      BazaarService.initBazaar(now: now),
    ];
    await Future.wait(toDo);
    isInited = true;
    isIniting = false;
  }

  static cleanCache() {
    isInited = false;
    isIniting = false;
  }
}