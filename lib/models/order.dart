import 'order_status.dart';

class Order {
  final int id;
  final int empresaId;
  final int clienteId;
  final DateTime fecha;
  final OrderStatus status;
  final double total;
  final List<OrderItem>? items;

  Order({
    required this.id,
    required this.empresaId,
    required this.clienteId,
    required this.fecha,
    required this.status,
    required this.total,
    this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      empresaId: json['empresaId'] as int,
      clienteId: json['clienteId'] as int,
      fecha: DateTime.parse(json['fecha'] as String),
      status: OrderStatus.fromInt(json['status'] as int),
      total: (json['total'] as num).toDouble(),
      items: json['items'] != null
          ? (json['items'] as List).map((item) => OrderItem.fromJson(item)).toList()
          : null,
    );
  }
}

class OrderItem {
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] as int,
      productName: json['productName'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }
}

class CreateOrderDto {
  final int empresaId;
  final List<CreateOrderItemDto> items;

  CreateOrderDto({
    required this.empresaId,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'empresaId': empresaId,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class CreateOrderItemDto {
  final int productId;
  final int quantity;

  CreateOrderItemDto({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}

class UpdateOrderStatusDto {
  final OrderStatus status;

  UpdateOrderStatusDto({required this.status});

  Map<String, dynamic> toJson() {
    return {
      'status': status.value,
    };
  }
}
