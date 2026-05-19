import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_loader.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../recording/domain/entities/recorded_call.dart';
import '../../../recording/presentation/cubit/recording_cubit.dart';
import '../../../recording/presentation/cubit/recording_state.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AudioPlayer? _audioPlayer;
  RecordedCall? _currentPlayingCall;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().loadSettings();
    context.read<RecordingCubit>().loadRecordings();
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Recordings'),
      ),
      bottomNavigationBar: _buildBottomAudioPlayer(),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          return settingsState.when(
            initial: () => const CustomLoader(),
            loading: () => const CustomLoader(),
            error: (msg) => Center(child: CustomText.body(msg, color: AppColors.error)),
            loaded: (isDark, isAutoRecord) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('General Preferences'),
                    const SizedBox(height: 12),
                    _buildSettingsCard([
                      _buildSwitchTile(
                        icon: Icons.autorenew_rounded,
                        color: AppColors.success,
                        title: 'Auto Record Calls',
                        subtitle: 'Start recording microphone automatically on calls',
                        value: isAutoRecord,
                        onChanged: (val) => context.read<SettingsCubit>().toggleAutoRecord(val),
                      ),
                    ]),

                    const SizedBox(height: 28),
                    _buildSectionHeader('System Permissions'),
                    const SizedBox(height: 12),
                    _buildSettingsCard([
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.settings_suggest_rounded, color: AppColors.primary, size: 20),
                        ),
                        title: CustomText.title('Manage App Permissions', fontSize: 16, fontWeight: FontWeight.bold),
                        subtitle: CustomText.muted('Open system settings to configure phone, contacts, mic, and dialer options', fontSize: 12),
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                        onTap: () => openAppSettings(),
                      ),
                    ]),
                    
                    const SizedBox(height: 28),
                    _buildSectionHeader('Call Recording Library'),
                    const SizedBox(height: 12),
                    
                    // Display Recordings Inline
                    BlocBuilder<RecordingCubit, RecordingState>(
                      builder: (context, recState) {
                        return recState.when(
                          initial: () => const CustomLoader(size: 32),
                          loading: () => const CustomLoader(size: 32),
                          error: (msg) => CustomText.body(msg, color: AppColors.error),
                          loaded: (recordings, isActive, activeName, activeNumber) {
                            if (recordings.isEmpty) {
                              return _buildEmptyRecordings();
                            }
                            return _buildRecordingsList(recordings);
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: CustomText(
        title.toUpperCase(),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.secondary,
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: CustomText.title(title, fontSize: 16, fontWeight: FontWeight.bold),
      subtitle: CustomText.muted(subtitle, fontSize: 12),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        activeTrackColor: AppColors.primary.withOpacity(0.2),
      ),
    );
  }

  Widget _buildEmptyRecordings() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        children: [
          Icon(Icons.mic_off_rounded, size: 44, color: AppColors.textMuted.withOpacity(0.4)),
          const SizedBox(height: 12),
          CustomText.title('No Call Recordings Yet', fontSize: 15, fontWeight: FontWeight.bold),
          const SizedBox(height: 4),
          CustomText.muted('Your recorded call audios will be archived here', textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildRecordingsList(List<RecordedCall> recordings) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recordings.length,
      itemBuilder: (context, index) {
        final rec = recordings[index];
        final dateStr = DateFormat('MMM d, yyyy - hh:mm a').format(rec.timestamp);
        final sizeMb = (rec.fileSizeInBytes / (1024 * 1024)).toStringAsFixed(2);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 0.8),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.audiotrack_rounded, color: AppColors.error, size: 20),
            ),
            title: CustomText.title(rec.name, fontSize: 15, fontWeight: FontWeight.bold),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                CustomText.muted(rec.number, fontSize: 12),
                const SizedBox(height: 2),
                Row(
                  children: [
                    CustomText.muted(dateStr, fontSize: 11),
                    const SizedBox(width: 8),
                    Container(width: 3, height: 3, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.textMuted)),
                    const SizedBox(width: 8),
                    CustomText.muted('${sizeMb} MB', fontSize: 11),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    (_currentPlayingCall?.id == rec.id && _isPlaying)
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded,
                    color: AppColors.primary,
                    size: 30,
                  ),
                  onPressed: () => _playAudio(rec),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textMuted, size: 20),
                  onPressed: () {
                    if (_currentPlayingCall?.id == rec.id) {
                      _stopAudio();
                    }
                    context.read<RecordingCubit>().removeRecording(rec.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _playAudio(RecordedCall rec) async {
    if (_currentPlayingCall?.id == rec.id) {
      if (_isPlaying) {
        await _audioPlayer?.pause();
        setState(() {
          _isPlaying = false;
        });
      } else {
        await _audioPlayer?.resume();
        setState(() {
          _isPlaying = true;
        });
      }
      return;
    }

    await _audioPlayer?.stop();
    _audioPlayer ??= AudioPlayer();

    _audioPlayer!.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _audioPlayer!.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _audioPlayer!.onPlayerStateChanged.listen((s) {
      if (mounted) {
        setState(() {
          _isPlaying = s == PlayerState.playing;
        });
      }
    });

    try {
      await _audioPlayer!.play(DeviceFileSource(rec.filePath));
      setState(() {
        _currentPlayingCall = rec;
        _isPlaying = true;
        _position = Duration.zero;
        _duration = Duration.zero;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText('Failed to play audio: $e', color: Colors.white),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer?.pause();
    setState(() {
      _isPlaying = false;
    });
  }

  Future<void> _stopAudio() async {
    await _audioPlayer?.stop();
    setState(() {
      _currentPlayingCall = null;
      _isPlaying = false;
      _position = Duration.zero;
      _duration = Duration.zero;
    });
  }

  Widget? _buildBottomAudioPlayer() {
    if (_currentPlayingCall == null) return null;

    final sizeMb = (_currentPlayingCall!.fileSizeInBytes / (1024 * 1024)).toStringAsFixed(2);
    final totalMinSec = _formatDuration(_duration);
    final currentMinSec = _formatDuration(_position);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.music_note_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText.title(_currentPlayingCall!.name, fontSize: 15, fontWeight: FontWeight.bold),
                      CustomText.muted('${_currentPlayingCall!.number} • $sizeMb MB', fontSize: 11),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  onPressed: _stopAudio,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CustomText.muted(currentMinSec, fontSize: 11),
                Expanded(
                  child: () {
                    final double posMs = _position.inMilliseconds.toDouble();
                    final double durMs = _duration.inMilliseconds.toDouble();
                    final double maxMs = durMs > 0 ? durMs : (posMs > 100.0 ? posMs : 100.0);
                    final double clampedValue = posMs.clamp(0.0, maxMs);
                    return Slider(
                      value: clampedValue,
                      min: 0.0,
                      max: maxMs,
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.border,
                      onChanged: (val) {
                        _audioPlayer?.seek(Duration(milliseconds: val.toInt()));
                      },
                    );
                  }(),
                ),
                CustomText.muted(totalMinSec, fontSize: 11),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.replay_10_rounded, color: AppColors.textPrimary, size: 28),
                  onPressed: () {
                    final newPos = _position - const Duration(seconds: 10);
                    _audioPlayer?.seek(newPos < Duration.zero ? Duration.zero : newPos);
                  },
                ),
                const SizedBox(width: 16),
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () {
                      if (_isPlaying) {
                        _pauseAudio();
                      } else {
                        _playAudio(_currentPlayingCall!);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.forward_10_rounded, color: AppColors.textPrimary, size: 28),
                  onPressed: () {
                    final newPos = _position + const Duration(seconds: 10);
                    _audioPlayer?.seek(newPos > _duration ? _duration : newPos);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final min = d.inMinutes;
    final sec = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$min:$sec';
  }
}
