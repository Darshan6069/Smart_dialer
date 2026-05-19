import '../entities/recent_call.dart';
import '../repository/recents_repository.dart';

class GetRecentCallsUseCase {
  final RecentsRepository repository;

  GetRecentCallsUseCase(this.repository);

  Future<List<RecentCall>> call() async {
    return await repository.getRecentCalls();
  }
}
