import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../models/order_status.dart';

class EmpresaOrdersScreen extends StatefulWidget {
  const EmpresaOrdersScreen({super.key});

  @override
  State<EmpresaOrdersScreen> createState() => _EmpresaOrdersScreenState();
}

class _EmpresaOrdersScreenState extends State<EmpresaOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  Future<void> _loadOrders() async {
    try {
      await context.read<OrderProvider>().fetchEmpresaOrders();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.nuevo:
        return Colors.blue;
      case OrderStatus.enviado:
        return Colors.orange;
      case OrderStatus.entregado:
        return Colors.green;
      case OrderStatus.cancelado:
        return Colors.red;
    }
  }

  Future<void> _showUpdateStatusDialog(int orderId, OrderStatus currentStatus) async {
    OrderStatus? selectedStatus = currentStatus;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Cambiar Estado del Pedido'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<OrderStatus>(
                title: const Text('Nuevo'),
                value: OrderStatus.nuevo,
                groupValue: selectedStatus,
                onChanged: (value) {
                  setDialogState(() => selectedStatus = value);
                },
              ),
              RadioListTile<OrderStatus>(
                title: const Text('Enviado'),
                value: OrderStatus.enviado,
                groupValue: selectedStatus,
                onChanged: (value) {
                  setDialogState(() => selectedStatus = value);
                },
              ),
              RadioListTile<OrderStatus>(
                title: const Text('Entregado'),
                value: OrderStatus.entregado,
                groupValue: selectedStatus,
                onChanged: (value) {
                  setDialogState(() => selectedStatus = value);
                },
              ),
              RadioListTile<OrderStatus>(
                title: const Text('Cancelado'),
                value: OrderStatus.cancelado,
                groupValue: selectedStatus,
                onChanged: (value) {
                  setDialogState(() => selectedStatus = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedStatus != null && selectedStatus != currentStatus) {
                  try {
                    await context.read<OrderProvider>().updateOrderStatus(
                          orderId,
                          selectedStatus!,
                        );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Estado actualizado'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } else {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos Recibidos'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orderProvider.empresaOrders.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 100,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No hay pedidos aún',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orderProvider.empresaOrders.length,
                    itemBuilder: (context, index) {
                      final order = orderProvider.empresaOrders[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ExpansionTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pedido #${order.id}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(order.status).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  order.status.displayName,
                                  style: TextStyle(
                                    color: _getStatusColor(order.status),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(order.fecha)}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              Text(
                                'Total: \$${order.total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ],
                          ),
                          children: [
                            const Divider(),
                            if (order.items != null) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Productos:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...order.items!.map((item) => Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${item.quantity}x ${item.productName}',
                                                  style: const TextStyle(fontSize: 14),
                                                ),
                                              ),
                                              Text(
                                                '\$${item.subtotal.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ElevatedButton.icon(
                                onPressed: () => _showUpdateStatusDialog(order.id, order.status),
                                icon: const Icon(Icons.edit),
                                label: const Text('Cambiar Estado'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
