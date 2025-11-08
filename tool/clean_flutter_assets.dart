import 'dart:io';

Future<void> main(List<String> args) async {
  final assetsDir = Directory('build/flutter_assets');

  if (!assetsDir.existsSync()) {
    stdout.writeln('build/flutter_assets não existe. Nenhuma limpeza necessária.');
    return;
  }

  stdout.writeln('Removendo build/flutter_assets travado...');

  try {
    if (Platform.isWindows) {
      final path = assetsDir.path.replaceAll('/', '\\');
      final result = await Process.run(
        'cmd',
        ['/c', 'rmdir /s /q "$path"'],
        runInShell: true,
      );

      if (result.exitCode != 0) {
        stderr.writeln('Falha ao remover via rmdir. Saída:');
        stderr.writeln(result.stdout);
        stderr.writeln(result.stderr);
        stderr.writeln('Tente fechar processos que estejam usando a pasta e execute novamente.');
        exit(result.exitCode);
      }
    } else {
      assetsDir.deleteSync(recursive: true);
    }

    stdout.writeln('Diretório build/flutter_assets removido com sucesso.');
  } on FileSystemException catch (error) {
    stderr.writeln('Não foi possível remover build/flutter_assets: ${error.message}');
    stderr.writeln('Verifique se outro processo está usando os arquivos ou execute o comando com permissões elevadas.');
    exitCode = 1;
  }
}
