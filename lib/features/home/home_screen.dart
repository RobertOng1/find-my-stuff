import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/category_card.dart';
import '../../widgets/lost_item_card.dart';
import '../chat/chat_screen.dart';
import '../claim/proof_form_screen.dart';
import 'add_report_screen.dart';
import '../../core/models/models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  String _selectedLocation = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isFoundTabActive = true; // Toggle state

  final List<Map<String, dynamic>> _categories = [
    {'title': 'Electronics', 'icon': Icons.devices},
    {'title': 'Water Bottle', 'icon': Icons.water_drop},
    {'title': 'Accessory', 'icon': Icons.watch},
    {'title': 'Key', 'icon': Icons.vpn_key},
    {'title': 'Wallet', 'icon': Icons.account_balance_wallet},
  ];

  // Mock Data
  final List<Map<String, dynamic>> _allLostItems = [
    {
      'title': 'Blue Backpack',
      'description': 'Old, slightly dirty polo beach backpack',
      'location': 'Hj. Anif Joint Lecture Building',
      'type': 'FOUND',
    },
    {
      'title': 'iPhone 13 Pro',
      'description': 'Black case with a sticker on the back',
      'location': 'Library, 2nd Floor',
      'type': 'LOST',
    },
    {
      'title': 'Water Bottle',
      'description': 'Tupperware brand, blue color',
      'location': 'Canteen',
      'type': 'FOUND',
    },
    {
      'title': 'Brown Wallet',
      'description': 'Leather wallet with ID card',
      'location': 'Parking Lot',
      'type': 'LOST',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter items based on search query, location, and TOGGLE STATE
    final filteredItems = _allLostItems.where((item) {
      final title = item['title']!.toLowerCase();
      final location = item['location']!.toLowerCase();
      final query = _searchQuery.toLowerCase();
      final type = item['type'];
      
      final matchesSearch = title.contains(query) || location.contains(query);
      final matchesLocation = _selectedLocation == 'All' || item['location']!.contains(_selectedLocation.split(' ')[0]);
      
      // Toggle Logic
      final matchesType = _isFoundTabActive ? type == 'FOUND' : type == 'LOST';

      return matchesSearch && matchesLocation && matchesType;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Light grey background for dashboard
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header & Search
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lost Item',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: _isFoundTabActive ? 'Search found items...' : 'Search lost reports...',
                        hintStyle: const TextStyle(color: AppColors.textGrey),
                        prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: AppColors.textGrey),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Toggle Switch
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isFoundTabActive = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isFoundTabActive ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: _isFoundTabActive
                                    ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Found Nearby',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _isFoundTabActive ? AppColors.primaryBlue : AppColors.textGrey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isFoundTabActive = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isFoundTabActive ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: !_isFoundTabActive
                                    ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Looking For',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: !_isFoundTabActive ? Colors.orange : AppColors.textGrey,
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

            // Categories
            Padding(
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

            // Location Filters
            Padding(
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
                    _buildFilterChip('Canteen', _selectedLocation == 'Canteen'),
                    const SizedBox(width: 12),
                    _buildFilterChip('Parking Lot', _selectedLocation == 'Parking Lot'),
                    const SizedBox(width: 24),
                  ],
                ),
              ),
            ),

            // Lost Items List
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
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
                    Expanded(
                      child: filteredItems.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                final isLostItem = item['type'] == 'LOST';
                                
                                return LostItemCard(
                                  title: item['title']!,
                                  description: item['description']!,
                                  location: item['location']!,
                                  imageUrl: 'assets/images/logo.png',
                                  isLost: isLostItem,
                                  onChatPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatScreen(itemName: item['title']!),
                                      ),
                                    );
                                  },
                                  onClaimPressed: () {
                                    if (isLostItem) {
                                      // Logic for "I Found It" - Go to Chat for now
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatScreen(itemName: item['title']!),
                                        ),
                                      );
                                    } else {
                                      // Logic for "Claim"
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProofFormScreen(
                                            item: ItemModel(
                                              id: 'mock_item_id_${index}',
                                              userId: 'mock_finder_id',
                                              title: item['title']!,
                                              description: item['description']!,
                                              location: item['location']!,
                                              imageUrl: 'assets/images/logo.png',
                                              type: item['type']!,
                                              category: 'General',
                                              date: DateTime.now(),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showReportOptions(context);
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textGrey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
