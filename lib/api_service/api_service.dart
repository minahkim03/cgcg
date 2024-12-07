import 'dart:io';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: "http://localhost:8080")
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @POST("/register/image")
  @MultiPart()
  Future<String> uploadProfileImage(@Part(name: "file") File profileImage);

  @POST("/register")
  Future<void> registerUser(@Body() Map<String, dynamic> userData);

  @POST("/event/new/image")
  @MultiPart()
  Future<String> uploadEventImage(@Part(name: "file") File image);
}
