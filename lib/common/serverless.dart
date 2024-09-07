import 'package:http/http.dart' as http; 
import 'dart:convert'; 
import 'package:json_annotation/json_annotation.dart';
part 'serverless.g.dart';

@JsonSerializable()
class GeneratedImage{
  String? path;
  String? url;
}

@JsonSerializable()
class GenerateApiRequest {
  GenerateApiRequest(this.prompt, this.image_url, {this.type="controlnet"});
  final String type;
  final String prompt;
  final String image_url;
  String? negative_prompt;
  int? height;
  int? width;
  int? num_inference_steps;
  int? refiner_inference_steps;
  double? guidance_scale;
  double? strength;
  int? num_images;
}
@JsonSerializable()
class GenerateControlnetApiRequest {
  GenerateControlnetApiRequest({this.model="canny", this.conditioning_scale=0.5});
  final String model;
  final double? conditioning_scale;
  int? image_resolution;
  int? low_threshold;
  int? high_threshold;
}




class GenerateHandlerApi {
  const GenerateHandlerApi(this.baseUri, this.token);
  final String baseUri;
  final String? token;
  void configure(String uri, String token) {

  }
  Future<List<String>> generate(String image,String prompt, String negative) async {
    final request = GenerateApiRequest(prompt, image){};
    final response = await http.post( 
        Uri.parse(baseUri), 
        headers: <String, String>{ 
          'Content-Type': 'application/json; charset=UTF-8', 
          'Authorization': 'Bearer $token',
        }, 
        body: jsonEncode(<String, dynamic>{ 
          'name': nameController.text, 
          'email': emailController.text, 
          // Add any other data you want to send in the body 
        }), 
      ); 
  
      if (response.statusCode == 201) { 
        // Successful POST request, handle the response here 
        final responseData = jsonDecode(response.body); 
        setState(() { 
          result = 'ID: ${responseData['id']}\nName: ${responseData['name']}\nEmail: ${responseData['email']}'; 
        }); 
      } else { 
        // If the server returns an error response, throw an exception 
        throw Exception('Failed to post data'); 
      } 
    } catch (e) { 
      setState(() { 
        result = 'Error: $e'; 
      }); 
    }   }
}
