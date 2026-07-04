import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomPrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<CustomPrimaryButton> createState() => _CustomPrimaryButtonState();
}

class _CustomPrimaryButtonState extends State<CustomPrimaryButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final bg = widget.backgroundColor ?? theme.colorScheme.primary;
    final fg = widget.textColor ?? Colors.white;

    return GestureDetector(
      onTapDown: widget.onPressed == null || widget.isLoading
          ? null
          : (_) => _controller.forward(),
      onTapUp: widget.onPressed == null || widget.isLoading
          ? null
          : (_) => _controller.reverse(),
      onTapCancel: widget.onPressed == null || widget.isLoading
          ? null
          : () => _controller.reverse(),
      onTap: widget.onPressed == null || widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.onPressed == null ? bg.withOpacity(0.5) : bg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.onPressed == null
                ? []
                : [
                    BoxShadow(
                      color: bg.withOpacity(isDark ? 0.3 : 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: widget.isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: fg, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.text,
                      style: GoogleFonts.plusJakartaSans(
                        color: fg,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class ContentCard extends StatelessWidget {
  final String title;
  final String category;
  final String time;
  final String? imageUrl;
  final String? duration;
  final VoidCallback? onTap;
  final String? tag;
  final Widget? trailing;

  const ContentCard({
    super.key,
    required this.title,
    required this.category,
    required this.time,
    this.imageUrl,
    this.duration,
    this.onTap,
    this.tag,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (imageUrl != null)
                  Stack(
                    children: [
                      Hero(
                        tag: 'content_img_$title',
                        child: Image.network(
                          imageUrl!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180,
                              color: theme.colorScheme.primary.withOpacity(0.05),
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: theme.colorScheme.primary.withOpacity(0.4),
                                  size: 40,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (tag != null)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              tag!.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      if (duration != null)
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              duration!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              category.toUpperCase(),
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            time,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                height: 1.3,
                              ),
                            ),
                          ),
                          if (trailing != null) ...[
                            const SizedBox(width: 8),
                            trailing!,
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DonationChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const DonationChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final selectedBg = theme.colorScheme.primary;
    final unselectedBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    final selectedFg = Colors.white;
    final unselectedFg = isDark ? Colors.white70 : Colors.black87;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Material(
        color: isSelected ? selectedBg : unselectedBg,
        borderRadius: BorderRadius.circular(12),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? Colors.transparent 
                    : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)),
                width: 1.0,
              ),
            ),