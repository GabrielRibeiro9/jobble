import 'package:equatable/equatable.dart';

class ConfigState extends Equatable {
  final double raioAtuacao; // em KM

  const ConfigState({required this.raioAtuacao});

  @override
  List<Object?> get props => [raioAtuacao];
}
