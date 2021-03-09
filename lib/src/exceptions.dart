import 'package:meta/meta.dart';

class ParameterParsingException implements Exception {
  final String parameter;

  ParameterParsingException({@required this.parameter, this.message});

  dynamic message;

  @override
  String toString() =>
      "Exception: Error while parsing parameter '$parameter. \n"
      "${message != null ? message : ""}";
}

class InvalidPackageException implements Exception {
  final String packageName;

  InvalidPackageException(this.packageName);

  @override
  String toString() => 'No package named "$packageName" was found.';
}
