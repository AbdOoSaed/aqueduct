import 'dart:async';

import 'package:aqueduct/src/application/application.dart';
import 'package:aqueduct/src/application/channel.dart';
import 'package:aqueduct/src/application/isolate_application_server.dart';
import 'package:aqueduct/src/application/options.dart';
import 'package:aqueduct/src/auth/auth.dart';
import 'package:aqueduct/src/http/http.dart';
import 'package:aqueduct/src/http/resource_controller.dart';
import 'package:aqueduct/src/http/resource_controller_bindings.dart';
import 'package:aqueduct/src/openapi/documentable.dart';
import 'package:aqueduct/src/openapi/openapi.dart';

abstract class RuntimeType {
  String get kind;
  String get source;
}

abstract class ChannelRuntime extends RuntimeType {
  Iterable<APIComponentDocumenter> getDocumentableChannelComponents(
      ApplicationChannel channel);

  Type get channelType;

  @override
  String get kind => "channel";

  String get name;
  Uri get libraryUri;
  IsolateEntryFunction get isolateEntryPoint;

  ApplicationChannel instantiateChannel();

  Future runGlobalInitialization(ApplicationOptions config);
}

abstract class ControllerRuntime extends RuntimeType {
  @override
  String get kind => "controller";

  bool get isMutable;

  ResourceControllerRuntime get resourceController;
}

abstract class SerializableRuntime extends RuntimeType {
  @override
  String get kind => "serializable";

  APISchemaObject documentSchema(APIDocumentContext context);
}

abstract class ResourceControllerRuntime {
  List<ResourceControllerOperationRuntime> get operations;

  void bindProperties(ResourceController rc, Request request, List<String> errorsIn);

  ResourceControllerOperationRuntime getOperationRuntime(String method, List<String> pathVariables);

  void documentComponents(ResourceController rc, APIDocumentContext context);

  List<APIParameter> documentOperationParameters(
      ResourceController rc, APIDocumentContext context, Operation operation);

  APIRequestBody documentOperationRequestBody(
      ResourceController rc, APIDocumentContext context, Operation operation);

  Map<String, APIOperation> documentOperations(ResourceController rc,
      APIDocumentContext context, String route, APIPath path);
}

abstract class ResourceControllerOperationRuntime {
  List<AuthScope> scopes;
  List<String> pathVariables;
  String method;

  bool isSuitableForRequest(String requestMethod, List<String> requestPathVariables);
  Future<Response> invoke(ResourceController rc, Request request, List<String> errorsIn);
}