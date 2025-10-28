enum OrderStatus {
  nuevo(0),
  enviado(1),
  entregado(2),
  cancelado(3);

  final int value;
  const OrderStatus(this.value);

  static OrderStatus fromInt(int value) {
    return OrderStatus.values.firstWhere((status) => status.value == value);
  }

  String get displayName {
    switch (this) {
      case OrderStatus.nuevo:
        return 'Nuevo';
      case OrderStatus.enviado:
        return 'Enviado';
      case OrderStatus.entregado:
        return 'Entregado';
      case OrderStatus.cancelado:
        return 'Cancelado';
    }
  }
}
