import 'package:equatable/equatable.dart';
import 'package:seeds/v2/domain-shared/page_state.dart';

/// STATE
class EditNameState extends Equatable {
  final PageState pageState;
  final String? name;
  final String? errorMessage;

  const EditNameState({
    required this.pageState,
    this.name,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        pageState,
        name,
        errorMessage,
      ];

  EditNameState copyWith({
    PageState? pageState,
    String? name,
    String? errorMessage,
  }) {
    return EditNameState(
      pageState: pageState ?? this.pageState,
      name: name ?? this.name,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  factory EditNameState.initial() {
    return const EditNameState(pageState: PageState.initial);
  }
}
