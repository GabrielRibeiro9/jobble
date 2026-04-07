import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tcc/features/settings/presentation/bloc/config_event.dart';
import 'package:flutter_tcc/features/settings/presentation/bloc/config_state.dart';

class ConfigBloc extends Bloc<ConfigEvent, ConfigState> {
  ConfigBloc() : super(const ConfigState(raioAtuacao: 15.0)) {
    on<UpdateRaioAtuacao>((event, emit) {
      emit(ConfigState(raioAtuacao: event.raio));
    });
  }
}
