import 'package:flutter/material.dart';

class AppPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;

  const AppPasswordField({
    super.key,
    required this.controller,
    required this.hint,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: widget.controller,
      obscureText: obscure,
      style: const TextStyle(fontFamily: "PTSerif"),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF4EBE0),
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.lock, color: Colors.grey),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              obscure = !obscure;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}