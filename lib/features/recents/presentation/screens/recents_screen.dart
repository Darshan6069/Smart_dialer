import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_loader.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../domain/entities/recent_call.dart';
import '../cubit/recents_cubit.dart';
import '../cubit/recents_state.dart';

class RecentsScreen extends StatefulWidget {
  const RecentsScreen({super.key});

  @override
  State<RecentsScreen> createState() => _RecentsScreenState();
}

class _RecentsScreenState extends State<RecentsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RecentsCubit>().loadRecentCalls();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Calls'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.textSecondary),
            onPressed: () => _confirmClearHistory(context),
          ),
        ],
      ),
      body: BlocBuilder<RecentsCubit, RecentsState>(
        builder: (context, state) {
          return state.when(
            initial: () => const CustomLoader(),
            loading: () => const CustomLoader(),
            error: (message) => Center(child: CustomText.body('Error: $message', color: AppColors.error)),
            loaded: (calls) {
              if (calls.isEmpty) {
                return _buildEmptyState();
              }
              return _buildCallsList(calls);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.call_missed_outgoing_rounded, size: 64, color: AppColors.textMuted.withOpacity(0.4)),
          const SizedBox(height: 16),
          CustomText.title('Call History is Clean', fontWeight: FontWeight.bold),
          const SizedBox(height: 4),
          CustomText.muted('Your incoming and outgoing calls show up here'),
        ],
      ),
    );
  }

  Widget _buildCallsList(List<RecentCall> calls) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: calls.length,
      itemBuilder: (context, index) {
        final call = calls[index];
        final timeStr = DateFormat('MMM dd, hh:mm a').format(call.timestamp);
        final durStr = _formatDuration(call.durationInSeconds);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 0.8),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: _getCallTypeColor(call.type).withOpacity(0.1),
              child: Icon(
                _getCallTypeIcon(call.type),
                color: _getCallTypeColor(call.type),
                size: 20,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: CustomText.title(
                    call.name.isEmpty ? call.number : call.name,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (call.isRecorded)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error.withOpacity(0.3), width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.mic_rounded, color: AppColors.error, size: 10),
                        const SizedBox(width: 2),
                        CustomText('REC', fontSize: 9, color: AppColors.error, fontWeight: FontWeight.bold),
                      ],
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                CustomText.muted(call.number),
                const SizedBox(height: 2),
                Row(
                  children: [
                    CustomText.muted(timeStr),
                    const SizedBox(width: 8),
                    Container(width: 4, height: 4, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.textMuted)),
                    const SizedBox(width: 8),
                    CustomText.muted(durStr),
                  ],
                ),
              ],
            ),
            trailing: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cardBg,
                border: Border.all(color: AppColors.border, width: 0.8),
              ),
              child: IconButton(
                icon: const Icon(Icons.phone_rounded, color: AppColors.success, size: 18),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.callScreen,
                    arguments: {
                      'name': call.name,
                      'number': call.number,
                      'isIncoming': false,
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getCallTypeIcon(CallType type) {
    switch (type) {
      case CallType.incoming:
        return Icons.call_received_rounded;
      case CallType.outgoing:
        return Icons.call_made_rounded;
      case CallType.missed:
        return Icons.call_missed_rounded;
    }
  }

  Color _getCallTypeColor(CallType type) {
    switch (type) {
      case CallType.incoming:
        return AppColors.success;
      case CallType.outgoing:
        return AppColors.primary;
      case CallType.missed:
        return AppColors.error;
    }
  }

  String _formatDuration(int seconds) {
    if (seconds == 0) return 'Missed';
    final duration = Duration(seconds: seconds);
    final mins = duration.inMinutes;
    final secs = duration.inSeconds % 60;
    if (mins == 0) return '${secs}s';
    return '${mins}m ${secs}s';
  }

  void _confirmClearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: CustomText.title('Clear call history?', fontWeight: FontWeight.bold),
        content: CustomText.body('This action will delete all call logs permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: CustomText.body('Cancel', color: AppColors.textSecondary),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<RecentsCubit>().clearHistory();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
