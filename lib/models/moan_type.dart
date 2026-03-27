enum MoanType {
  suave,
  intenso,
  dramatico,
  timido,
  robusto,
}

extension MoanTypeExtension on MoanType {
  String get displayName {
    switch (this) {
      case MoanType.suave:
        return 'Suave';
      case MoanType.intenso:
        return 'Intenso';
      case MoanType.dramatico:
        return 'Dramático';
      case MoanType.timido:
        return 'Tímido';
      case MoanType.robusto:
        return 'Robusto';
    }
  }

  String get emoji {
    switch (this) {
      case MoanType.suave:
        return '😌';
      case MoanType.intenso:
        return '🔥';
      case MoanType.dramatico:
        return '🎭';
      case MoanType.timido:
        return '🫣';
      case MoanType.robusto:
        return '💪';
    }
  }

  String get description {
    switch (this) {
      case MoanType.suave:
        return 'Un gemido suave y relajado';
      case MoanType.intenso:
        return 'Fuerte y apasionado';
      case MoanType.dramatico:
        return 'Teatral y exagerado';
      case MoanType.timido:
        return 'Discreto y contenido';
      case MoanType.robusto:
        return 'Grave y profundo';
    }
  }

  int get index2 => MoanType.values.indexOf(this);
}
