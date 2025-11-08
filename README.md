# cajucards

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Solução para erro no Windows ao executar no Edge

Em alguns ambientes Windows, o comando `flutter run -d edge` pode falhar com a mensagem:

```
Flutter failed to delete a directory at "build\flutter_assets".
```

Isso normalmente acontece quando algum processo mantém arquivos dentro de `build/flutter_assets`
travados, impedindo que o Flutter limpe o diretório antes de reconstruir o projeto.

Para liberar a pasta rapidamente sem precisar mexer manualmente no explorador de arquivos,
execute o utilitário abaixo antes de iniciar o app:

```
dart run tool/clean_flutter_assets.dart
flutter run -d edge
```

O script tenta remover o diretório problemático (usando `rmdir` no Windows) e imprime mensagens
claras caso algum processo ainda esteja segurando os arquivos. Feche janelas do navegador ou
processos que possam estar utilizando o diretório e execute novamente se necessário.
