import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/credits.dart';

class CreditDetailScreen extends StatelessWidget {
  const CreditDetailScreen({Key? key}) : super(key: key);

  static const routeName = '/credit-detail';

  @override
  Widget build(BuildContext context) {
    final creditId = ModalRoute.of(context)!.settings.arguments as String;
    final loadedCredit =
        Provider.of<Credits>(context, listen: false).findById(creditId);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Name : ${loadedCredit.customerName}',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Customer Phone : ${loadedCredit.customerPhone.substring(4, 14)}',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Amount : NRS. ${loadedCredit.amount}',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Date : ${DateFormat.yMMMd().format(loadedCredit.date)}',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
