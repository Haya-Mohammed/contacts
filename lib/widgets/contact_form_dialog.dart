import 'package:flutter/material.dart';
import 'package:untitled55/models/contact_model.dart';

Future<Contact?> showContactFormDialog(BuildContext context, {Contact? initial}) {
  return showDialog<Contact>(
    context: context,
    builder: (_) => _ContactFormDialog(initial: initial),
  );
}

class _ContactFormDialog extends StatefulWidget {
  final Contact? initial;
  const _ContactFormDialog({this.initial});

  @override
  State<_ContactFormDialog> createState() => _ContactFormDialogState();
}

class _ContactFormDialogState extends State<_ContactFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial?.name);
    _email = TextEditingController(text: widget.initial?.email);
    _phone = TextEditingController(text: widget.initial?.phone);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final base = widget.initial ?? const Contact(name: '', email: '', phone: '');
    Navigator.pop(
      context,
      base.copyWith(name: _name.text.trim(), email: _email.text.trim(), phone: _phone.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdit ? 'تعديل جهة اتصال' : 'جهة اتصال جديدة'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'الاسم'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'الاسم مطلوب' : null,
              ),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'الإيميل'),
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return 'الإيميل مطلوب';
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'إيميل غير صالح';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'الجوال'),
                onFieldSubmitted: (_) => _submit(),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'رقم الجوال مطلوب' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
        FilledButton(onPressed: _submit, child: Text(_isEdit ? 'حفظ' : 'إضافة')),
      ],
    );
  }
}
