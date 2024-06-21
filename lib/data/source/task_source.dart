import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:ploying_app/common/urls.dart';
import 'package:http/http.dart' as http;
import 'package:d_method/d_method.dart';
import 'package:ploying_app/data/models/task.dart';

class TaskSource {
  static const _baseURL = '${URLs.host}/tasks';

  static Future<bool> add(
    String title,
    String description,
    String dueDate,
    int userId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(_baseURL),
        body: jsonEncode({
          "title": title,
          "description": description,
          "status": "Queue",
          "dueDate": dueDate,
          "userId": userId
        }),
      );
      DMethod.logResponse(response);

      return response.statusCode == 201;
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return false;
    }
  }

  static Future<bool> delete(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseURL/$id'),
      );
      DMethod.logResponse(response);

      return response.statusCode == 200;
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return false;
    }
  }

  static Future<bool> submit(int id, XFile xfile) async {
    try {
      final request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$_baseURL/$id/submit'),
      )
        ..fields['submitDate'] = DateTime.now().toIso8601String()
        ..files.add(
          await http.MultipartFile.fromPath(
            'attachment',
            xfile.path,
            filename: xfile.name,
          ),
        );
      final response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return false;
    }
  }

   static Future<bool> reject(int id, String reason) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseURL/$id/reject'),
        body: {
          "reason": reason,
          "rejectedDate": DateTime.now().toIso8601String(),
        },
      );
      DMethod.logResponse(response);

      return response.statusCode == 200;
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return false;
    }
  }

  static Future<bool> fixToQueue(int id, int revision) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseURL/$id/fix'),
        body: {
          "revision": '$revision',
        },
      );
      DMethod.logResponse(response);

      return response.statusCode == 200;
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return false;
    }
  }

  static Future<bool> approve(int id) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseURL/$id/approve'),
        body: {
          "approvedDate": DateTime.now().toIso8601String(),
        },
      );
      DMethod.logResponse(response);

      return response.statusCode == 200;
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return false;
    }
  }

  
  static Future<Task?> findById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseURL/$id'),
      );
      DMethod.logResponse(response);

      if (response.statusCode == 200) {
        Map resBody = jsonDecode(response.body);
        return Task.fromJson(Map.from(resBody));
      }

      return null;
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return null;
    }
  }

  static Future<List<Task>?> needToBeReviewed() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseURL/review/asc'),
      );
      DMethod.logResponse(response);

      if (response.statusCode == 200) {
        List resBody = jsonDecode(response.body);
        return resBody.map((e) => Task.fromJson(Map.from(e))).toList();
      }

      return null;
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return null;
    }
  }

  static Future<List<Task>?> progress(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseURL/progress/$userId'),
      );
      DMethod.logResponse(response);

      if (response.statusCode == 200) {
        List resBody = jsonDecode(response.body);
        return resBody.map((e) => Task.fromJson(Map.from(e))).toList();
      }

      return null;
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return null;
    }
  }

  static Future<Map?> statistic(int userId) async {
    List listStatus = ['Queue', 'Review', 'Approved', 'Rejected'];
    Map stat = {};
    try {
      final response = await http.get(
        Uri.parse('$_baseURL/stat/$userId'),
      );
      DMethod.logResponse(response);

      if (response.statusCode == 200) {
        List resBody = jsonDecode(response.body);
        for (String status in listStatus) {
          Map? found = resBody.where((e) => e['status'] == status).firstOrNull;
          stat[status] = found?['total'] ?? 0;
        }
        return stat;
      }

      return null;
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return null;
    }
  }

  static Future<List<Task>?> whereUserAndStatus(
      int userId, String status) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseURL/user/$userId/$status'),
      );
      DMethod.logResponse(response);

      if (response.statusCode == 200) {
        List resBody = jsonDecode(response.body);
        return resBody.map((e) => Task.fromJson(Map.from(e))).toList();
      }

      return null;
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return null;
    }
  }
}
