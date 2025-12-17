import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// In-App Notification Banner - Slides in from top
/// 
/// Usage:
/// ```dart
/// InAppNotification.show(
///   context,
///   title: 'New Claim!',
///   message: 'John wants to claim your item',
///   avatarUrl: 'https://...',
///   onTap: () => Navigator.push(...),
/// );
/// ```
class InAppNotification {
  static OverlayEntry? _currentOverlay;

  /// Show a top slide-in notification
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    String? avatarUrl,
    IconData icon = Icons.notifications,
    Color iconColor = AppColors.primaryBlue,
    VoidCallback? onTap,
    VoidCallback? onActionTap,
    String? actionLabel,
    Duration duration = const Duration(seconds: 4),
  }) {
    // Remove existing notification if any
    dismiss();

    final overlay = Overlay.of(context);
    
    _currentOverlay = OverlayEntry(
      builder: (context) => _NotificationBanner(
        title: title,
        message: message,
        avatarUrl: avatarUrl,
        icon: icon,
        iconColor: iconColor,
        onTap: () {
          dismiss();
          onTap?.call();
        },
        onActionTap: () {
          dismiss();
          onActionTap?.call();
        },
        actionLabel: actionLabel,
        onDismiss: dismiss,
        duration: duration,
      ),
    );

    overlay.insert(_currentOverlay!);
  }

  /// Dismiss current notification
  static void dismiss() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}

class _NotificationBanner extends StatefulWidget {
  final String title;
  final String message;
  final String? avatarUrl;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;
  final VoidCallback? onActionTap;
  final String? actionLabel;
  final VoidCallback onDismiss;
  final Duration duration;

  const _NotificationBanner({
    required this.title,
    required this.message,
    this.avatarUrl,
    required this.icon,
    required this.iconColor,
    this.onTap,
    this.onActionTap,
    this.actionLabel,
    required this.onDismiss,
    required this.duration,
  });

  @override
  State<_NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<_NotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Start animation
    _controller.forward();

    // Auto dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismissWithAnimation();
      }
    });
  }

  void _dismissWithAnimation() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: GestureDetector(
                onTap: widget.onTap,
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity! < 0) {
                    _dismissWithAnimation();
                  }
                },
                child: _buildBanner(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon/Avatar
              _buildLeading(),
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textGrey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Action button or arrow
              if (widget.actionLabel != null) ...[
                const SizedBox(width: 8),
                _buildActionButton(),
              ] else ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textGrey.withOpacity(0.5),
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeading() {
    if (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [AppColors.primaryLight, AppColors.primaryBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            widget.avatarUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildIconFallback(),
          ),
        ),
      );
    }
    return _buildIconFallback();
  }

  Widget _buildIconFallback() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            widget.iconColor.withOpacity(0.2),
            widget.iconColor.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        widget.icon,
        color: widget.iconColor,
        size: 22,
      ),
    );
  }

  Widget _buildActionButton() {
    return GestureDetector(
      onTap: widget.onActionTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          widget.actionLabel!,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

/// Extension for easy access
extension InAppNotificationContext on BuildContext {
  void showInAppNotification({
    required String title,
    required String message,
    String? avatarUrl,
    IconData icon = Icons.notifications,
    Color iconColor = AppColors.primaryBlue,
    VoidCallback? onTap,
    VoidCallback? onActionTap,
    String? actionLabel,
    Duration duration = const Duration(seconds: 4),
  }) {
    InAppNotification.show(
      this,
      title: title,
      message: message,
      avatarUrl: avatarUrl,
      icon: icon,
      iconColor: iconColor,
      onTap: onTap,
      onActionTap: onActionTap,
      actionLabel: actionLabel,
      duration: duration,
    );
  }
}
