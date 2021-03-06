import 'package:equatable/equatable.dart';
import 'package:seeds/v2/datasource/remote/model/profile_model.dart';
import 'package:seeds/v2/domain-shared/page_state.dart';

class ImportKeyState extends Equatable {
  final PageState pageState;
  final String? errorMessage;
  final String? privateKey;
  final List<ProfileModel> accounts;

  const ImportKeyState({required this.pageState, this.errorMessage, required this.accounts, this.privateKey});

  @override
  List<Object> get props => [pageState];

  ImportKeyState copyWith({
    PageState? pageState,
    String? errorMessage,
    List<ProfileModel>? accounts,
    String? privateKey,
  }) {
    return ImportKeyState(
      pageState: pageState ?? this.pageState,
      errorMessage: errorMessage ?? this.errorMessage,
      accounts: accounts ?? this.accounts,
      privateKey: privateKey ?? this.privateKey,
    );
  }

  factory ImportKeyState.initial() {
    return const ImportKeyState(pageState: PageState.initial, accounts: []);
  }
}
