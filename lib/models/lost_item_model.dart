class LostItemModel {
  String name;
  String iconPath;
  String category;
  String description;
  String dateLost;
  String locationLost;
  bool isFound;

  LostItemModel({
    required this.name,
    required this.iconPath,
    required this.category,
    required this.description,
    required this.dateLost,
    required this.locationLost,
    required this.isFound,
  });

  static List<LostItemModel> getLostItems() {
    List<LostItemModel> lostItems = [];

    lostItems.add(
      LostItemModel(
        name: 'Iphone', 
        iconPath: 'assets/icons/ip12.jpg',
        category: 'Smartphone', 
        description: 'Iphone 12, black, brand new', 
        dateLost: '2025-10-01', 
        locationLost: 'Near USU Library',
        isFound: false,
      ),
    );
    lostItems.add(
      LostItemModel(
        name: 'Laptop', 
        iconPath: 'assets/icons/macbook.jpg',
        category: 'Others', 
        description: 'Macbook Pro, silver, 2020 edition', 
        dateLost: '2025-10-09', 
        locationLost: 'Near Pendopo Fasilkom-TI',
        isFound: true,
      ),
    );
    return lostItems;
  }
}