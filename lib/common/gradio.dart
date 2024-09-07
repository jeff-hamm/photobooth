import 'dart:js';
import 'dart:js_util';
import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'dart:async';

@JS()
external Gradio get gradio;

@JS()
class GeneratedImage{
  String? path;
  String? url;
}


@JS()
class Gradio {

  external void configure(String uri);
  external Future<List<String>> generate(String image,String prompt, String negative);
}
