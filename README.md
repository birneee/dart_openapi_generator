# Dart OpenAPI Generator

Dart dev tool to download OpenAPI file and generate the OpenAPI client.

## Requirements
- java version 8 or above installed on system path

## Supported Download Sources
- private Gitlab repositories

## Include in your project's `pubspec.yaml`

```yaml
dev_dependencies:
  openapi:
    git:
      url: https://github.com/birneee/dart_openapi_generator.git
      ref: 0.4.0

openapi:
  generatorVersion: <version>
  url: <url>
  token: <token>
  version: <tag>
```

## Download and Generate
```bash
pub run openapi:generate # for dart projects
flutter pub run openapi:generate # for flutter projects
```

## Clean Geneated Files
```bash
pub run openapi:clean # for dart projects
flutter pub run openapi:clean # for flutter projects
```