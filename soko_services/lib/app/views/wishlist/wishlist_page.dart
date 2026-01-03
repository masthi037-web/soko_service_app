import 'package:flutter/material.dart';
import '../../widgets/wishlist/wishlist_item_card.dart';
import 'package:provider/provider.dart';
import '../../controllers/wishlist_controller.dart';
import '../../views/company/company_page.dart';
import '../../widgets/home/trusted_stores_grid.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light grey background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Wishlist',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.search,
                      size: 24,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Favorite Brands Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Favorite Stores',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Consumer<WishlistController>(
                    builder: (context, controller, child) {
                      if (controller.wishlistStores.length <= 4) {
                        return const SizedBox.shrink();
                      }
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                appBar: AppBar(
                                  title: const Text('Favorite Stores'),
                                ),
                                body: SingleChildScrollView(
                                  padding: const EdgeInsets.all(16),
                                  child: TrustedStoresGrid(
                                    stores: controller.wishlistStores,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'VIEW ALL',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Brands List
              Consumer<WishlistController>(
                builder: (context, controller, child) {
                  if (controller.wishlistStores.isEmpty) {
                    return SizedBox(
                      height: 130,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite_border,
                              color: Colors.grey[400],
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No favorite stores',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return SizedBox(
                    height: 130,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.wishlistStores.length,
                      itemBuilder: (context, index) {
                        final store = controller.wishlistStores[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CompanyPage(store: store),
                              ),
                            );
                          },
                          child: _BrandAvatar(
                            name: store.companyName ?? 'Unknown',
                            image: store.logo ?? '',
                            color: Colors.teal.withValues(alpha: 0.05),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Saved Items Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Saved Items',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '6 items',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Product Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.62,
                children: const [
                  WishlistItemCard(
                    imageUrl:
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR6A7LCSH1gKyLyd3qgAeR0qQzU5nF_nQ-J8g&s',
                    brandName: 'The Clay Studio',
                    productName: 'Artisan Ceramic Vase',
                    price: '₹48',
                  ),
                  WishlistItemCard(
                    imageUrl:
                        'https://assets.myntassets.com/h_1440,q_100,w_1080/v1/assets/images/25134268/2023/9/25/67635677-4923-452f-90e6-993d3957864f1695646194386MarksSpencerWomenBlueSolidTailoredJacket1.jpg',
                    brandName: 'Neon Threads',
                    productName: 'Abstract Neon Coat',
                    price: '₹120',
                  ),
                  WishlistItemCard(
                    imageUrl:
                        'https://www.ikea.com/in/en/images/products/lisabo-chair-ash__0803522_pe768789_s5.jpg?f=s',
                    brandName: 'Timber & Co.',
                    productName: 'Oak Minimalist Chair',
                    price: '₹249',
                    isLowStock: true,
                  ),
                  WishlistItemCard(
                    imageUrl:
                        'https://m.media-amazon.com/images/I/71Y8M3D7HCL._AC_UF894,1000_QL80_.jpg',
                    brandName: 'Scented Soul',
                    productName: 'Lavender Soy Candle',
                    price: '₹22',
                  ),
                  WishlistItemCard(
                    imageUrl:
                        'https://cdn.fynd.com/v2/falling-surf-7c8bb8/fyprod/wrkr/products/pictures/item/free/original/3G-C55x2v-Silver-Pendant-w-Chain---925-Sterling-Silver_1.jpeg',
                    brandName: 'Luna Silver',
                    productName: 'Sterling Moon Pendant',
                    price: '₹85',
                  ),
                  WishlistItemCard(
                    imageUrl:
                        'https://www.kingarthurbaking.com/sites/default/files/styles/featured_image/public/2023-01/sourdough-starter_04.jpg?itok=yU_jC3g3',
                    brandName: 'Grain & Co',
                    productName: 'Sourdough Starter Kit',
                    price: '₹35',
                    isRestocked: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandAvatar extends StatelessWidget {
  final String name;
  final String image;
  final Color color;

  const _BrandAvatar({
    required this.name,
    required this.image,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.teal.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: color,
              backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
              child: image.isEmpty
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: Colors.teal[700],
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
