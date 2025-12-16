import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/chat_service.dart';
import '../../core/services/auth_service.dart';
import '../../widgets/category_card.dart';
import '../../widgets/lost_item_card.dart';
import '../chat/chat_screen.dart';
import '../claim/submit_proof_screen.dart';
import 'create_report_screen.dart';
import '../../core/services/firestore_service.dart';
import '../../core/models/models.dart';
import '../../widgets/animated_gradient_bg.dart';
import '../../core/utils/ui_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService(); // Init Service
  int _selectedCategoryIndex = 0;
  String _selectedLocation = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isFoundTabActive = true; // Toggle state

  final List<Map<String, dynamic>> _categories = [
    {'title': 'All', 'icon': Icons.grid_view},
    {'title': 'Electronics', 'icon': Icons.devices},
    {'title': 'Water Bottle', 'icon': Icons.water_drop},
    {'title': 'Accessory', 'icon': Icons.watch},
    {'title': 'Key', 'icon': Icons.vpn_key},
    {'title': 'Wallet', 'icon': Icons.account_balance_wallet},
  ];

  @override
  Widget build(BuildContext context) {
    // Logic moved to StreamBuilder
    
    return Scaffold(
      extendBodyBehindAppBar: true, // Allow body to extend behind
      body: AnimatedGradientBg(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header & Search
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Find My Stuff',
                        style: TextStyle(
                          fontSize: 28, // Larger
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Glass Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8), // Glassy
                          borderRadius: BorderRadius.circular(20), // Pill shape
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2D9CDB).withOpacity(0.1), // Blue-ish shadow
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(() => _searchQuery = value),
                          decoration: InputDecoration(
                            hintText: _isFoundTabActive ? 'Search found items...' : 'Search lost reports...',
                            hintStyle: TextStyle(color: AppColors.textGrey.withOpacity(0.7)),
                            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryBlue),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, color: AppColors.textGrey),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Modern Toggle Switch
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isFoundTabActive = true),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    gradient: _isFoundTabActive 
                                        ? const LinearGradient(colors: [AppColors.primaryBlue, AppColors.primaryLight])
                                        : null,
                                    color: _isFoundTabActive ? null : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: _isFoundTabActive
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primaryBlue.withOpacity(0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            )
                                          ]
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Found',
                                    style: TextStyle(
                                      fontWeight: _isFoundTabActive ? FontWeight.bold : FontWeight.w500,
                                      color: _isFoundTabActive ? Colors.white : AppColors.textGrey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isFoundTabActive = false),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    gradient: !_isFoundTabActive 
                                        ? const LinearGradient(colors: [Colors.orange, Colors.orangeAccent])
                                        : null,
                                    color: !_isFoundTabActive ? null : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: !_isFoundTabActive
                                        ? [
                                            BoxShadow(
                                              color: Colors.orange.withOpacity(0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            )
                                          ]
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Lost',
                                    style: TextStyle(
                                      fontWeight: !_isFoundTabActive ? FontWeight.bold : FontWeight.w500,
                                      color: !_isFoundTabActive ? Colors.white : AppColors.textGrey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Categories
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 24.0, bottom: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 90,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            return CategoryCard(
                              title: _categories[index]['title'],
                              icon: _categories[index]['icon'],
                              isSelected: _selectedCategoryIndex == index,
                              onTap: () {
                                setState(() {
                                  _selectedCategoryIndex = index;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Location Filters
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 24.0, bottom: 24.0),
                  child: SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildFilterChip('All', _selectedLocation == 'All'),
                        const SizedBox(width: 12),
                        _buildFilterChip('Hj. Anif Building', _selectedLocation == 'Hj. Anif Building'),
                        const SizedBox(width: 12),
                        _buildFilterChip('Library', _selectedLocation == 'Library'),
                        const SizedBox(width: 12),
                        _buildFilterChip('Gedung Pancasila', _selectedLocation == 'Gedung Pancasila'),
                        const SizedBox(width: 12),
                        _buildFilterChip('Parking Lot', _selectedLocation == 'Parking Lot'),
                        const SizedBox(width: 24),
                      ],
                    ),
                  ),
                ),
              ),

              // Lost Items List - Using SliverFillRemaining to fill the rest of the screen
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: StreamBuilder<List<ItemModel>>(
                    stream: _firestoreService.getFeedItems(_isFoundTabActive ? 'FOUND' : 'LOST'),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(48.0),
                          child: Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
                        );
                      }

                      final items = snapshot.data ?? [];
                      
                      // Filter items based on search query, location, and category
                      final filteredItems = items.where((item) {
                        final title = item.title.toLowerCase();
                        final location = item.location.toLowerCase();
                        final query = _searchQuery.toLowerCase();
                        
                        final matchesSearch = title.contains(query) || location.contains(query);
                        final matchesLocation = _selectedLocation == 'All' || item.location.contains(_selectedLocation.split(' ')[0]);
                        
                        // Category Filter
                        final selectedCategory = _categories[_selectedCategoryIndex]['title'];
                        final matchesCategory = selectedCategory == 'All' || item.category == selectedCategory;
                        
                        return matchesSearch && matchesLocation && matchesCategory;
                      }).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: Text(
                              _isFoundTabActive ? 'Found Items' : 'Lost Reports',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          if (filteredItems.isEmpty)
                            _buildEmptyState()
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                final isLostItem = item.type == 'LOST';
                                
                                return LostItemCard(
                                  title: item.title,
                                  description: item.description,
                                  location: item.location,
                                  imageUrl: item.imageUrl.isNotEmpty ? item.imageUrl : 'assets/images/logo.png', // Fallback image
                                  isLost: isLostItem,
                                  onChatPressed: () async {
                                    final currentUser = AuthService().currentUser;
                                    if (currentUser == null) {
                                      UiUtils.showModernSnackBar(context, 'Please login to chat', isSuccess: false);
                                      return;
                                    }

                                    // Prevent chatting with yourself
                                    if (currentUser.uid == item.userId) {
                                      UiUtils.showModernSnackBar(context, 'You cannot chat with yourself', isSuccess: false);
                                      return;
                                    }

                                    final chatId = await FirestoreService().createChat(
                                      itemId: item.id,
                                      itemName: item.title,
                                      claimantId: currentUser.uid, 
                                      finderId: item.userId,
                                    );

                                      if (context.mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatScreen(
                                              chatId: chatId,
                                              itemId: item.id,
                                              itemName: item.title,
                                              otherUserId: item.userId,
                                            ),
                                          ),
                                        );
                                      }
                                  },
                                  onClaimPressed: () {
                                      final currentUser = AuthService().currentUser;
                                      if (currentUser == null) {
                                         UiUtils.showModernSnackBar(context, 'Please login to contact owner', isSuccess: false);
                                        return;
                                      }
                                       if (currentUser.uid == item.userId) {
                                        UiUtils.showModernSnackBar(context, 'This is your own post', isSuccess: false);
                                        return;
                                      }
                                      
                                      // Navigate to ProofFormScreen
                                      // If item is LOST -> I found it -> isFoundReport = true
                                      // If item is FOUND -> I claim it -> isFoundReport = false
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProofFormScreen(
                                            item: item,
                                            isFoundReport: isLostItem,
                                          ),
                                        ),
                                      );
                                  },
                                );
                              },
                            ),
                          const SizedBox(height: 100),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ), // SafeArea
      ), // AnimatedGradientBg
    );
  }

  void _showReportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'What do you want to report?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildOptionCard(
                    context,
                    'I Lost an Item',
                    Icons.search,
                    AppColors.errorRed,
                    'LOST',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOptionCard(
                    context,
                    'I Found an Item',
                    Icons.check_circle_outline,
                    AppColors.successGreen,
                    'FOUND',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, String title, IconData icon, Color color, String type) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddReportScreen(reportType: type),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.search_off, size: 48, color: AppColors.textGrey),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nothing Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try different keywords or filters',
            style: TextStyle(
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLocation = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.white,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textGrey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
