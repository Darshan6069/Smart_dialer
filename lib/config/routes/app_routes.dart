import 'package:flutter/material.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/call_screen/presentation/screens/call_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String callScreen = '/call_screen';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _premiumRoute(const SplashScreen(), settings);
      case home:
        return _premiumRoute(const HomeScreen(), settings);
      case callScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        return _premiumRoute(
          CallScreen(
            contactName: args?['name'] ?? 'Unknown Number',
            phoneNumber: args?['number'] ?? 'Unknown',
            isIncoming: args?['isIncoming'] ?? false,
            autoRecord: args?['autoRecord'] ?? false,
          ),
          settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  static Route<dynamic> _premiumRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.05);
        const end = Offset.zero;
        const curve = Curves.fastOutSlowIn;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 375),
    );
  }
}
