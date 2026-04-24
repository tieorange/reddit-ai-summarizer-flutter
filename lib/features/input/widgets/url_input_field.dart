import 'package:flutter/material.dart';

class UrlInputField extends StatelessWidget {
  const UrlInputField({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.errorText,
  });

  final TextEditingController controller;
  final VoidCallback onSubmitted;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.url,
      autocorrect: false,
      decoration: InputDecoration(
        hintText: 'https://www.reddit.com/r/...',
        labelText: 'Reddit Post URL',
        errorText: errorText,
        prefixIcon: const Icon(Icons.link_rounded),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () => controller.clear(),
              )
            : null,
      ),
      onSubmitted: (_) => onSubmitted(),
    );
  }
}
