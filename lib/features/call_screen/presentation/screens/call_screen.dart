import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text.dart';
import '../cubit/call_screen_cubit.dart';
import '../cubit/call_screen_state.dart';

class CallScreen extends StatefulWidget {
  final String contactName;
  final String phoneNumber;
  final bool isIncoming;
  final bool autoRecord;

  const CallScreen({
    super.key,
    required this.contactName,
    required this.phoneNumber,
    this.isIncoming = false,
    this.autoRecord = false,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    _glowAnimation = Tween<double>(begin: 12.0, end: 28.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start native connection setup
    context.read<CallScreenCubit>().startCall(
      widget.contactName,
      widget.phoneNumber,
      widget.isIncoming,
      widget.autoRecord,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CallScreenCubit, CallScreenState>(
      listener: (context, state) {
        state.maybeWhen(idle: () => Navigator.pop(context), orElse: () {});
      },
      builder: (context, state) {
        final isMuted = state.maybeWhen(
          dialing: (name, number, isMuted, isSpeakerOn) => isMuted,
          ringing: (name, number, isMuted, isSpeakerOn) => isMuted,
          inCall:
              (
                name,
                number,
                durationSeconds,
                isMuted,
                isSpeakerOn,
                isRecording,
              ) => isMuted,
          orElse: () => false,
        );

        final isSpeakerOn = state.maybeWhen(
          dialing: (name, number, isMuted, isSpeakerOn) => isSpeakerOn,
          ringing: (name, number, isMuted, isSpeakerOn) => isSpeakerOn,
          inCall:
              (
                name,
                number,
                durationSeconds,
                isMuted,
                isSpeakerOn,
                isRecording,
              ) => isSpeakerOn,
          orElse: () => false,
        );

        final isRecording = state.maybeWhen(
          inCall:
              (
                name,
                number,
                durationSeconds,
                isMuted,
                isSpeakerOn,
                isRecording,
              ) => isRecording,
          orElse: () => false,
        );

        final durationSeconds = state.maybeWhen(
          inCall:
              (
                name,
                number,
                durationSeconds,
                isMuted,
                isSpeakerOn,
                isRecording,
              ) => durationSeconds,
          ended: (name, number, durationSeconds, message) => durationSeconds,
          orElse: () => 0,
        );

        final name = state.maybeWhen(
          dialing: (name, number, isMuted, isSpeakerOn) => name,
          ringing: (name, number, isMuted, isSpeakerOn) => name,
          inCall:
              (
                name,
                number,
                durationSeconds,
                isMuted,
                isSpeakerOn,
                isRecording,
              ) => name,
          ended: (name, number, durationSeconds, message) => name,
          orElse: () => widget.contactName,
        );

        final number = state.maybeWhen(
          dialing: (name, number, isMuted, isSpeakerOn) => number,
          ringing: (name, number, isMuted, isSpeakerOn) => number,
          inCall:
              (
                name,
                number,
                durationSeconds,
                isMuted,
                isSpeakerOn,
                isRecording,
              ) => number,
          ended: (name, number, durationSeconds, message) => number,
          orElse: () => widget.phoneNumber,
        );

        final formattedTime = _formatTime(durationSeconds);
        final bool isCallActive = state.maybeWhen(
          inCall: (_, __, dur, ___, ____, _____) => dur > 1,
          orElse: () => false,
        );

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFF141724), Color(0xFF090A10)],
                center: Alignment(0, -0.4),
                radius: 1.3,
              ),
            ),
            child: Stack(
              children: [
                // 1. Fluid Ambient Backdrops
                _buildAmbientLights(isRecording),

                // 2. Main Call Overlay Layer
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 28,
                    ),
                    child: Column(
                      children: [
                        // Live Status Badge or Call Recording Indicator
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: isRecording
                              ? _buildRecordingBadge()
                              : const SizedBox(height: 32),
                        ),
                        const Spacer(),

                        // Premium Double-Ring Avatar HUD
                        _buildGlowAvatarHUD(name, isRecording, isCallActive),
                        const SizedBox(height: 40),

                        // Contact Metadata Card
                        CustomText(
                          name,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        CustomText(
                          number,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF8F9BB3),
                        ),
                        const SizedBox(height: 20),

                        // Animated Waveform Status Display
                        _buildCallStatusWidget(
                          state,
                          formattedTime,
                          isCallActive,
                        ),
                        const Spacer(),

                        // Premium Glassmorphic Controls Grid
                        _buildControlsGrid(
                          context,
                          isMuted,
                          isSpeakerOn,
                          isRecording,
                          name,
                          number,
                        ),
                        const SizedBox(height: 40),

                        // Layered Primary End Call Button
                        _buildEndCallButton(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAmbientLights(bool isRecording) {
    final activeColor = isRecording ? AppColors.error : AppColors.primary;
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: 120,
              left: -80,
              child: Container(
                key: ValueKey(isRecording),
                width: 300 + (_pulseController.value * 50),
                height: 300 + (_pulseController.value * 50),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activeColor.withOpacity(
                    0.03 + (_pulseController.value * 0.02),
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            Positioned(
              top: 240,
              right: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withOpacity(
                    0.02 + (_pulseController.value * 0.02),
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGlowAvatarHUD(String name, bool isRecording, bool isCallActive) {
    final accentColor = isRecording ? AppColors.error : AppColors.secondary;
    final ringColor = isCallActive ? AppColors.success : AppColors.primary;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Center(
          child: Container(
            width: 170,
            height: 170,
            alignment: CenterPlayState,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer Pulse Ring
                Container(
                  width: 140 + (_pulseController.value * 24),
                  height: 140 + (_pulseController.value * 24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accentColor.withOpacity(
                        0.2 - (_pulseController.value * 0.15),
                      ),
                      width: 1.5,
                    ),
                  ),
                ),
                // Inner Glowing Ring
                Container(
                  width: 136,
                  height: 136,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ringColor.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ringColor.withOpacity(0.12),
                        blurRadius: _glowAnimation.value,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                // Premium Glassmorphic Core Container
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1E2230).withOpacity(0.4),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                        width: 1.2,
                      ),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Center(
                        child: Text(
                          name.isNotEmpty
                              ? name.substring(0, 1).toUpperCase()
                              : 'U',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                            color: accentColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCallStatusWidget(
    CallScreenState state,
    String formattedTime,
    bool isCallActive,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Glassmorphic Status Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isCallActive) ...[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                CustomText(
                  state.maybeWhen(
                    dialing: (_, __, ___, ____) => 'CALLING...',
                    ringing: (_, __, ___, ____) => 'RINGING...',
                    ended: (_, __, ___, ____) => 'CALL ENDED',
                    inCall: (_, __, dur, ___, ____, _____) {
                      return formattedTime;
                    },
                    orElse: () => 'CONNECTING...',
                  ),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: state.maybeWhen(
                    ended: (_, __, ___, ____) => AppColors.error,
                    inCall: (_, __, dur, ___, ____, _____) {
                      return AppColors.success;
                    },
                    orElse: () => const Color(0xFF00B0FF),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Simulated Real-Time Audio Waves
        if (isCallActive) _buildLiveWaveform() else const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLiveWaveform() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final double baseHeight = 6.0 + (index * 4.0);
            final double finalHeight =
                baseHeight + (_pulseController.value * (16.0 - index * 2.0));
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 3.5,
              height: finalHeight.clamp(4.0, 24.0),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(
                  0.6 + (_pulseController.value * 0.4),
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildControlsGrid(
    BuildContext context,
    bool isMuted,
    bool isSpeakerOn,
    bool isRecording,
    String name,
    String number,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildGlassControl(
              icon: isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
              label: 'Mute',
              isActive: isMuted,
              onTap: () => context.read<CallScreenCubit>().toggleMute(),
            ),
            _buildGlassControl(
              icon: isSpeakerOn
                  ? Icons.volume_up_rounded
                  : Icons.volume_down_rounded,
              label: 'Speaker',
              isActive: isSpeakerOn,
              onTap: () => context.read<CallScreenCubit>().toggleSpeaker(),
            ),
            _buildGlassControl(
              icon: Icons.fiber_manual_record_rounded,
              label: isRecording ? 'Recording' : 'Record',
              isActive: isRecording,
              activeColor: AppColors.error,
              onTap: () {
                if (isRecording) {
                  context.read<CallScreenCubit>().stopRecording();
                } else {
                  context.read<CallScreenCubit>().startRecording(name, number);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassControl({
    required IconData icon,
    required String label,
    required bool isActive,
    Color? activeColor,
    required VoidCallback onTap,
  }) {
    final actColor = activeColor ?? AppColors.secondary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(100),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? actColor.withOpacity(0.18)
                    : Colors.white.withOpacity(0.04),
                border: Border.all(
                  color: isActive ? actColor : Colors.white.withOpacity(0.08),
                  width: 1.2,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: actColor.withOpacity(0.2),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                color: isActive ? actColor : Colors.white.withOpacity(0.7),
                size: 26,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        CustomText(
          label,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.white : const Color(0xFF8F9BB3),
        ),
      ],
    );
  }

  Widget _buildEndCallButton(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Concentric Ambient Shadow Ring
              Container(
                width: 82 + (_pulseController.value * 12),
                height: 82 + (_pulseController.value * 12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.error.withOpacity(
                    0.08 - (_pulseController.value * 0.06),
                  ),
                ),
              ),
              // Main Button Ring
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF1744), Color(0xFFFF5252)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF1744).withOpacity(0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.read<CallScreenCubit>().endCall(),
                    borderRadius: BorderRadius.circular(100),
                    child: const Icon(
                      Icons.call_end_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecordingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.error,
            ),
          ),
          const SizedBox(width: 8),
          const CustomText(
            'REC ACTIVE',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
        ],
      ),
    );
  }

  String _formatTime(int totalSecs) {
    final mins = totalSecs ~/ 60;
    final secs = totalSecs % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Alignment get CenterPlayState => Alignment.center;
}
