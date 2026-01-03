import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/home_controller.dart';
import '../../widgets/home/home_header.dart';
import '../../widgets/home/custom_search_bar.dart';
import '../../widgets/home/category_list.dart';
import '../../widgets/home/recommended_card.dart';
import '../../widgets/home/trusted_stores_grid.dart';
import '../../views/company/company_page.dart';
import '../../views/wishlist/wishlist_page.dart';
import '../../widgets/home/filter_bottom_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeController>().loadData();
    });
  }

  void _onItemTapped(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (index == 0) {
      context.read<HomeController>().loadData();
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _selectedIndex == 0
          ? GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: SafeArea(child: _buildHomeView()),
            )
          : const WishlistPage(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Cart',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }

  Widget _buildHomeView() {
    return Consumer<HomeController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeHeader(),
                const SizedBox(height: 16),
                CustomSearchBar(
                  optionsBuilder: (textEditingValue) {
                    return controller.getSuggestions(textEditingValue.text);
                  },
                  onSelected: (option) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CompanyPage(store: option),
                      ),
                    );
                  },
                  onFilterTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const FilterBottomSheet(),
                    );
                  },
                  hasActiveFilters: controller.hasActiveFilters,
                ),
                if (controller.hasActiveFilters) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        if (controller.selectedSort != SortOption.defaultSort)
                          _buildFilterChip(
                            label: _getSortLabel(controller.selectedSort),
                            onDeleted: controller.resetSort,
                          ),
                        ...controller.selectedOffers.map(
                          (offer) => _buildFilterChip(
                            label: _getOfferLabel(offer),
                            onDeleted: () =>
                                controller.removeOfferFilter(offer),
                          ),
                        ),
                        if (controller.minRating != null)
                          _buildFilterChip(
                            label: '${controller.minRating} & Up',
                            onDeleted: controller.removeRatingFilter,
                          ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: TextButton(
                            onPressed: controller.clearFilters,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: Colors.grey[100],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Clear All',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                CategoryList(categories: controller.categories),
                const SizedBox(height: 24),
                _buildSectionHeader('Recommended for you', () {
                  FocusManager.instance.primaryFocus?.unfocus();
                }),
                const SizedBox(height: 12),
                SizedBox(
                  height: 210, // Height for recommended cards
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: controller.recommendedStores.length,
                    itemBuilder: (context, index) {
                      return RecommendedCard(
                        store: controller.recommendedStores[index],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Trusted Stores', () {
                  FocusManager.instance.primaryFocus?.unfocus();
                }),
                const SizedBox(height: 12),
                TrustedStoresGrid(
                  stores: controller.hasActiveFilters
                      ? controller.filteredStores
                      : controller.stores,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onViewAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        if (title == 'Recommended for you')
          GestureDetector(
            onTap: onViewAll,
            child: const Text(
              'View all',
              style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDeleted,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF006D5B),
        deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white),
        onDeleted: onDeleted,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: -2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide.none,
        ),
      ),
    );
  }

  String _getSortLabel(SortOption sort) {
    switch (sort) {
      case SortOption.defaultSort:
        return 'Default';
      case SortOption.newArrivals:
        return 'New Arrivals';
      case SortOption.rating:
        return 'Rating';
      case SortOption.deliveryTime:
        return 'Delivery Time';
    }
  }

  String _getOfferLabel(OfferOption offer) {
    switch (offer) {
      case OfferOption.freeShipping:
        return 'Free Shipping';
      case OfferOption.discounts:
        return 'Discounts';
    }
  }
}
