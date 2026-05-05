import 'package:flutter/material.dart';

class AppListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback onTap;

  const AppListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4), // soft grey
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),

        leading: leading,

        title: Text(
          title,
          style: TextStyle(fontFamily: "PTSerif", color: primary, fontSize: 16),
        ),

        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: const TextStyle(
                  fontFamily: "PTSerif",
                  fontSize: 12,
                  color: Colors.black54,
                ),
              )
            : null,

        trailing: trailing,

        onTap: onTap,
      ),
    );
  }
}
