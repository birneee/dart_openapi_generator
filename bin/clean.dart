import 'package:dart_openapi_generator/utils.dart';

import 'generate.dart';

void main() async {
  await deleteIfExists(openApiSpecDir);
  await deleteIfExists(generatedOutputDir);
  await deleteIfExists(libOutputDir);
}
