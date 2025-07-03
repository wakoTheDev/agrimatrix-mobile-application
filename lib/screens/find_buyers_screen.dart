import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/app_models.dart';

class FindBuyersScreen extends StatefulWidget {
  final List<EnhancedListing> listings;
  final List<AppUser> users;
  final Function(String, String) onContactBuyer;

  const FindBuyersScreen({
    super.key,
    required this.listings,
    required this.users,
    required this.onContactBuyer,
  });

  @override
  State<FindBuyersScreen> createState() => _FindBuyersScreenState();
}

class _FindBuyersScreenState extends State<FindBuyersScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _organicOnly = false;
  RangeValues _priceRange = const RangeValues(0, 1000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B5320),
        foregroundColor: Colors.white,
        title: Text(
          'Find Buyers',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search products, sellers, or locations...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Quick Filters
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildQuickFilter('All', _selectedCategory == 'All'),
                _buildQuickFilter('Vegetables', _selectedCategory == 'Vegetables'),
                _buildQuickFilter('Fruits', _selectedCategory == 'Fruits'),
                _buildQuickFilter('Grains', _selectedCategory == 'Grains'),
                _buildQuickFilter('Organic', _organicOnly),
              ],
            ),
          ),

          // Listings Count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${_getFilteredListings().length} listings found',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    // Sort options
                    _showSortDialog();
                  },
                  icon: const Icon(Icons.sort),
                  label: const Text('Sort'),
                ),
              ],
            ),
          ),

          // Listings Grid
          Expanded(
            child: _buildListingsGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilter(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            if (label == 'All') {
              _selectedCategory = 'All';
            } else if (label == 'Organic') {
              _organicOnly = selected;
            } else {
              _selectedCategory = selected ? label : 'All';
            }
          });
        },
        selectedColor: const Color(0xFF2B5320),
        labelStyle: GoogleFonts.poppins(
          color: isSelected ? Colors.white : Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildListingsGrid() {
    final filteredListings = _getFilteredListings();
    
    if (filteredListings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No listings found',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search filters',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredListings.length,
      itemBuilder: (context, index) {
        final listing = filteredListings[index];
        return _buildListingCard(listing);
      },
    );
  }

  Widget _buildListingCard(EnhancedListing listing) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with seller info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF2B5320),
                  child: Text(
                    listing.sellerName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            listing.sellerName,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (listing.verified) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        listing.location,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  DateFormat('MMM dd').format(listing.postedDate),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          // Product info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        listing.product,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2B5320),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: listing.isOrganic ? Colors.green[100] : Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        listing.isOrganic ? 'Organic' : listing.grade,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: listing.isOrganic ? Colors.green[700] : Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  listing.description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.inventory, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${listing.quantity} ${listing.unit}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'KES ${listing.pricePerUnit}/${listing.unit}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2B5320),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      widget.onContactBuyer(listing.sellerId, listing.sellerName);
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('Chat'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2B5320),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showContactDialog(listing);
                    },
                    icon: const Icon(Icons.phone),
                    label: const Text('Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2B5320),
                      foregroundColor: Colors.white,
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

  List<EnhancedListing> _getFilteredListings() {
    return widget.listings.where((listing) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final searchLower = _searchQuery.toLowerCase();
        if (!listing.product.toLowerCase().contains(searchLower) &&
            !listing.sellerName.toLowerCase().contains(searchLower) &&
            !listing.location.toLowerCase().contains(searchLower)) {
          return false;
        }
      }

      // Category filter
      if (_selectedCategory != 'All' && listing.category != _selectedCategory) {
        return false;
      }

      // Organic filter
      if (_organicOnly && !listing.isOrganic) {
        return false;
      }

      // Price range filter
      if (listing.pricePerUnit < _priceRange.start || listing.pricePerUnit > _priceRange.end) {
        return false;
      }

      return true;
    }).toList();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Advanced Filters',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category filter
                  Text('Category', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: ['All', 'Vegetables', 'Fruits', 'Grains', 'Legumes']
                        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Price range
                  Text('Price Range (KES)', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 1000,
                    divisions: 20,
                    labels: RangeLabels(
                      _priceRange.start.round().toString(),
                      _priceRange.end.round().toString(),
                    ),
                    onChanged: (values) {
                      setDialogState(() {
                        _priceRange = values;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Organic only
                  CheckboxListTile(
                    title: const Text('Organic Only'),
                    value: _organicOnly,
                    onChanged: (value) {
                      setDialogState(() {
                        _organicOnly = value!;
                      });
                    },
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B5320),
              foregroundColor: Colors.white,
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sort By', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Price: Low to High'),
              onTap: () {
                Navigator.pop(context);
                // Sort by price ascending
              },
            ),
            ListTile(
              title: const Text('Price: High to Low'),
              onTap: () {
                Navigator.pop(context);
                // Sort by price descending
              },
            ),
            ListTile(
              title: const Text('Newest First'),
              onTap: () {
                Navigator.pop(context);
                // Sort by date descending
              },
            ),
            ListTile(
              title: const Text('Nearest Location'),
              onTap: () {
                Navigator.pop(context);
                // Sort by distance
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showContactDialog(EnhancedListing listing) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contact ${listing.sellerName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: Text(listing.phone),
              subtitle: const Text('Tap to call'),
              onTap: () {
                Navigator.pop(context);
                // Make phone call
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Color(0xFF2B5320)),
              title: const Text('Start Chat'),
              subtitle: const Text('Send a message'),
              onTap: () {
                Navigator.pop(context);
                widget.onContactBuyer(listing.sellerId, listing.sellerName);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
