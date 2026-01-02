import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/home_controller.dart';
import '../../widgets/home/home_header.dart';
import '../../widgets/home/custom_search_bar.dart';
import '../../widgets/home/category_list.dart';
import '../../widgets/home/recommended_card.dart';
import '../../widgets/home/trusted_stores_grid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeController>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<HomeController>(
              builder: (context, controller, child) {
                if (controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HomeHeader(),
                    const SizedBox(height: 16),
                    const CustomSearchBar(),
                    const SizedBox(height: 24),
                    CategoryList(categories: controller.categories),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Recommended for you', () {}),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 210, // Height for recommended cards
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.recommendedStores.length,
                        itemBuilder: (context, index) {
                          return RecommendedCard(
                            store: controller.recommendedStores[index],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Trusted Stores', () {}),
                    const SizedBox(height: 12),
                    TrustedStoresGrid(stores: controller.stores),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
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
}
