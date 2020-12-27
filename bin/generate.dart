import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:openapi/utils.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

var openApiSpecDir = Directory("build/openapi");
var generatorDir = Directory("build/generator");
var generatedOutputDir = Directory("build/openapi/generated");
var libOutputDir = Directory("lib/generated/openapiclient");

const OPENAPI_GENERATOR_URL = "https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli";

void main() async {
  var config = getConfigFromPubspec();
  await downloadOpenApiGeneratorJar(config, skipIfExists: true);
  await downloadApiSchema(config, skipIfExists: true);
  await generateOpenApiClient(config);
  await copyToLib();
  print("done");
}

void copyToLib() async {
  await deleteIfExists(libOutputDir);
  await copyDir(
      Directory(p.join(generatedOutputDir.path, "lib")), libOutputDir);
}

void generateOpenApiClient(Config config) async {
  await deleteIfExists(generatedOutputDir);
  await generatedOutputDir.parent.create(recursive: true);
  var result;
  try {
    result = await Process.run("java",[
      "-jar",
      getOpenApiGeneratorJarFile(config.generatorVersion).path,
      "generate",
      "-g",
      "dart",
      "-i",
      getApiDownloadFile(config.version).path,
      "-o",
      generatedOutputDir.path
    ], runInShell: true);
  } on Exception catch (ex) {
    print(ex);
    throw Exception(
        "openapi-generator might not be installed on your system. See README for further instructions");
  }
  print(result.stdout);
  print(result.stderr);
  if (result.exitCode != 0) {
    throw Exception("Failed to generate OpenAPI dart client.");
  }
}

File getApiDownloadFile(String version) {
  return File(p.join(openApiSpecDir.path, "api_$version.yaml"));
}

File getOpenApiGeneratorJarFile(String version) {
  return File(p.join(generatorDir.path, "openapi-generator-cli-$version.jar"));
}

String getOpenApiGeneratorJarUrl(String version){
  return "$OPENAPI_GENERATOR_URL/$version/openapi-generator-cli-$version.jar";
}

void downloadOpenApiGeneratorJar(Config config, {bool skipIfExists = false}) async {
  print("Downloading OpenApi Generator...");
  var file = getOpenApiGeneratorJarFile(config.generatorVersion);
  if(skipIfExists && await file.exists()){
    print("skip (file already exists)");
    return;
  }
  var url = Uri.parse(getOpenApiGeneratorJarUrl(config.generatorVersion));
  var client = HttpClient();
  var request = await client.getUrl(url);
  var response = await request.close();
  if (response.statusCode != 200) {
    throw new Exception("Failed to download OpenApi Generator");
  }
  await file.parent.create(recursive: true);
  await response.pipe(file.openWrite());
  print("done");
}

void downloadApiSchema(Config config, {bool skipIfExists = false}) async {
  print("Downloading API Schema...");
  var file = getApiDownloadFile(config.version);
  if(skipIfExists && await file.exists()){
    print("skip (file already exists)");
    return;
  }
  var url = "${config.url}?ref=${config.version}";
  var response = await http.get(url, headers: {'PRIVATE-TOKEN': config.token});
  if (response.statusCode != 200) {
    throw new Exception("Failed to download API Schema");
  }
  await file.parent.create(recursive: true);
  await file.writeAsString(response.body);
  print("done");
}

class Config {
  final String version;
  final String generatorVersion;
  final String token;
  final String url;

  Config(this.generatorVersion, this.version, this.token, this.url) {
    if (generatorVersion == null) {
      throw Exception("invalid generator version");
    }
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
    return Config(
        yamlMap['openapi']['generatorVersion'],
        yamlMap['openapi']['version'],
        yamlMap['openapi']['token'],
        yamlMap['openapi']['url']);
  } on Exception catch (_) {
    throw Exception(
        "Invalid pubspec config. See README for further instructions");
  }
}
