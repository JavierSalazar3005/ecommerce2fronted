enum Role {
  admin(0),
  empresa(1),
  cliente(2);

  final int value;
  const Role(this.value);

  static Role fromInt(int value) {
    return Role.values.firstWhere((role) => role.value == value);
  }

  String get displayName {
    switch (this) {
      case Role.admin:
        return 'Administrador';
      case Role.empresa:
        return 'Empresa';
      case Role.cliente:
        return 'Cliente';
    }
  }
}
