import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_button.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: '1',
      type: PaymentType.card,
      lastFour: '4567',
      brand: 'Visa',
      expiryDate: '12/25',
      isDefault: true,
    ),
    PaymentMethod(
      id: '2',
      type: PaymentType.card,
      lastFour: '8901',
      brand: 'Mastercard',
      expiryDate: '08/26',
      isDefault: false,
    ),
    PaymentMethod(
      id: '3',
      type: PaymentType.paypal,
      email: 'john.doe@email.com',
      isDefault: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft),
          onPressed: () => AppRoutes.goBack(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAddPaymentButton(context),
            const SizedBox(height: 24),
            _buildPaymentMethodsList(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPaymentButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: 'Add Payment Method',
        onPressed: () {
          _showAddPaymentDialog(context);
        },
        variant: ButtonVariant.primary,
        size: ButtonSize.large,
        icon: LucideIcons.plus,
      ),
    );
  }

  Widget _buildPaymentMethodsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Payment Methods',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _paymentMethods.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final method = _paymentMethods[index];
            return _buildPaymentMethodCard(context, method);
          },
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(BuildContext context, PaymentMethod method) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getMethodColor(method.type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getMethodIcon(method.type),
                color: _getMethodColor(method.type),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _getMethodTitle(method),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      if (method.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Default',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getMethodSubtitle(method),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(LucideIcons.moreVertical, size: 20),
              onSelected: (value) {
                switch (value) {
                  case 'default':
                    _setAsDefault(method);
                    break;
                  case 'edit':
                    _editPaymentMethod(method);
                    break;
                  case 'delete':
                    _deletePaymentMethod(method);
                    break;
                }
              },
              itemBuilder: (context) => [
                if (!method.isDefault)
                  const PopupMenuItem(
                    value: 'default',
                    child: Row(
                      children: [
                        Icon(LucideIcons.star, size: 16),
                        SizedBox(width: 8),
                        Text('Set as Default'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(LucideIcons.edit, size: 16),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(LucideIcons.trash, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getMethodIcon(PaymentType type) {
    switch (type) {
      case PaymentType.card:
        return LucideIcons.creditCard;
      case PaymentType.paypal:
        return LucideIcons.wallet;
      case PaymentType.bankTransfer:
        return LucideIcons.building;
    }
  }

  Color _getMethodColor(PaymentType type) {
    switch (type) {
      case PaymentType.card:
        return Colors.blue;
      case PaymentType.paypal:
        return Colors.orange;
      case PaymentType.bankTransfer:
        return Colors.green;
    }
  }

  String _getMethodTitle(PaymentMethod method) {
    switch (method.type) {
      case PaymentType.card:
        return '${method.brand} •••• ${method.lastFour}';
      case PaymentType.paypal:
        return 'PayPal';
      case PaymentType.bankTransfer:
        return 'Bank Transfer';
    }
  }

  String _getMethodSubtitle(PaymentMethod method) {
    switch (method.type) {
      case PaymentType.card:
        return 'Expires ${method.expiryDate}';
      case PaymentType.paypal:
        return method.email ?? '';
      case PaymentType.bankTransfer:
        return 'Bank account ending in ${method.lastFour}';
    }
  }

  void _showAddPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Payment Method'),
        content: const Text('Choose a payment method to add:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Credit Card setup coming soon!')),
              );
            },
            child: const Text('Credit Card'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PayPal setup coming soon!')),
              );
            },
            child: const Text('PayPal'),
          ),
        ],
      ),
    );
  }

  void _setAsDefault(PaymentMethod method) {
    setState(() {
      for (var m in _paymentMethods) {
        m.isDefault = m.id == method.id;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_getMethodTitle(method)} set as default')),
    );
  }

  void _editPaymentMethod(PaymentMethod method) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit payment method coming soon!')),
    );
  }

  void _deletePaymentMethod(PaymentMethod method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Method'),
        content: Text('Are you sure you want to delete ${_getMethodTitle(method)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _paymentMethods.removeWhere((m) => m.id == method.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment method deleted'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

enum PaymentType { card, paypal, bankTransfer }

class PaymentMethod {
  final String id;
  final PaymentType type;
  final String? lastFour;
  final String? brand;
  final String? expiryDate;
  final String? email;
  bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    this.lastFour,
    this.brand,
    this.expiryDate,
    this.email,
    this.isDefault = false,
  });
}
