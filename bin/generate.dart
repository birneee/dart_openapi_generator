import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:openapi/utils.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

var openApiSpecDir = Directory("build/openapi");
var generatedOutputDir = Directory("build/openapi/generated");
var libOutputDir = Directory("lib/generated/openapiclient");

void main() async {
  var config = getConfigFromPubspec();
  await downloadApiSchema(config);
  await generateOpenApiClient(config.version);
  await copyToLib();
  print("done");
}

void copyToLib() async {
  await deleteIfExists(libOutputDir);
  await copyDir(
      Directory(p.join(generatedOutputDir.path, "lib")), libOutputDir);
}

void generateOpenApiClient(String version) async {
  var apiFile = getApiDownloadFile(version);
  await deleteIfExists(generatedOutputDir);
  await generatedOutputDir.parent.create(recursive: true);
  var result;
  try {
    result = await Process.run("openapi-generator",[
      "generate",
      "-g",
      "dart",
      "-i",
      apiFile.path,
      "-o",
      generatedOutputDir.path
    ], runInShell: true);
  } on Exception catch (ex) {
    print(ex);
    throw Exception(
        "openapi-generator might not be installed on your system. See README for further instructions");
  }
  print(result.stdout);
  if (result.exitCode != 0) {
    throw Exception("Failed to generate OpenAPI dart client.");
  }
}

File getApiDownloadFile(String version) {
  return File(p.join(openApiSpecDir.path, "api_$version.yaml"));
}

void downloadApiSchema(Config config) async {
  var url = "${config.url}?ref=${config.version}";
  var response = await http.get(url, headers: {'PRIVATE-TOKEN': config.token});
  if (response.statusCode != 200) {
    throw new Exception("Failed to download API Schema");
  }
  var file = getApiDownloadFile(config.version);
  await file.parent.create(recursive: true);
  await file.writeAsString(response.body);
}

class Config {
  final String version;
  final String token;
  final String url;

  Config(this.version, this.token, this.url) {
    if (version == null) {
      throw Exception("invalid version");
    }
    if (token == null) {
      throw Exception("invalid token");
    }
    if (url == null) {
      throw Exception("invalid url");
    }
  }
}

Config getConfigFromPubspec() {
  try {
    var file = File("pubspec.yaml");
    var yamlString = file.readAsStringSync();
    var yamlMap = loadYaml(yamlString);
    return Config(yamlMap['openapi']['version'], yamlMap['openapi']['token'],
        yamlMap['openapi']['url']);
  } on Exception catch (_) {
    throw Exception(
        "Invalid pubspec config. See README for further instructions");
  }
}
