import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:google_fonts/google_fonts.dart';

class MarkdownTheme {
  static MarkdownStyleSheet sheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: theme.textTheme.bodyLarge?.copyWith(
        height: 1.6,
        letterSpacing: 0.2,
        color: isDark ? Colors.grey[300] : Colors.grey[800],
      ),
      h1: GoogleFonts.outfit(
        textStyle: theme.textTheme.headlineMedium,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
      h2: GoogleFonts.outfit(
        textStyle: theme.textTheme.headlineSmall,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
      h3: GoogleFonts.outfit(
        textStyle: theme.textTheme.titleLarge,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : Colors.black,
      ),
      listBullet: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            width: 3,
          ),
        ),
      ),
      blockquotePadding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
      blockquote: theme.textTheme.bodyLarge?.copyWith(
        color: isDark ? Colors.grey[400] : Colors.grey[600],
        fontStyle: FontStyle.italic,
        height: 1.6,
      ),
      code: GoogleFonts.firaCode(
        textStyle: theme.textTheme.bodyMedium?.copyWith(
          backgroundColor: Colors.transparent,
          color: isDark ? Colors.orange[200] : Colors.orange[900],
        ),
      ),
      codeblockPadding: const EdgeInsets.all(16),
      codeblockDecoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
    );
  }
}
