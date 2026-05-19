import '../repository/recents_repository.dart';

class ClearRecentCallsUseCase {
  final RecentsRepository repository;

  ClearRecentCallsUseCase(this.repository);

  Future<void> call() async {
    await repository.clearRecentCalls();
  }
}
