import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userName = Provider.of<Auth>(context).loggedUserName;
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Row(
              children: [
                Text('Hi, $userName'),
                const SizedBox(
                  width: 10,
                ),
                const Icon(Icons.waving_hand_sharp),
              ],
            ),
            automaticallyImplyLeading: false,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context, listen: false).logout();
            },
          )
        ],
      ),
    );
  }
}
