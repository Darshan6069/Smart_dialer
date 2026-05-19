import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../contacts/presentation/screens/contacts_screen.dart';
import '../../../dialer/presentation/screens/dialer_screen.dart';
import '../../../recents/presentation/screens/recents_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const DialerScreen(),
      const RecentsScreen(),
      const ContactsScreen(),
      const SettingsScreen(),
    ];

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final selectedIndex = state.currentTabIndex;

        return Scaffold(
          body: screens[selectedIndex],
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.border, width: 0.8),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (index) => context.read<HomeCubit>().changeTab(index),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dialpad_rounded),
                  activeIcon: Icon(Icons.dialpad_rounded, color: AppColors.primary),
                  label: 'Dialer',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.call_rounded),
                  activeIcon: Icon(Icons.call_rounded, color: AppColors.primary),
                  label: 'Recents',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_alt_rounded),
                  activeIcon: Icon(Icons.people_alt_rounded, color: AppColors.primary),
                  label: 'Contacts',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_rounded),
                  activeIcon: Icon(Icons.settings_rounded, color: AppColors.primary),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
