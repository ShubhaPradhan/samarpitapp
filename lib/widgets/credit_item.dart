import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:samarpitapp/screens/credit_detail_screen.dart';
import 'package:samarpitapp/screens/edit_credit_screen.dart';

import '../providers/credits.dart';

class CreditItem extends StatelessWidget {
  final String id;
  final String customerName;
  final String customerPhone;
  final int amount;
  final DateTime date;

  const CreditItem({
    Key? key,
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.amount,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 5,
      ),
      child: ListTile(
        onTap: () {
          Navigator.of(context).pushNamed(
            CreditDetailScreen.routeName,
            arguments: id,
          );
        },
        leading: CircleAvatar(
          radius: 30,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: FittedBox(
              child: Text(amount.toStringAsFixed(0)),
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
        ),
        title: Text(
          customerName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customerPhone,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                DateFormat.yMMMd().format(date),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        trailing: SizedBox(
          width: 96,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    EditCreditScreen.routeName,
                    arguments: id,
                  );
                },
                icon: const Icon(Icons.edit),
                color: Theme.of(context).colorScheme.primary,
              ),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Are you sure?'),
                      content: const Text(
                          'Do you want to remove the credit from the list?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop(false);
                          },
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(ctx).pop(true);
                            try {
                              await Provider.of<Credits>(context, listen: false)
                                  .deleteCredit(id);
                            } catch (error) {
                              scaffold.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Deleting failed!',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text('Yes'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete),
                color: Theme.of(context).errorColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
