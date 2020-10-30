import 'package:openapi/utils.dart';

import 'generate.dart';

void main() async {
  await deleteIfExists(openApiSpecDir);
  await deleteIfExists(generatedOutputDir);
  await deleteIfExists(libOutputDir);
}
