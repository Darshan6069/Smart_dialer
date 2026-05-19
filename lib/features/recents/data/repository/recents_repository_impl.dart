import '../../domain/entities/recent_call.dart';
import '../../domain/repository/recents_repository.dart';
import '../datasource/recents_local_datasource.dart';
import '../models/recent_call_model.dart';

class RecentsRepositoryImpl implements RecentsRepository {
  final RecentsLocalDataSource localDataSource;

  RecentsRepositoryImpl({required this.localDataSource});

  @override
  Future<List<RecentCall>> getRecentCalls() async {
    final models = await localDataSource.getRecentCalls();
    return models;
  }

  @override
  Future<void> saveRecentCall(RecentCall call) async {
    final model = RecentCallModel.fromEntity(call);
    await localDataSource.saveRecentCall(model);
  }

  @override
  Future<void> deleteRecentCall(String id) async {
    await localDataSource.deleteRecentCall(id);
  }

  @override
  Future<void> clearRecentCalls() async {
    await localDataSource.clearRecentCalls();
  }
}
