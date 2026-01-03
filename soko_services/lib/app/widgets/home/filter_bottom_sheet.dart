import 'package:flutter/material.dart';
import '../../controllers/home_controller.dart';
import 'package:provider/provider.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late SortOption _tempSort;
  late Set<OfferOption> _tempOffers;
  double? _tempMinRating;

  @override
  void initState() {
    super.initState();
    // Initialize with current values from controller
    final controller = context.read<HomeController>();
    _tempSort = controller.selectedSort;
    _tempOffers = Set.from(controller.selectedOffers);
    _tempMinRating = controller.minRating;
  }

  void _applyFilters() {
    context.read<HomeController>().applyFilters(
      sort: _tempSort,
      offers: _tempOffers,
      minRating: _tempMinRating,
    );
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _tempSort = SortOption.defaultSort;
      _tempOffers = {};
      _tempMinRating = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle & Header
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter & Sort',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.black54,
                    ),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SORT BY
                  _buildSectionTitle('SORT BY'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildSortChip('Default', SortOption.defaultSort),
                      _buildSortChip('New Arrivals', SortOption.newArrivals),
                      _buildSortChip('Rating', SortOption.rating),
                      _buildSortChip('Delivery Time', SortOption.deliveryTime),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // OFFERS
                  _buildSectionTitle('OFFERS'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildOfferChip(
                        'Free Shipping',
                        OfferOption.freeShipping,
                        Icons.local_shipping_outlined,
                      ),
                      _buildOfferChip(
                        'Discounts',
                        OfferOption.discounts,
                        Icons.local_offer_outlined,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // RATING
                  _buildSectionTitle('RATING'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F9F8), // Very subtle teal tint
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.teal.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStarIcon(1, _tempMinRating ?? 0),
                            const SizedBox(width: 8),
                            _buildStarIcon(2, _tempMinRating ?? 0),
                            const SizedBox(width: 8),
                            _buildStarIcon(3, _tempMinRating ?? 0),
                            const SizedBox(width: 8),
                            _buildStarIcon(4, _tempMinRating ?? 0),
                            const SizedBox(width: 8),
                            _buildStarIcon(5, _tempMinRating ?? 0),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _tempMinRating != null
                              ? '${_tempMinRating?.toStringAsFixed(0)} Stars & Up'
                              : 'Any Rating',
                          style: TextStyle(
                            color: _tempMinRating != null
                                ? Colors.teal
                                : Colors.grey,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Actions
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _clearFilters,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      foregroundColor: Colors.grey[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: const Text(
                      'Clear All',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: const Color(0xFF006D5B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.grey,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildSortChip(String label, SortOption value) {
    final bool isSelected = _tempSort == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tempSort = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF006D5B) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? const Color(0xFF006D5B) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildOfferChip(String label, OfferOption value, IconData icon) {
    final bool isSelected = _tempOffers.contains(value);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _tempOffers.remove(value);
          } else {
            _tempOffers.add(value);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF006D5B).withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF006D5B) : Colors.grey[300]!,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? const Color(0xFF006D5B) : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF006D5B) : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarIcon(int value, double currentRating) {
    final bool isFilled = value <= currentRating;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_tempMinRating == value.toDouble()) {
            _tempMinRating = null;
          } else {
            _tempMinRating = value.toDouble();
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          Icons.star_rounded,
          size: 40,
          color: isFilled ? const Color(0xFFFFB300) : Colors.grey[300],
        ),
      ),
    );
  }
}
