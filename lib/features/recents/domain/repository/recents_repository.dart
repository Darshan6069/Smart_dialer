import '../entities/recent_call.dart';

abstract class RecentsRepository {
  Future<List<RecentCall>> getRecentCalls();
  Future<void> saveRecentCall(RecentCall call);
  Future<void> deleteRecentCall(String id);
  Future<void> clearRecentCalls();
}
