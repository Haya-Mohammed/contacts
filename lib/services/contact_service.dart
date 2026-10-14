import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:untitled55/models/contact_model.dart';

class ContactService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com/users';
  static const Map<String, String> _headers = {'Content-Type': 'application/json; charset=UTF-8'};
  static const Duration _timeout = Duration(seconds: 15);

  /// JSONPlaceholder فيه 10 مستخدمين حقيقيين بس. أي id أكبر منه هو جهة
  /// أضفناها محلياً (السيرفر وهمي ما بيحفظها)، فلو بعتنا PUT/DELETE لها
  /// السيرفر بيرجع 500. عشان هيك بنتعامل معها محلياً.
  static const int _lastServerId = 10;

  bool _isLocalOnly(int? id) => id == null || id > _lastServerId;

  /// بتحوّل أخطاء الشبكة لرسائل مفهومة للمستخدم.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on TimeoutException {
      throw Exception('انتهت مهلة الاتصال، حاول مرة ثانية');
    } on http.ClientException {
      throw Exception('تعذّر الاتصال بالسيرفر، تأكد من الإنترنت');
    } on FormatException {
      throw Exception('رد السيرفر غير صالح');
    }
  }

  // GET
  Future<List<Contact>> getContacts() {
    return _guard(() async {
      final response = await http.get(Uri.parse(_baseUrl)).timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Contact.fromJson(item as Map<String, dynamic>)).toList();
      }
      throw Exception('فشل تحميل جهات الاتصال (${response.statusCode})');
    });
  }

  // POST
  Future<Contact> addContact(Contact contact) {
    return _guard(() async {
      final response = await http
          .post(Uri.parse(_baseUrl), headers: _headers, body: jsonEncode(contact.toJson()))
          .timeout(_timeout);

      if (response.statusCode == 201) {
        return Contact.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
      throw Exception('فشل إضافة جهة الاتصال (${response.statusCode})');
    });
  }

  // PUT
  Future<Contact> updateContact(Contact contact) {
    return _guard(() async {
      if (_isLocalOnly(contact.id)) return contact;

      final response = await http
          .put(
            Uri.parse('$_baseUrl/${contact.id}'),
            headers: _headers,
            body: jsonEncode(contact.toJson()),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return Contact.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
      throw Exception('فشل تعديل جهة الاتصال (${response.statusCode})');
    });
  }

  // DELETE
  Future<void> deleteContact(int id) {
    return _guard(() async {
      if (_isLocalOnly(id)) return;

      final response = await http.delete(Uri.parse('$_baseUrl/$id')).timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('فشل حذف جهة الاتصال (${response.statusCode})');
      }
    });
  }
}
