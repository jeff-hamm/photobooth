import 'package:auto_route/auto_route.dart';
import 'package:io_photobooth/app/router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        /// routes go here
        AutoRoute(page: LandingRoute.page, initial: true, path: "/"
            //   transitionsBuilder: (context, animation, secondaryAnimation, child) {
            //   // Define your custom transition here
            //   return FadeTransition(opacity: animation, child: child);
            // }
            ),
        AutoRoute(page: PhotoboothRoute.page, path: "/booth", children: [
          AutoRoute(page: PhotobothViewRoute.page, path: 'preview'),
          AutoRoute(page: PickerRoute.page, path: 'picker'),
          AutoRoute(page: StickersRoute.page, path: 'stickers'),
          AutoRoute(page: ShareRoute.page, path: 'share'),
        ])
      ];
}
// final appRouter = GoRouter(
//   routes: [
//     GoRoute(
//       path: '/',
//       builder: (context, state) => const LandingPage(),
//     ),
//     GoRoute(
//       path: '/booth',
//       builder: (context, state) => const PhotoboothPage(),
//       routes: [
//         GoRoute(
//           path: 'stickers',
//           builder: (context, state) => const StickersPage(),
//         ),
//       ]
//     ),
//     GoRoute(
//       path: '/share',
//       builder: (context, state) => const SharePage(),
//     )
//   ],
// );
