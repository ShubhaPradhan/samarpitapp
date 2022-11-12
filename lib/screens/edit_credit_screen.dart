import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/credit.dart';
import '../models/http_exception.dart';
import '../providers/credits.dart';

class EditCreditScreen extends StatefulWidget {
  const EditCreditScreen({Key? key}) : super(key: key);

  static const routeName = '/add-credit';

  @override
  State<EditCreditScreen> createState() => _EditCreditScreenState();
}

class _EditCreditScreenState extends State<EditCreditScreen> {
  final _form = GlobalKey<FormState>();
  var _editedCredit = Credit(
    id: '',
    customerName: '',
    customerPhone: '',
    amount: 0,
    date: DateTime.now(),
  );

  var _initValues = {
    'customerName': '',
    'customerPhone': '',
    'amount': '',
  };

  var _isInit = true;

  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final creditId = ModalRoute.of(context)!.settings.arguments as String?;
      if (creditId != null) {
        _editedCredit =
            Provider.of<Credits>(context, listen: false).findById(creditId);
        _initValues = {
          'customerName': _editedCredit.customerName,
          'customerPhone': _editedCredit.customerPhone.substring(4, 14),
          'amount': _editedCredit.amount.toString(),
        };
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _showErrorDialog(String message) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('An error occurred!'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState?.validate();
    if (isValid == null) {
      return;
    }
    _form.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedCredit.id.isNotEmpty) {
      try {
        await Provider.of<Credits>(context, listen: false)
            .updateCredit(_editedCredit.id, _editedCredit);
        Navigator.of(context).pop();
      } on HttpException catch (error) {
        var errorMessage = 'An error occurred!';
        if (error.toString().contains('PHONE_EXISTS')) {
          errorMessage = 'This phone number already exists.';
          await _showErrorDialog(errorMessage);
        }
      } catch (error) {
        const errorMessage = 'Could not update credit. Please try again later.';
        await _showErrorDialog(errorMessage);
      }
    } else {
      try {
        await Provider.of<Credits>(context, listen: false)
            .addCredit(_editedCredit);
        Navigator.of(context).pop();
      } on HttpException catch (error) {
        var errorMessage = 'An error occurred!';
        if (error.toString().contains('PHONE_EXISTS')) {
          errorMessage = 'This phone number already exists.';
          await _showErrorDialog(errorMessage);
        }
      } catch (error) {
        const errorMessage = 'Could not add credit. Please try again later.';
        await _showErrorDialog(errorMessage);
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _editedCredit.id.isEmpty
            ? const Text('Add Credit')
            : const Text('Edit Credit'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              padding: const EdgeInsets.all(10),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValues['customerName'],
                      decoration: const InputDecoration(
                        labelText: 'Customer Name',
                      ),
                      textInputAction: TextInputAction.next,
                      onSaved: (value) {
                        _editedCredit = Credit(
                          customerName: value!,
                          customerPhone: _editedCredit.customerPhone,
                          amount: _editedCredit.amount,
                          date: _editedCredit.date,
                          id: _editedCredit.id,
                        );
                      },
                      validator: (value) {
                        if (value.toString().isEmpty) {
                          return 'Please provide a customer name.';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['customerPhone'],
                      decoration: const InputDecoration(
                        labelText: 'Customer Phone',
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.phone,
                      onSaved: (value) {
                        _editedCredit = Credit(
                          customerName: _editedCredit.customerName,
                          customerPhone: "+977$value",
                          amount: _editedCredit.amount,
                          date: _editedCredit.date,
                          id: _editedCredit.id,
                        );
                      },
                      validator: (value) {
                        // validate phone number
                        if (value.toString().isEmpty) {
                          return 'Please provide a customer phone.';
                        } else if (value.toString().length != 10) {
                          return 'Please provide a valid phone number.';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['amount'],
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      onSaved: (value) {
                        _editedCredit = Credit(
                          customerName: _editedCredit.customerName,
                          customerPhone: _editedCredit.customerPhone,
                          amount: int.parse(value!),
                          date: _editedCredit.date,
                          id: _editedCredit.id,
                        );
                      },
                      validator: (value) {
                        if (value.toString().isEmpty) {
                          return 'Please provide an amount.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: _saveForm,
                      child: _editedCredit.id.isEmpty
                          ? const Text('Add Credit')
                          : const Text('Edit Credit'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
