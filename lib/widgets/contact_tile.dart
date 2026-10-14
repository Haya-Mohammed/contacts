import 'package:flutter/material.dart';
import 'package:untitled55/models/contact_model.dart';

/// عنصر جهة اتصال واحد: كبسة طويلة للتعديل + سحب للحذف.
class ContactTile extends StatelessWidget {
  final Contact contact;
  final VoidCallback onLongPress;
  final Future<bool?> Function(DismissDirection) confirmDismiss;
  final VoidCallback onDismissed;

  const ContactTile({
    super.key,
    required this.contact,
    required this.onLongPress,
    required this.confirmDismiss,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final initial = contact.name.isNotEmpty ? contact.name.characters.first : '?';

    return Dismissible(
      key: ValueKey('contact_${contact.id}'),
      direction: DismissDirection.horizontal,
      background: const _DeleteBackground(),
      secondaryBackground: const _DeleteBackground(),
      confirmDismiss: confirmDismiss,
      onDismissed: (_) => onDismissed(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ListTile(
          onLongPress: onLongPress,
          leading: CircleAvatar(child: Text(initial)),
          title: Text(contact.name),
          subtitle: Text('${contact.email}\n${contact.phone}'),
          isThreeLine: true,
        ),
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
      alignment: Alignment.center,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.delete, color: Colors.white),
          Icon(Icons.delete, color: Colors.white),
        ],
      ),
    );
  }
}
