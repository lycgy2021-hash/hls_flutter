import 'package:dio/dio.dart';

import 'package:flutter_app/services/api/api_headers.dart';
import 'package:flutter_app/services/identity/identity_manager.dart';

class HeaderInterceptor extends Interceptor {
  HeaderInterceptor(this._identityManager);

  final IdentityManager _identityManager;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final actorId = await _identityManager.getActorId();
    final did = await _identityManager.getDid();

    options.headers[xActorId] = actorId;
    options.headers[xDid] = did;

    handler.next(options);
  }
}
