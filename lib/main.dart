import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/credit_detail_screen.dart';
import '../screens/auth_screen.dart';
import '../providers/auth.dart';
import '../providers/credits.dart';
import '../screens/edit_credit_screen.dart';
import '../screens/credit_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Credits>(
          create: (ctx) => Credits('', () async {}, []),
          update: (ctx, auth, previousCredits) => Credits(
            auth.token.toString(),
            auth.refreshToken,
            previousCredits == null ? [] : previousCredits.items,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Credit App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green)
                .copyWith(secondary: Colors.blue.shade800),
            fontFamily: 'Quicksand',
            textTheme: ThemeData.light().textTheme.copyWith(
                  headline6: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            appBarTheme: AppBarTheme(
              titleTextStyle: ThemeData.light()
                  .textTheme
                  .copyWith(
                    headline6: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                  .headline6,
            ),
          ),
          home: auth.isAuth
              ? const CreditListScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? const Scaffold(
                              body: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : const AuthScreen(),
                ),
          routes: {
            CreditListScreen.routeName: (ctx) => const CreditListScreen(),
            EditCreditScreen.routeName: (ctx) => const EditCreditScreen(),
            CreditDetailScreen.routeName: (ctx) => const CreditDetailScreen(),
          },
        ),
      ),
    );
  }
}
