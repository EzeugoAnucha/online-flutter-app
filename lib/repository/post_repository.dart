import 'dart:convert';
import 'dart:io';

import 'package:anucha_project/model/post.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class PostRepository {
  final String baseUrl = "https://dummyjson.com";

  Future<List<Post>> fetchPosts() async {
    try {
      debugPrint('Fetching posts from: $baseUrl/posts');

      final response = await http.get(
        Uri.parse('$baseUrl/posts'),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        List<dynamic> postsData = jsonResponse['posts'] ?? [];

        debugPrint('Fetched ${postsData.length} posts');

        return postsData.map((dynamic item) {
          return Post(
            id: item['id'],
            userId: item['userId'] ?? 1,
            title: item['title'] ?? '',
            body: item['body'] ?? '',
          );
        }).toList();
      } else {
        throw Exception("Failed to load posts (Status: ${response.statusCode})");
      }
    } on SocketException catch (e) {
      debugPrint('SocketException: $e');
      throw Exception("No internet connection");
    } catch (e) {
      debugPrint('Error: $e');
      throw Exception("Failed to load posts: $e");
    }
  }

  Future<Post> createPost(Post post) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': post.title,
          'body': post.body,
          'userId': post.userId,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return Post(
          id: responseData['id'],
          userId: responseData['userId'] ?? post.userId,
          title: responseData['title'] ?? post.title,
          body: responseData['body'] ?? post.body,
        );
      } else {
        throw Exception("Failed to create post");
      }
    } catch (e) {
      debugPrint('Error creating post: $e');
      throw Exception("Failed to create post: $e");
    }
  }
}