import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:seeds/v2/datasource/remote/firebase/firebase_database_repository.dart';
import 'package:seeds/v2/datasource/remote/model/firebase_models/guardian_model.dart';

class FirebaseDatabaseGuardiansRepository extends FirebaseDatabaseService {
  Stream<bool> hasGuardianNotificationPending(String userAccount) {
    bool _findNotification(QuerySnapshot event) {
      QueryDocumentSnapshot? guardianNotification = event.docs.firstWhereOrNull(
        (QueryDocumentSnapshot? element) => element?.id == GUARDIAN_NOTIFICATION_KEY,
      );

      if (guardianNotification == null) {
        return false;
      } else {
        return guardianNotification[GUARDIAN_NOTIFICATION_KEY];
      }
    }

    return usersCollection
        .doc(userAccount)
        .collection(PENDING_NOTIFICATIONS_KEY)
        .snapshots()
        .map((event) => _findNotification(event));
  }

  Stream<List<GuardianModel>> getGuardiansForUser(String userId) {
    return usersCollection.doc(userId).collection(GUARDIANS_COLLECTION_KEY).snapshots().asyncMap(
        (QuerySnapshot event) => event.docs
            .map(
                (QueryDocumentSnapshot e) => GuardianModel.fromMap(e.data()!)) // ignore: unnecessary_non_null_assertion
            .toList());
  }

  Stream<bool> isGuardiansInitialized(String userAccount) {
    return usersCollection
        .doc(userAccount)
        .snapshots()
        .map((user) => user.data()?[GUARDIAN_CONTRACT_INITIALIZED] ?? false);
  }
}
