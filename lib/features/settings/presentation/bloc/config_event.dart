import 'package:equatable/equatable.dart';

abstract class ConfigEvent extends Equatable {
  const ConfigEvent();

  @override
  List<Object?> get props => [];
}

class UpdateRaioAtuacao extends ConfigEvent {
  final double raio;

  const UpdateRaioAtuacao(this.raio);

  @override
  List<Object?> get props => [raio];
}
