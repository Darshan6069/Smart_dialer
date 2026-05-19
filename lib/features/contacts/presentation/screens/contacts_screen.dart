import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_loader.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../dialer/presentation/cubit/dialer_cubit.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../domain/entities/contact_entity.dart';
import '../cubit/contacts_cubit.dart';
import '../cubit/contacts_state.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ContactsCubit>().loadContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: Column(
        children: [
          // Elegant Search Input Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => context.read<ContactsCubit>().searchContacts(val),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                hintText: 'Search contacts by name or phone...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted),
                  onPressed: () {
                    _searchController.clear();
                    context.read<ContactsCubit>().loadContacts();
                  },
                ),
              ),
            ),
          ),
          
          Expanded(
            child: BlocBuilder<ContactsCubit, ContactsState>(
              builder: (context, state) {
                return state.when(
                  initial: () => const CustomLoader(),
                  loading: () => const CustomLoader(),
                  error: (msg) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.contact_phone_rounded, size: 64, color: AppColors.error.withOpacity(0.4)),
                          const SizedBox(height: 16),
                          CustomText.title('Access Denied', fontWeight: FontWeight.bold),
                          const SizedBox(height: 8),
                          CustomText.muted(
                            'Please grant contacts permission in Settings to load device address books.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                           ElevatedButton(
                            onPressed: () async {
                              final status = await Permission.contacts.request();
                              if (status.isGranted) {
                                if (context.mounted) {
                                  context.read<ContactsCubit>().loadContacts();
                                }
                              } else if (status.isPermanentlyDenied) {
                                openAppSettings();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const CustomText(
                              'Retry Authorization',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  loaded: (contacts) {
                    if (contacts.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline_rounded, size: 54, color: AppColors.textMuted.withOpacity(0.5)),
                            const SizedBox(height: 8),
                            CustomText.muted('No contacts found'),
                          ],
                        ),
                      );
                    }
                    return _buildContactsList(contacts);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList(List<ContactEntity> contacts) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        final phone = contact.phones.isNotEmpty ? contact.phones.first : 'No Phone Number';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 0.8),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: contact.photoBytes != null ? MemoryImage(contact.photoBytes!) : null,
              child: contact.photoBytes == null
                  ? CustomText(
                      contact.displayName.isNotEmpty
                          ? contact.displayName.substring(0, 1).toUpperCase()
                          : '?',
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    )
                  : null,
            ),
            title: CustomText.title(
              contact.displayName.isEmpty ? 'Unnamed Contact' : contact.displayName,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            subtitle: CustomText.muted(phone),
            trailing: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: IconButton(
                icon: const Icon(Icons.phone_rounded, color: Colors.white, size: 18),
                onPressed: contact.phones.isNotEmpty
                    ? () async {
                        final status = await Permission.phone.request();
                        if (!status.isGranted) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: CustomText('Phone permission is required to make calls.', color: Colors.white),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                          return;
                        }

                        if (!context.mounted) return;

                        // 1. Fetch automatic call recording preference
                        final autoRecord = context.read<SettingsCubit>().state.maybeWhen(
                              loaded: (_, record) => record,
                              orElse: () => false,
                            );

                        // 2. Trigger native calling intent
                        context.read<DialerCubit>().makeCall(phone);

                        // 3. Open CallScreen UI
                        Navigator.pushNamed(
                          context,
                          AppRoutes.callScreen,
                          arguments: {
                            'name': contact.displayName,
                            'number': phone,
                            'isIncoming': false,
                            'autoRecord': autoRecord,
                          },
                        );
                      }
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}
