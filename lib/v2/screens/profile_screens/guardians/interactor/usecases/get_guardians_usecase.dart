import 'package:seeds/v2/datasource/local/settings_storage.dart';
import 'package:seeds/v2/datasource/remote/api/members_repository.dart';
import 'package:seeds/v2/datasource/remote/firebase/firebase_database_guardians_repository.dart';
import 'package:seeds/v2/datasource/remote/model/firebase_models/guardian_model.dart';
import 'package:seeds/v2/datasource/remote/model/member_model.dart';

class GetGuardiansUseCase {
  final FirebaseDatabaseGuardiansRepository _repository = FirebaseDatabaseGuardiansRepository();
  final MembersRepository _membersRepository = MembersRepository();

  Stream<List<GuardianModel>> getGuardians() {
    return _repository
        .getGuardiansForUser(settingsStorage.accountName)
        .asyncMap((List<GuardianModel> event) => getMemberData(event));
  }

  Future<List<GuardianModel>> getMemberData(List<GuardianModel> guardians) async {
    Iterable<Future<Result>> futures =
        guardians.map((GuardianModel e) => _membersRepository.getMemberByAccountName(e.uid));
    List<Result> results = await Future.wait(futures);
    Iterable<Result<dynamic>> filtered = results.where((Result element) => element.isValue);

    return guardians.map((GuardianModel guardian) => mapGuardian(guardian, filtered)).toList();
  }

  GuardianModel mapGuardian(GuardianModel guardian, Iterable<Result<dynamic>> filtered) {
    MemberModel match = filtered.firstWhere((element) => element.asValue!.value.account == guardian.uid).asValue!.value;

    return guardian.copyWith(image: match.image, nickname: match.nickname);
  }
}
