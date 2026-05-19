import '../entities/recent_call.dart';
import '../repository/recents_repository.dart';

class SaveRecentCallUseCase {
  final RecentsRepository repository;

  SaveRecentCallUseCase(this.repository);

  Future<void> call(RecentCall recentCall) async {
    await repository.saveRecentCall(recentCall);
  }
}
