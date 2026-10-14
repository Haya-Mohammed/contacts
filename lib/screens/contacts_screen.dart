import 'package:flutter/material.dart';
import 'package:untitled55/models/contact_model.dart';

import '../services/contact_service.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/contact_form_dialog.dart';
import '../widgets/contact_tile.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _service = ContactService();

  late Future<void> _loadFuture;
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadFuture = _load();
  }

  /// بتجيب القائمة من السيرفر وبتخزنها محلياً، عشان نقدر نعدّل عليها
  /// (إضافة/تعديل/حذف) بدون ما نعيد الطلب كل مرة.
  Future<void> _load() async {
    _contacts = await _service.getContacts();
  }

  void _reload() {
    setState(() => _loadFuture = _load());
  }

  String _msg(Object e) => e.toString().replaceFirst('Exception: ', '');

  void _showSnack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  // ---------- POST ----------
  Future<void> _onAdd() async {
    final draft = await showContactFormDialog(context);
    if (draft == null) return;

    try {
      final created = await _service.addContact(draft);
      // JSONPlaceholder بيرجع دايماً id = 11، فنعطي id محلي فريد
      // عشان ما يتكرر الـ key في Dismissible.
      final nextId = _contacts.fold<int>(0, (max, c) => (c.id ?? 0) > max ? (c.id ?? 0) : max) + 1;
      setState(() => _contacts.add(created.copyWith(id: nextId)));
      _showSnack('تمت الإضافة');
    } catch (e) {
      _showSnack(_msg(e));
    }
  }

  // ---------- PUT ----------
  Future<void> _onEdit(Contact contact) async {
    final edited = await showContactFormDialog(context, initial: contact);
    if (edited == null) return;

    try {
      final updated = await _service.updateContact(edited);
      final index = _contacts.indexWhere((c) => c.id == contact.id);
      if (index != -1) {
        setState(() => _contacts[index] = updated);
      }
      _showSnack('تم التعديل');
    } catch (e) {
      _showSnack(_msg(e));
    }
  }

  // ---------- DELETE ----------
  Future<bool> _confirmAndDelete(Contact contact) async {
    final confirmed = await showConfirmDeleteDialog(context, contact.name);
    if (!confirmed) return false;

    try {
      await _service.deleteContact(contact.id!);
      return true; // السيرفر أكّد، فنخلي Dismissible يكمل
    } catch (e) {
      _showSnack(_msg(e));
      return false; // فشل الحذف، بترجع الجهة مكانها
    }
  }

  void _removeLocally(Contact contact) {
    setState(() => _contacts.removeWhere((c) => c.id == contact.id));
    _showSnack('تم حذف ${contact.name}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('دفتر جهات الاتصال')),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAdd,
        tooltip: 'إضافة جهة اتصال',
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(_msg(snapshot.error!), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _reload,
                      icon: const Icon(Icons.refresh),
                      label: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (_contacts.isEmpty) {
            return const Center(child: Text('لا توجد جهات اتصال'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              _reload();
              await _loadFuture;
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 8, bottom: 88),
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                return ContactTile(
                  contact: contact,
                  onLongPress: () => _onEdit(contact),
                  confirmDismiss: (_) => _confirmAndDelete(contact),
                  onDismissed: () => _removeLocally(contact),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
