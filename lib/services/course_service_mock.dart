import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/course_model.dart';

class CourseServiceMock {
  Future<List<Course>> fetchCourses() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final jsonString = await rootBundle.loadString('assets/mock_data/courses.json');
    final data = json.decode(jsonString) as List<dynamic>;
    return data.map((e) => Course.fromJson(e as Map<String, dynamic>)).toList();
  }
}
