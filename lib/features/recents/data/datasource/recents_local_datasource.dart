import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/recent_call_model.dart';

abstract class RecentsLocalDataSource {
  Future<List<RecentCallModel>> getRecentCalls();
  Future<void> saveRecentCall(RecentCallModel call);
  Future<void> deleteRecentCall(String id);
  Future<void> clearRecentCalls();
}

class RecentsLocalDataSourceImpl implements RecentsLocalDataSource {
  final Box<RecentCallModel> _recentCallsBox;

  RecentsLocalDataSourceImpl(this._recentCallsBox);

  @override
  Future<List<RecentCallModel>> getRecentCalls() async {
    try {
      final List<RecentCallModel> list = _recentCallsBox.values.toList();
      // Sort recent calls: most recent call first
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    } catch (e) {
      throw CacheException('Failed to retrieve recent calls from cache.');
    }
  }

  @override
  Future<void> saveRecentCall(RecentCallModel call) async {
    try {
      await _recentCallsBox.put(call.id, call);
    } catch (e) {
      throw CacheException('Failed to persist call history.');
    }
  }

  @override
  Future<void> deleteRecentCall(String id) async {
    try {
      await _recentCallsBox.delete(id);
    } catch (e) {
      throw CacheException('Failed to delete recent call entry.');
    }
  }

  @override
  Future<void> clearRecentCalls() async {
    try {
      await _recentCallsBox.clear();
    } catch (e) {
      throw CacheException('Failed to clear call history.');
    }
  }
}
