import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../../settings/presentation/cubit/settings_state.dart';
import '../../../call_screen/presentation/cubit/call_screen_cubit.dart';
import '../cubit/dialer_cubit.dart';
import '../cubit/dialer_state.dart';

class DialerScreen extends StatefulWidget {
  const DialerScreen({super.key});

  @override
  State<DialerScreen> createState() => _DialerScreenState();
}

class _DialerScreenState extends State<DialerScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DialerCubit>().checkSystemDialerStatus();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        context.read<DialerCubit>().checkSystemDialerStatus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DialerCubit, DialerState>(
      listener: (context, state) {
        state.maybeWhen(
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: CustomText(message, color: Colors.white),
                backgroundColor: AppColors.error,
              ),
            );
          },
          orElse: () {},
        );
      },
      child: BlocBuilder<DialerCubit, DialerState>(
        builder: (context, state) {
          final inputNumber = state.maybeWhen(
            typing: (number, _, __) => number,
            orElse: () => '',
          );

          final searchResults = state.maybeWhen(
            typing: (_, results, __) => results,
            orElse: () => const [],
          );

          final isSystemDialer = state.maybeWhen(
            empty: (isSys) => isSys,
            typing: (_, __, isSys) => isSys,
            orElse: () => false,
          );

          final hasQuery = inputNumber.isNotEmpty;

          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  // 1. T9 autocompletion results matching the text
                  Expanded(
                    child: hasQuery
                        ? _buildSearchResults(context, searchResults)
                        : _buildDialerPlaceholder(),
                  ),

                  // 2. Active dial display output
                  if (hasQuery) _buildNumberDisplay(context, inputNumber),

                  // 3. System dialer helper status card
                  if (!isSystemDialer) _buildDialerPermissionCard(context),

                  // 4. Elegant Glowing Keypad Grid
                  _buildKeypadGrid(context, inputNumber),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, List<dynamic> results) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search_rounded, size: 48, color: AppColors.textMuted.withOpacity(0.5)),
            const SizedBox(height: 8),
            CustomText.muted('No speed-dial matches'),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final contact = results[index];
        final phone = contact.phones.isNotEmpty ? contact.phones.first : '';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: contact.photoBytes != null ? MemoryImage(contact.photoBytes!) : null,
              child: contact.photoBytes == null
                  ? CustomText(
                      contact.displayName.substring(0, 1).toUpperCase(),
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    )
                  : null,
            ),
            title: CustomText.title(contact.displayName, fontSize: 16),
            subtitle: CustomText.muted(phone),
            trailing: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: IconButton(
                icon: const Icon(Icons.phone_rounded, color: Colors.white, size: 20),
                onPressed: () => _initiateCall(context, contact.displayName, phone),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialerPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: const Icon(Icons.dialpad_rounded, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          CustomText.title('Type a phone number', fontWeight: FontWeight.bold),
          const SizedBox(height: 4),
          CustomText.muted('T9 speed dial lookup searches your contact list'),
        ],
      ),
    );
  }

  Widget _buildNumberDisplay(BuildContext context, String inputNumber) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 48), // Spacer balance
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: CustomText(
                inputNumber,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.backspace_outlined, color: AppColors.error, size: 22),
            onPressed: () => context.read<DialerCubit>().removeDigit(),
          ),
        ],
      ),
    );
  }

  Widget _buildDialerPermissionCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withOpacity(0.12),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.security_rounded, color: AppColors.secondary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText('Set Default Dialer', fontSize: 14, fontWeight: FontWeight.bold),
                const SizedBox(height: 2),
                CustomText.muted('Required for outgoing & incoming call management', fontSize: 11),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => context.read<DialerCubit>().requestSystemDialer(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 4,
              shadowColor: AppColors.primary.withOpacity(0.3),
            ),
            child: const CustomText(
              'SET',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildKeypadGrid(BuildContext context, String number) {
    final List<Map<String, String>> keys = [
      {'digit': '1', 'letters': 'o_o'},
      {'digit': '2', 'letters': 'A B C'},
      {'digit': '3', 'letters': 'D E F'},
      {'digit': '4', 'letters': 'G H I'},
      {'digit': '5', 'letters': 'J K L'},
      {'digit': '6', 'letters': 'M N O'},
      {'digit': '7', 'letters': 'P Q R S'},
      {'digit': '8', 'letters': 'T U V'},
      {'digit': '9', 'letters': 'W X Y Z'},
      {'digit': '*', 'letters': ''},
      {'digit': '0', 'letters': '+'},
      {'digit': '#', 'letters': ''},
    ];

    return Container(
      padding: const EdgeInsets.only(left: 32, right: 32, bottom: 20, top: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 12,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.45,
              crossAxisSpacing: 16,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final key = keys[index];
              return InkWell(
                onTap: () => context.read<DialerCubit>().addDigit(key['digit']!),
                onLongPress: key['digit'] == '0'
                    ? () => context.read<DialerCubit>().addDigit('+')
                    : null,
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 0.8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(
                        key['digit']!,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      if (key['letters']!.isNotEmpty)
                        CustomText(
                          key['letters']!,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Call activation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 48), // Balance spacer
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00E676), Color(0xFF00B0FF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E676).withOpacity(0.3),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.phone_rounded, color: Colors.white, size: 32),
                  onPressed: number.isNotEmpty
                      ? () => _initiateCall(context, '', number)
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              if (number.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.cancel_rounded, color: AppColors.textMuted, size: 28),
                  onPressed: () => context.read<DialerCubit>().clearDialer(),
                )
              else
                const SizedBox(width: 32),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _initiateCall(BuildContext context, String name, String number) async {
    final status = await Permission.phone.request();
    if (!status.isGranted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: CustomText('Phone permission is required to place system calls.', color: Colors.white),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    final settingsCubit = context.read<SettingsCubit>();
    final settingsState = settingsCubit.state;
    final autoRecord = settingsState.maybeWhen(
      loaded: (isDarkTheme, isAutoRecord) => isAutoRecord,
      orElse: () => false,
    );

    if (!context.mounted) return;

    // Trigger native call connection intent
    context.read<DialerCubit>().makeCall(number);

    Navigator.pushNamed(
      context,
      AppRoutes.callScreen,
      arguments: {
        'name': name.isEmpty ? number : name,
        'number': number,
        'isIncoming': false,
        'autoRecord': autoRecord,
      },
    );
  }
}
