import 'package:equatable/equatable.dart';

enum PageState { scan, processing, success, stop }

class ScannerState extends Equatable {
  final PageState pageState;

  const ScannerState({
    required this.pageState,
  });

  @override
  List<Object> get props => [pageState];

  ScannerState copyWith({
    PageState? pageState,
  }) {
    return ScannerState(
      pageState: pageState ?? this.pageState,
    );
  }

  factory ScannerState.initial() {
    return const ScannerState(
      pageState: PageState.scan,
    );
  }
}
