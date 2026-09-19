import 'package:dio/dio.dart';

/// Intercepta chamadas de LEITURA (GET) e devolve respostas ficticias.
///
/// Ativado com `--dart-define=USE_MOCK=true`. Serve para o desenvolvimento:
/// o painel de 5 abas abre cheio (Inicio, Servicos, Contratos, Ajustes,
/// Perfil) mesmo sem a API no ar, e sem depender de login real.
class MockInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final path = options.path;
    final method = options.method.toUpperCase();

    // Apenas leituras sao mockadas; escrita continua indo a rede (seguro).
    if (method != 'GET') {
      return handler.next(options);
    }

    Map<String, dynamic>? mock;
    if (path == '/organizations/jobs/completed-today') {
      mock = _completedToday();
    } else if (path == '/matches') {
      mock = _matches();
    } else if (path == '/contracts') {
      mock = _contracts();
    } else if (path == '/notifications') {
      mock = _notifications();
    } else if (path == '/notifications/count') {
      mock = {'count': 3};
    } else if (path == '/projects') {
      mock = _projects();
    }

    if (mock != null) {
      return handler.resolve(
        Response(
          requestOptions: options,
          data: mock,
          statusCode: 200,
        ),
      );
    }

    // Caminho desconhecido: segue para a rede normalmente.
    return handler.next(options);
  }

  /// Ganhos ficticios de hoje (card "Inicio").
  Map<String, dynamic> _completedToday() {
    return {
      'totalEarnings': 187.5,
      'jobs': List.generate(
        3,
        (i) => {
          'id': 'job-mock-$i',
          'status': 'COMPLETED',
          'title': ['Limpeza residencial', 'Pintura de sala', 'Troca de piso'][i],
          'clientName': ['Ana Souza', 'Carlos Lima', 'Marina Tavares'][i],
        },
      ),
    };
  }

  /// Chamados em aberto (aba "Servicos" e contagem do "Inicio").
  Map<String, dynamic> _matches() {
    return {
      'matches': [
        {
          'id': 'req-mock-1',
          'title': 'Reparo hidraulico',
          'description': 'Torneira pingando e vazamento no registro do banheiro.',
          'categoryLabel': 'Hidraulica',
          'isEmergency': false,
          'scheduledAt': '2026-09-18T09:00:00',
          'status': 'PENDING',
          'distanceKm': 2.4,
          'clientRevealed': false,
          'location': 'Jardim Paulista, Sao Paulo - SP',
        },
        {
          'id': 'req-mock-2',
          'title': 'Montagem de movel',
          'description': 'Montar guarda-roupa 6 portas com espelho.',
          'categoryLabel': 'Montagem',
          'isEmergency': false,
          'scheduledAt': '2026-09-19T14:00:00',
          'status': 'PENDING',
          'distanceKm': 5.1,
          'clientRevealed': false,
          'location': 'Vila Mariana, Sao Paulo - SP',
        },
        {
          'id': 'req-mock-3',
          'title': 'Desentupimento de pia',
          'description': 'Pia da cozinha entupida, precisa urgente.',
          'categoryLabel': 'Encanamento',
          'isEmergency': true,
          'scheduledAt': '2026-09-17T18:30:00',
          'status': 'PENDING',
          'distanceKm': 0.9,
          'clientRevealed': false,
          'location': 'Consolacao, Sao Paulo - SP',
        },
      ],
    };
  }

  /// Contratos (aba "Contratos").
  Map<String, dynamic> _contracts() {
    return {
      'contracts': [
        {
          'id': 'contract-mock-1',
          'code': 'CT-2026-014',
          'status': 'COMPLETED',
          'priceCents': 125000,
          'startDate': '2026-09-10T08:00:00',
          'request': {
            'title': 'Limpeza residencial',
            'description': 'Limpeza completa de apartamento 3 quartos.',
          },
          'organization': {'name': 'Servicos & Cia'},
          'client': {'name': 'Ana Souza'},
        },
        {
          'id': 'contract-mock-2',
          'code': 'CT-2026-015',
          'status': 'AWAITING_CONFIRMATION',
          'priceCents': 80000,
          'startDate': '2026-09-22T10:00:00',
          'request': {
            'title': 'Pintura de sala',
            'description': 'Pintura interna de sala e corredor.',
          },
          'organization': {'name': 'Servicos & Cia'},
          'client': {'name': 'Carlos Lima'},
        },
      ],
    };
  }

  /// Notificacoes (aba "Ajustes").
  Map<String, dynamic> _notifications() {
    return {
      'notifications': [
        {
          'id': 'notif-mock-1',
          'organizationId': 'org-mock-1',
          'type': 'SERVICE_REQUEST',
          'title': 'Novo chamado disponivel',
          'message': 'Um cliente proximo pediu reparo hidraulico.',
          'personName': 'Jobble',
          'isUnread': true,
          'createdAt': '2026-09-17T08:00:00',
        },
        {
          'id': 'notif-mock-2',
          'organizationId': 'org-mock-1',
          'type': 'CONTRACT',
          'title': 'Contrato assinado',
          'message': 'O contrato CT-2026-014 foi assinado pelo cliente.',
          'personName': 'Jobble',
          'isUnread': false,
          'createdAt': '2026-09-16T15:30:00',
        },
      ],
    };
  }

  /// Projetos/portfolio (aba "Perfil").
  Map<String, dynamic> _projects() {
    return {
      'projects': [
        {'id': 'proj-mock-1', 'name': 'Reforma de cozinha', 'status': 'COMPLETED'},
        {'id': 'proj-mock-2', 'name': 'Instalacao de ar-condicionado', 'status': 'IN_PROGRESS'},
      ],
    };
  }
}
