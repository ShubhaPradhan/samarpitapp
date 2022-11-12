import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:samarpitapp/widgets/app_drawer.dart';

import '../providers/credits.dart';
import '../widgets/credit_item.dart';

class CreditListScreen extends StatefulWidget {
  const CreditListScreen({Key? key}) : super(key: key);

  static const routeName = '/credit-list';

  @override
  State<CreditListScreen> createState() => _CreditListScreenState();
}

class _CreditListScreenState extends State<CreditListScreen> {
  var _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      Provider.of<Credits>(context).fetchAndSetCredits();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final creditData = Provider.of<Credits>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credits'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/add-credit');
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: ListView.builder(
        itemCount: creditData.items.length,
        itemBuilder: (ctx, i) => CreditItem(
          id: creditData.items[i].id,
          customerName: creditData.items[i].customerName,
          customerPhone: creditData.items[i].customerPhone,
          amount: creditData.items[i].amount,
          date: creditData.items[i].date,
        ),
      ),
    );
  }
}
