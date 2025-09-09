import 'dart:io';

import 'package:yaml/yaml.dart';

/// Syncs last_verified date from docs/docs/RULES_HUG_mapping.yaml into
/// lib/features/conversation/domain/constants.dart as rulesLastVerifiedYmd.
///
/// Usage:
///   dart run tool/sync_last_verified.dart
void main(List<String> args) async {
  const mappingPath = 'docs/docs/RULES_HUG_mapping.yaml';
  const constantsPath = 'lib/features/conversation/domain/constants.dart';

  try {
    final yamlStr = await File(mappingPath).readAsString();
    final yaml = loadYaml(yamlStr) as YamlMap;
    final lastVerified = yaml['last_verified']?.toString();

    if (lastVerified == null ||
        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(lastVerified)) {
      stderr.writeln(
          'Error: last_verified is missing or not in YYYY-MM-DD format (found: $lastVerified).');
      exit(2);
    }

    final constantsFile = File(constantsPath);
    if (!await constantsFile.exists()) {
      stderr.writeln('Error: constants file not found at $constantsPath');
      exit(3);
    }

    var content = await constantsFile.readAsString();
    final regex =
        RegExp(r"const String rulesLastVerifiedYmd = '([^']*)';");
    final match = regex.firstMatch(content);

    final current = match?.group(1);

    final checkMode = args.contains('--check');
    if (checkMode) {
      if (current == lastVerified) {
        stdout.writeln('OK: last_verified is synchronized ($lastVerified).');
        return;
      }
      stderr.writeln(
          'Mismatch: mapping=$lastVerified, constants=${current ?? 'MISSING'}');
      exit(5);
    }

    if (match == null) {
      // Append the constant if missing
      if (!content.endsWith('\n')) content += '\n';
      content += "const String rulesLastVerifiedYmd = '$lastVerified';\n";
    } else {
      if (current == lastVerified) {
        stdout.writeln('No change needed (already $lastVerified).');
        return;
      }
      content = content.replaceFirst(
          regex, "const String rulesLastVerifiedYmd = '$lastVerified';");
    }

    await constantsFile.writeAsString(content);
    stdout.writeln('Updated rulesLastVerifiedYmd to $lastVerified');
  } on FileSystemException catch (e) {
    stderr.writeln('Filesystem error: ${e.message}');
    exit(4);
  } catch (e) {
    stderr.writeln('Unexpected error: $e');
    exit(1);
  }
}
