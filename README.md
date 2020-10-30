# Dart OpenAPI Generator

Dart dev tool to download OpenAPI file and generate the OpenAPI client.

## Requirements
- openapi-generator installed on system path (https://github.com/OpenAPITools/openapi-generator)

## Supported Download Sources
- private Gitlab repositories

## Include in your projects `pubspec.yaml`

```yaml
dev_dependencies:
  openapi:
    git:
      url: https://github.com/birneee/dart_openapi_generator.git
      ref: 0.1.0

openapi:
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