# Dart OpenAPI Generator

Dart dev tool to download OpenAPI file and generate the OpenAPI client.

## Supported Download Sources
- private Gitlab repositories

## Include in your projects `pubspec.yaml`

```yaml
dev_dependencies:
  dart_openapi_generator:
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
flutter pub run openapi:generate
```

## Clean Geneated Files
```bash
flutter pub run openapi:clean
```