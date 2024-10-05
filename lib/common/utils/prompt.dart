import 'dart:async' show Future;
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

List<String>? prompts;
final r = Random();
Future<List<String>> _loadPrompts() async {
  return prompts ??= const LineSplitter()
      .convert(await rootBundle.loadString('assets/file/prompts.txt'));
}

Future<String> getRandomPrompt() async {
  final p = await _loadPrompts();
  return p[r.nextInt(p.length)];
}
