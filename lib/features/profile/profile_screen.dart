import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/models/models.dart';
import '../auth/login_screen.dart';

import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'badges_screen.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  
  UserModel? _currentUser;
  int _lostCount = 0;
  int _foundCount = 0;
  int _returnedCount = 0; // Logic for this might need refinement based on 'resolved' items
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    
    // 1. Get User Info
    final user = await _authService.getCurrentUserModel();
    
    if (user != null) {
      // 2. Get Stats
      final lost = await _firestoreService.getUserItemCount(user.uid, 'LOST');
      final found = await _firestoreService.getUserItemCount(user.uid, 'FOUND');
      
      // For "Returned", we might count items with status 'RESOLVED' that this user found?
      // Or items this user lost that were 'RESOLVED'?
      // For now, let's just use a placeholder or potentially query resolved claimed items.
      // Let's assume 'Returned' means items I found and returned to owner.
      // Complex query, maybe skip for now or use mock.
      // Let's rely on Found items count that are resolved contextually if possible, 
      // but for V1 we can keep it 0 or mock, OR count 'FOUND' items that are 'RESOLVED'.
      // Let's try to query 'FOUND' items with status 'RESOLVED'.
      // _firestoreService doesn't have that specific query yet.
      // I'll leave it as a TODO or just show foundCount for now.
      
      if (mounted) {
        setState(() {
          _currentUser = user;
          _lostCount = lost;
          _foundCount = found;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF9F9F9),
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
      );
    }

    // Default or Empty User
    final displayName = _currentUser?.displayName ?? 'User';
    final email = _currentUser?.email ?? 'No Email';
    final photoUrl = _currentUser?.photoUrl ?? '';
    final role = 'Member'; // Static for now

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Curved Header Background
                CustomPaint(
                  painter: CurvedHeaderPainter(),
                  child: Container(
                    height: 260,
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 60, left: 24, right: 24),
                    alignment: Alignment.topCenter,
                    child: Row(
                      children: [
                        // Expanded to center the text
                        const Expanded(
                          child: Text(
                            'My Profile',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Glass Profile Card
                Positioned(
                  top: 130,
                  left: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppColors.primaryBlue, AppColors.primaryLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 42,
                            backgroundImage: photoUrl.isNotEmpty 
                                ? NetworkImage(photoUrl) 
                                : const AssetImage('assets/images/logo.png') as ImageProvider,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                role,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8E1), // Amber 50
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFFFD54F)), // Amber 300
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.stars_rounded, size: 16, color: Color(0xFFFFB300)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_currentUser?.points ?? 0} Pts',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFF57F17), // Amber 900
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(color: Color(0xFFF0F0F0), thickness: 1),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.email_rounded, 'Email', email),
                  const SizedBox(height: 12),
                  // Display real phone number or fallback
                  _buildInfoRow(
                    Icons.phone_rounded, 
                    'Phone', 
                    _currentUser?.phoneNumber.isNotEmpty == true 
                        ? _currentUser!.phoneNumber 
                        : 'Not Set'
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Spacing
      const SizedBox(height: 240),

      // Glass Stats Row
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            _buildGlassStatCard(_lostCount.toString(), 'Lost Item', const Color(0xFFFFA000)),
            const SizedBox(width: 12),
            _buildGlassStatCard(_foundCount.toString(), 'Found Item', AppColors.successGreen),
            const SizedBox(width: 12),
            _buildGlassStatCard(_returnedCount.toString(), 'Returned', AppColors.primaryBlue),
          ],
        ),
      ),

      const SizedBox(height: 24),

            // Badges Section (Dynamic)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.emoji_events, color: Color(0xFFFFC107)),
                          SizedBox(width: 8),
                          Text(
                            'My Badge',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          if (_currentUser != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BadgesScreen(userBadges: _currentUser!.badges)),
                            );
                          }
                        },
                        child: const Text(
                          'See All >',
                          style: TextStyle(color: AppColors.primaryBlue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Render badges dynamically
                  if (_currentUser != null && _currentUser!.badges.isNotEmpty) ...[
                     _buildDynamicBadgesGrid(_currentUser!.badges),
                  ] else ...[
                     const Padding(
                       padding: EdgeInsets.all(16.0),
                       child: Text('No badges yet. Return lost items to earn them!', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                     )
                  ]
                ],
              ),
            ),

      const SizedBox(height: 24),

      // Account Settings
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingsButton(context, 'Edit Profile', Icons.edit_outlined, () async {
              if (_currentUser == null) return;
              
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(user: _currentUser!),
                ),
              );
              
              // If true returned, refresh data
              if (result == true) {
                _loadProfileData();
              }
            }),
                  const SizedBox(height: 12),
                  _buildSettingsButton(context, 'Change Password', Icons.lock_outline, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                    );
                  }),
                  const SizedBox(height: 12),
                  _buildSettingsButton(context, 'Logout', Icons.logout, () async {
                    await AuthService().signOut();
                     if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  }, isWarning: true),
                  const SizedBox(height: 64)
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }


  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textGrey),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.textGrey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textDark),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGlassStatCard(String count, String label, Color accentColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: accentColor.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textGrey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicBadgesGrid(List<String> badgeIds) {
    // Show only first 4 badges max for profile preview
    final displayIds = badgeIds.take(4).toList();
    if (displayIds.isEmpty) return const SizedBox();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5, // Flattened aspect ratio for small card
      ),
      itemCount: displayIds.length,
      itemBuilder: (context, index) {
        final badge = BadgeConstants.getBadge(displayIds[index]);
        if (badge == null) return const SizedBox();
        
        return _buildBadgeCard(
          badge.name, 
          IconData(badge.iconCodePoint, fontFamily: 'MaterialIcons'), 
          Color(badge.colorValue).withOpacity(0.2), 
          Color(badge.colorValue)
        );
      },
    );
  }

  Widget _buildBadgeCard(String title, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context, String title, IconData icon, VoidCallback onTap, {bool isWarning = false}) {
    final color = isWarning ? AppColors.errorRed : AppColors.textDark;
    final iconColor = isWarning ? AppColors.errorRed : AppColors.primaryBlue;
    final bgColor = isWarning ? AppColors.errorRed.withOpacity(0.1) : AppColors.primaryLight.withOpacity(0.1);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0F0F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: isWarning ? AppColors.errorRed : AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}

class CurvedHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.primaryBlue, AppColors.primaryLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 2, size.height, 
      size.width, size.height - 60
    );
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
