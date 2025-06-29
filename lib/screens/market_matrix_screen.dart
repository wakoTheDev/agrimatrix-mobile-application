import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class MarketMatrixScreen extends StatefulWidget {
  const MarketMatrixScreen({super.key});

  @override
  State<MarketMatrixScreen> createState() => _MarketMatrixScreenState();
}
class Listing {
  final String seller;
  final String product;
  final String quantity;
  final String price;
  final String location;
  final double rating;
  final bool verified;

  Listing({
    required this.seller,
    required this.product,
    required this.quantity,
    required this.price,
    required this.location,
    required this.rating,
    required this.verified,
  });
}

class _MarketMatrixScreenState extends State<MarketMatrixScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCurrency = 'KES';
  String _selectedRegion = 'All';
  String _searchQuery = '';
  bool _isOnline = true;
  
  // Sample market data with timestamps
  final List<Map<String, dynamic>> _marketData = [
    {
      'cropName': 'Maize',
      'marketName': 'Nairobi Market',
      'price': 45,
      'grade': 'Grade 1',
      'icon': Icons.grass,
      'trend': 'up',
      'change': 5.2,
      'lastUpdated': '2 mins ago',
      'source': 'KALRO',
      'demandLevel': 'High',
    },
    {
      'cropName': 'Carrots',
      'marketName': 'Mombasa Market',  
      'price': 80,
      'grade': 'Premium',
      'icon': Icons.eco,
      'trend': 'down',
      'change': -3.1,
      'lastUpdated': '5 mins ago',
      'source': 'M-Farm',
      'demandLevel': 'Medium',
    },
    {
      'cropName': 'Tomatoes',
      'marketName': 'Kisumu Market',
      'price': 120,
      'grade': 'Grade 1',
      'icon': Icons.spa,
      'trend': 'up',
      'change': 8.7,
      'lastUpdated': '1 min ago',
      'source': 'MOA',
      'demandLevel': 'Very High',
    },
    {
      'cropName': 'Beans',
      'marketName': 'Migori Market',
      'price': 95,
      'grade': 'Organic',
      'icon': Icons.nature,
      'trend': 'stable',
      'change': 0.0,
      'lastUpdated': '3 mins ago',
      'source': 'Private Traders',
      'demandLevel': 'Medium',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getTrendColor(String trend) {
    switch (trend) {
      case 'up':
        return Colors.green;
      case 'down':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTrendIcon(String trend) {
    switch (trend) {
      case 'up':
        return Icons.trending_up;
      case 'down':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }

  Widget _buildLiveMarketDashboard() {
    return Column(
      children: [
        // Market Status Header
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isOnline ? Colors.green[50] : Colors.red[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isOnline ? Colors.green : Colors.red,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                _isOnline ? Icons.wifi : Icons.wifi_off,
                color: _isOnline ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                _isOnline ? 'Live Data' : 'Offline Mode',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: _isOnline ? Colors.green[700] : Colors.red[700],
                ),
              ),
              const Spacer(),
              // Currency Switcher
              DropdownButton<String>(
                value: _selectedCurrency,
                items: ['KES', 'USD'].map((currency) {
                  return DropdownMenuItem(
                    value: currency,
                    child: Text(currency),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCurrency = value!;
                  });
                },
              ),
            ],
          ),
        ),
        
        // Live Price Ticker
        Container(
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _marketData.length,
            itemBuilder: (context, index) {
              final item = _marketData[index];
              return Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2B5320),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['cropName'],
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '$_selectedCurrency ${item['price']}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _getTrendIcon(item['trend']),
                          color: _getTrendColor(item['trend']),
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Market Items List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _marketData.length,
            itemBuilder: (context, index) {
              final item = _marketData[index];
              return _buildEnhancedMarketItem(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedMarketItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2B5320).withOpacity(0.15),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(-6, 0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                // Crop Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B5320).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item['icon'],
                    color: const Color(0xFF2B5320),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Crop Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item['cropName'],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2B5320),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item['grade'],
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        item['marketName'],
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Price and Trend
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B5320),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_selectedCurrency ${item['price']}/kg',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _getTrendIcon(item['trend']),
                          color: _getTrendColor(item['trend']),
                          size: 16,
                        ),
                        Text(
                          '${item['change'] > 0 ? '+' : ''}${item['change']}%',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: _getTrendColor(item['trend']),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Additional Info Row
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.source, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        item['source'],
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.trending_up, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Demand: ${item['demandLevel']}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  item['lastUpdated'],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceAnalyzer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Trends & Analytics',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2B5320),
            ),
          ),
          const SizedBox(height: 16),
          
          // Time Period Selector
          Row(
            children: [
              _buildPeriodChip('7D', true),
              _buildPeriodChip('30D', false),
              _buildPeriodChip('90D', false),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Sample Chart Placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  Text(
                    'Price Trend Chart',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Integration with Chart Libraries Required',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Profit Estimator
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profit Estimator',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Buy Price',
                          hintText: 'Enter buy price',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Sell Price',
                          hintText: 'Enter sell price',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // Calculate profit logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Calculate Profit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String period, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(period),
        selected: isSelected,
        onSelected: (selected) {
          // Handle period selection
        },
        selectedColor: const Color(0xFF2B5320),
        labelStyle: GoogleFonts.poppins(
          color: isSelected ? Colors.white : Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildMarketFinder() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Advanced Search
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search crops, sellers, or markets...',
              hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
              suffixIcon: IconButton(
                icon: Icon(Icons.filter_list, color: Colors.grey[600]),
                onPressed: () {
                  _showFilterDialog();
                },
              ),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Quick Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All Regions', _selectedRegion == 'All'),
                _buildFilterChip('Nairobi', _selectedRegion == 'Nairobi'),
                _buildFilterChip('Mombasa', _selectedRegion == 'Mombasa'),
                _buildFilterChip('Kisumu', _selectedRegion == 'Kisumu'),
                _buildFilterChip('Organic Only', false),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Map View Toggle
          ElevatedButton.icon(
            onPressed: () {
              // Show map view
            },
            icon: const Icon(Icons.map),
            label: const Text('View on Map'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B5320),
              foregroundColor: Colors.white,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Filtered Results
          Expanded(
            child: ListView.builder(
              itemCount: _marketData.length,
              itemBuilder: (context, index) {
                final item = _marketData[index];
                // Apply search filter
                if (_searchQuery.isNotEmpty &&
                    !item['cropName'].toLowerCase().contains(_searchQuery.toLowerCase()) &&
                    !item['marketName'].toLowerCase().contains(_searchQuery.toLowerCase())) {
                  return Container();
                }
                return _buildEnhancedMarketItem(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (label.contains('Region') || ['Nairobi', 'Mombasa', 'Kisumu'].contains(label)) {
            setState(() {
              _selectedRegion = selected ? label : 'All';
            });
          }
        },
        selectedColor: const Color(0xFF2B5320),
        labelStyle: GoogleFonts.poppins(
          color: isSelected ? Colors.white : Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildAgriInsights() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Market Insights & Trends',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2B5320),
          ),
        ),
        const SizedBox(height: 16),

        // Daily Bulletin
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.newspaper, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Today\'s Market Bulletin',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Maize prices expected to rise due to seasonal demand. Weather forecast shows favorable conditions for tomato harvest.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Demand Forecast
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.trending_up, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Demand Forecast',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'High demand expected for tomatoes next week. Consider harvesting early for better prices.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Expert Tips
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Expert Tip',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Store your maize in dry conditions to maintain Grade 1 quality and get premium prices.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


  Widget _buildAgriConnect() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connect & Trade',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2B5320),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Quick Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Post Listing'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B5320),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.search),
                  label: const Text('Find Buyers'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Text(
            'Recent Listings',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2B5320),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Sample Listings
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                return _buildListingCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildListingCard(int index) {
    final List<Listing> listings = [
      Listing(
        seller: 'John Farmer',
        product: 'Premium Tomatoes',
        quantity: '500 kg',
        price: '120',
        location: 'Kisumu',
        rating: 4.8,
        verified: true,
      ),
      Listing(
        seller: 'Mary Agri Co.',
        product: 'Organic Maize',
        quantity: '1000 kg',
        price: '50',
        location: 'Nairobi',
        rating: 4.9,
        verified: true,
      ),
      Listing(
        seller: 'Farm Fresh Ltd',
        product: 'Grade 1 Carrots',
        quantity: '200 kg',
        price: '85',
        location: 'Mombasa',
        rating: 4.6,
        verified: false,
      ),
    ];

    
    final listing = listings[index];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF2B5320),
                child: Text(
                  listing.seller[0],
                  style: const TextStyle(color: Colors.white),
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
                          listing.seller,
                          style: GoogleFonts.poppins(
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
                    Row(
                      children: [
                        ...List.generate(5, (starIndex) {
                          return Icon(
                            starIndex < listing.rating.floor()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                        const SizedBox(width: 4),
                        Text(
                          '${listing.rating}',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
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
          
          const SizedBox(height: 12),
          
          Text(
            listing.product,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2B5320),
            ),
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              Expanded(
                child: Text(
                  'Quantity: ${listing.quantity}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Text(
                'KES ${listing.price}/kg',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2B5320),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
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
                  onPressed: () {},
                  icon: const Icon(Icons.call),
                  label: const Text('Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B5320),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Advanced Filters',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Region/County',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedRegion,
                  items: ['All', 'Nairobi', 'Mombasa', 'Kisumu', 'Migori']
                      .map((region) => DropdownMenuItem(
                            value: region,
                            child: Text(region),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRegion = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                Text(
                  'Price Range (KES)',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Min',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Max',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Text(
                  'Product Type',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Fresh'),
                      selected: false,
                      onSelected: (selected) {},
                    ),
                    FilterChip(
                      label: const Text('Dried'),
                      selected: false,
                      onSelected: (selected) {},
                    ),
                    FilterChip(
                      label: const Text('Processed'),
                      selected: false,
                      onSelected: (selected) {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Text(
                  'Certification',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Organic'),
                      selected: false,
                      onSelected: (selected) {},
                    ),
                    FilterChip(
                      label: const Text('Local'),
                      selected: false,
                      onSelected: (selected) {},
                    ),
                    FilterChip(
                      label: const Text('Non-GMO'),
                      selected: false,
                      onSelected: (selected) {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Apply filters
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B5320),
                foregroundColor: Colors.white,
              ),
              child: const Text('Apply Filters'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF2B5320),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AgriMatrix',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Smart Agricultural Market Platform',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Notification Bell
                      IconButton(
                        onPressed: () {
                          // Show notifications
                        },
                        icon: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                        ),
                      ),
                      // Settings
                      IconButton(
                        onPressed: () {
                          // Show settings
                        },
                        icon: const Icon(
                          Icons.settings,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Tab Bar
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: const [
                      Tab(text: 'Live Market'),
                      Tab(text: 'Price Analyzer'),
                      Tab(text: 'Market Finder'),
                      Tab(text: 'Insights'),
                      Tab(text: 'Connect'),
                    ],
                  ),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLiveMarketDashboard(),
                  _buildPriceAnalyzer(),
                  _buildMarketFinder(),
                  _buildAgriInsights(),
                  _buildAgriConnect(),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // Floating Action Button for Quick Actions
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showQuickActionsDialog();
        },
        backgroundColor: const Color(0xFF2B5320),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showQuickActionsDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Quick Actions',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2B5320),
                ),
              ),
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      'Set Price Alert',
                      Icons.notifications_active,
                      Colors.orange,
                      () {
                        Navigator.pop(context);
                        _showPriceAlertDialog();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickActionCard(
                      'Post Product',
                      Icons.add_circle,
                      Colors.green,
                      () {
                        Navigator.pop(context);
                        // Navigate to post product screen
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      'Find Buyers',
                      Icons.people,
                      Colors.blue,
                      () {
                        Navigator.pop(context);
                        // Navigate to buyer finder
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickActionCard(
                      'Weather Info',
                      Icons.wb_sunny,
                      Colors.purple,
                      () {
                        Navigator.pop(context);
                        // Show weather information
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showPriceAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Set Price Alert',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Commodity',
                  border: OutlineInputBorder(),
                ),
                items: ['Maize', 'Tomatoes', 'Carrots', 'Beans']
                    .map((commodity) => DropdownMenuItem(
                          value: commodity,
                          child: Text(commodity),
                        ))
                    .toList(),
                onChanged: (value) {},
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Target Price (KES)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Alert Type',
                  border: OutlineInputBorder(),
                ),
                items: ['Price Above', 'Price Below', 'Price Change']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {},
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Set up price alert
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Price alert set successfully!'),
                    backgroundColor: Color(0xFF2B5320),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B5320),
                foregroundColor: Colors.white,
              ),
              child: const Text('Set Alert'),
            ),
          ],
        );
      },
    );
  }
}