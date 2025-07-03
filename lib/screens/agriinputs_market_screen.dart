import 'package:flutter/material.dart';

// Main Screen
class AgriInputsMarketScreen extends StatefulWidget {
  const AgriInputsMarketScreen({super.key});

  @override
  _AgriInputsMarketScreenState createState() => _AgriInputsMarketScreenState();
}

class _AgriInputsMarketScreenState extends State<AgriInputsMarketScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedPriceRange = 'All';
  String _selectedDeliveryOption = 'All';
  List<Product> _filteredProducts = [];
  final List<Product> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _filteredProducts = sampleProducts;
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = sampleProducts.where((product) {
        bool matchesSearch = product.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                           product.category.toLowerCase().contains(_searchController.text.toLowerCase());
        bool matchesCategory = _selectedCategory == 'All' || product.category == _selectedCategory;
        bool matchesPrice = _selectedPriceRange == 'All' || _isPriceInRange(product.price, _selectedPriceRange);
        bool matchesDelivery = _selectedDeliveryOption == 'All' || product.deliveryOptions.contains(_selectedDeliveryOption);
        
        return matchesSearch && matchesCategory && matchesPrice && matchesDelivery;
      }).toList();
    });
  }

  bool _isPriceInRange(double price, String range) {
    switch (range) {
      case 'Under KES 1,000':
        return price < 1000;
      case 'KES 1,000 - 5,000':
        return price >= 1000 && price <= 5000;
      case 'Above KES 5,000':
        return price > 5000;
      default:
        return true;
    }
  }

  void _addToCart(Product product) {
    setState(() {
      _cartItems.add(product);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} added to cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriInputs Market'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (_cartItems.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${_cartItems.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(cartItems: _cartItems),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products, brands, suppliers...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) => _filterProducts(),
            ),
          ),
          
          // Filters
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterDropdown(
                    'Category',
                    _selectedCategory,
                    ['All', 'Seeds', 'Fertilizers', 'Pesticides', 'Equipment', 'Vet Products'],
                    (value) {
                      setState(() {
                        _selectedCategory = value!;
                        _filterProducts();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterDropdown(
                    'Price',
                    _selectedPriceRange,
                    ['All', 'Under KES 1,000', 'KES 1,000 - 5,000', 'Above KES 5,000'],
                    (value) {
                      setState(() {
                        _selectedPriceRange = value!;
                        _filterProducts();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterDropdown(
                    'Delivery',
                    _selectedDeliveryOption,
                    ['All', 'Pickup', 'Delivery', 'Both'],
                    (value) {
                      setState(() {
                        _selectedDeliveryOption = value!;
                        _filterProducts();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Quick Actions
          Container(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildQuickActionCard('Promotions', Icons.local_offer, Colors.orange),
                _buildQuickActionCard('Bulk Orders', Icons.inventory, Colors.blue),
                _buildQuickActionCard('Get Quote', Icons.request_quote, Colors.purple),
                _buildQuickActionCard('Suppliers', Icons.store, Colors.green),
              ],
            ),
          ),
          
          // Products Grid
          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No products found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      return ProductCard(
                        product: _filteredProducts[index],
                        onAddToCart: () => _addToCart(_filteredProducts[index]),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(product: _filteredProducts[index]),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 12)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        child: InkWell(
          onTap: () {
            // Handle quick action tap
            switch (title) {
              case 'Promotions':
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PromotionsScreen()));
                break;
              case 'Bulk Orders':
                Navigator.push(context, MaterialPageRoute(builder: (context) => const BulkOrderScreen()));
                break;
              case 'Get Quote':
                Navigator.push(context, MaterialPageRoute(builder: (context) => const QuoteRequestScreen()));
                break;
              case 'Suppliers':
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SuppliersScreen()));
                break;
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

// Product Card Widget
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onAddToCart, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
                child: product.imageUrl != null
                    ? Image.network(product.imageUrl!, fit: BoxFit.cover)
                    : const Icon(Icons.image, size: 48, color: Colors.grey),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'KES ${product.price.toStringAsFixed(0)}',
                      style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        Text('${product.rating}', style: TextStyle(fontSize: 10)),
                        const Spacer(),
                        Text(
                          product.inStock ? 'In Stock' : 'Out of Stock',
                          style: TextStyle(
                            fontSize: 9,
                            color: product.inStock ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: SizedBox(
                width: double.infinity,
                height: 28,
                child: ElevatedButton(
                  onPressed: product.inStock ? onAddToCart : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('Add to Cart', style: TextStyle(fontSize: 10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Product Detail Screen
class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey[200]),
              child: widget.product.imageUrl != null
                  ? Image.network(widget.product.imageUrl!, fit: BoxFit.cover)
                  : const Icon(Icons.image, size: 100, color: Colors.grey),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and Price
                  Text(
                    widget.product.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'KES ${widget.product.price.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 28, color: Colors.green[700], fontWeight: FontWeight.bold),
                  ),
                  
                  // Rating and Stock Status
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < widget.product.rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      Text('${widget.product.rating}/5'),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.product.inStock ? Colors.green[100] : Colors.red[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.product.inStock ? 'In Stock' : 'Out of Stock',
                          style: TextStyle(
                            color: widget.product.inStock ? Colors.green[700] : Colors.red[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Supplier Info
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Supplier Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.store, color: Colors.green[700]),
                              const SizedBox(width: 8),
                              Text(widget.product.supplier),
                              const Spacer(),
                              if (widget.product.isVerified)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.verified, color: Colors.blue, size: 16),
                                      SizedBox(width: 4),
                                      Text('Verified', style: TextStyle(color: Colors.blue, fontSize: 12)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                              const SizedBox(width: 8),
                              Text(widget.product.location, style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Description
                  const SizedBox(height: 20),
                  const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.product.description),
                  
                  // Delivery Options
                  const SizedBox(height: 20),
                  const Text('Delivery Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: widget.product.deliveryOptions.map((option) {
                      return Chip(
                        label: Text(option),
                        backgroundColor: Colors.green[100],
                        labelStyle: TextStyle(color: Colors.green[700]),
                      );
                    }).toList(),
                  ),
                  
                  // Quantity Selector
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text('Quantity:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                              icon: const Icon(Icons.remove),
                            ),
                            Text('$_quantity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            IconButton(
                              onPressed: () => setState(() => _quantity++),
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // Reviews Section
                  const SizedBox(height: 20),
                  const Text('Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...widget.product.reviews.map((review) => ReviewCard(review: review)).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: widget.product.inStock ? () {
                  // Add to cart logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${widget.product.name} added to cart')),
                  );
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Add to Cart'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: widget.product.inStock ? () {
                  // Buy now logic
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutScreen(
                        items: [CartItem(product: widget.product, quantity: _quantity)],
                      ),
                    ),
                  );
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Buy Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Cart Screen
class CartScreen extends StatefulWidget {
  final List<Product> cartItems;

  const CartScreen({super.key, required this.cartItems});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _cartItems = [];

  @override
  void initState() {
    super.initState();
    // Convert products to cart items with quantities
    Map<String, int> productCounts = {};
    for (var product in widget.cartItems) {
      productCounts[product.id] = (productCounts[product.id] ?? 0) + 1;
    }
    
    _cartItems = productCounts.entries.map((entry) {
      var product = widget.cartItems.firstWhere((p) => p.id == entry.key);
      return CartItem(product: product, quantity: entry.value);
    }).toList();
  }

  double get _totalAmount {
    return _cartItems.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: _cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Your cart is empty', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Continue Shopping'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      return CartItemCard(
                        cartItem: _cartItems[index],
                        onQuantityChanged: (newQuantity) {
                          setState(() {
                            if (newQuantity > 0) {
                              _cartItems[index].quantity = newQuantity;
                            } else {
                              _cartItems.removeAt(index);
                            }
                          });
                        },
                        onRemove: () {
                          setState(() {
                            _cartItems.removeAt(index);
                          });
                        },
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(
                            'KES ${_totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[700]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _cartItems.isNotEmpty ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CheckoutScreen(items: _cartItems),
                              ),
                            );
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Proceed to Checkout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// Supporting Screens (Simplified implementations)
class PromotionsScreen extends StatelessWidget {
  const PromotionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promotions & Discounts'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          PromotionCard(
            title: '20% Off All Seeds',
            description: 'Get 20% discount on all seed varieties',
            validUntil: 'Valid until Dec 31, 2024',
            discount: '20%',
          ),
          PromotionCard(
            title: 'Bulk Fertilizer Deal',
            description: 'Buy 10 bags, get 2 free',
            validUntil: 'Limited time offer',
            discount: 'Buy 10 Get 2',
          ),
          PromotionCard(
            title: 'Free Delivery',
            description: 'Free delivery on orders above KES 5,000',
            validUntil: 'Ongoing',
            discount: 'Free Delivery',
          ),
        ],
      ),
    );
  }
}

class BulkOrderScreen extends StatelessWidget {
  const BulkOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Orders'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Request Bulk Order',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Quantity Required',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Additional Requirements',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bulk order request submitted')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Submit Request'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuoteRequestScreen extends StatelessWidget {
  const QuoteRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Quote'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Get Custom Quote',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Organization/Farm Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Contact Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Products & Quantities Needed',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Quote request submitted')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Request Quote'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verified Suppliers'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: sampleSuppliers.map((supplier) => SupplierCard(supplier: supplier)).toList(),
      ),
    );
  }
}

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> items;

  const CheckoutScreen({super.key, required this.items});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'M-PESA';
  String _selectedDeliveryMethod = 'Delivery';
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  double get _subtotal {
    return widget.items.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  double get _deliveryFee {
    return _selectedDeliveryMethod == 'Delivery' ? 200.0 : 0.0;
  }

  double get _total {
    return _subtotal + _deliveryFee;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            const Text('Order Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ...widget.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(child: Text(item.product.name)),
                          Text('${item.quantity}x'),
                          const SizedBox(width: 16),
                          Text('KES ${(item.product.price * item.quantity).toStringAsFixed(2)}'),
                        ],
                      ),
                    )),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal:'),
                        Text('KES ${_subtotal.toStringAsFixed(2)}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Delivery:'),
                        Text('KES ${_deliveryFee.toStringAsFixed(2)}'),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('KES ${_total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Delivery Information
            const Text('Delivery Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Pickup'),
                            value: 'Pickup',
                            groupValue: _selectedDeliveryMethod,
                            onChanged: (value) {
                              setState(() {
                                _selectedDeliveryMethod = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Delivery'),
                            value: 'Delivery',
                            groupValue: _selectedDeliveryMethod,
                            onChanged: (value) {
                              setState(() {
                                _selectedDeliveryMethod = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    if (_selectedDeliveryMethod == 'Delivery') ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Delivery Address',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Payment Method
            const Text('Payment Method', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Row(
                        children: [
                          Icon(Icons.phone_android, color: Colors.green),
                          SizedBox(width: 8),
                          Text('M-PESA'),
                        ],
                      ),
                      value: 'M-PESA',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Row(
                        children: [
                          Icon(Icons.phone_android, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Airtel Money'),
                        ],
                      ),
                      value: 'Airtel Money',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Row(
                        children: [
                          Icon(Icons.credit_card, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Card Payment'),
                        ],
                      ),
                      value: 'Card',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            // Process payment
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Order Confirmed'),
                content: const Text('Your order has been placed successfully. You will receive updates via SMS.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text('Place Order - KES ${_total.toStringAsFixed(2)}'),
        ),
      ),
    );
  }
}

// Supporting Widget Classes
class CartItemCard extends StatelessWidget {
  final CartItem cartItem;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: cartItem.product.imageUrl != null
                  ? Image.network(cartItem.product.imageUrl!, fit: BoxFit.cover)
                  : const Icon(Icons.image, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'KES ${cartItem.product.price.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.green[700]),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => onQuantityChanged(cartItem.quantity - 1),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('${cartItem.quantity}'),
                    IconButton(
                      onPressed: () => onQuantityChanged(cartItem.quantity + 1),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: onRemove,
                  child: const Text('Remove', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(review.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(review.comment),
            const SizedBox(height: 4),
            Text(
              review.date,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class PromotionCard extends StatelessWidget {
  final String title;
  final String description;
  final String validUntil;
  final String discount;

  const PromotionCard({
    super.key,
    required this.title,
    required this.description,
    required this.validUntil,
    required this.discount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  discount,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description),
                  const SizedBox(height: 4),
                  Text(
                    validUntil,
                    style:  TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}

class SupplierCard extends StatelessWidget {
  final Supplier supplier;

  const SupplierCard({super.key, required this.supplier});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green[100],
                  child: Icon(Icons.store, color: Colors.green[700]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            supplier.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          if (supplier.isVerified) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.verified, color: Colors.blue, size: 20),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(supplier.location, style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text('${supplier.rating}'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${supplier.productCount} products'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Specializes in: ${supplier.specialization}'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // View supplier products
                    },
                    child: const Text('View Products'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Contact supplier
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                    child: const Text('Contact'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Data Models
class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String supplier;
  final String location;
  final bool isVerified;
  final double rating;
  final bool inStock;
  final String description;
  final List<String> deliveryOptions;
  final String? imageUrl;
  final List<Review> reviews;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.supplier,
    required this.location,
    required this.isVerified,
    required this.rating,
    required this.inStock,
    required this.description,
    required this.deliveryOptions,
    this.imageUrl,
    required this.reviews,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});
}

class Review {
  final String customerName;
  final int rating;
  final String comment;
  final String date;

  Review({
    required this.customerName,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

class Supplier {
  final String id;
  final String name;
  final String location;
  final bool isVerified;
  final double rating;
  final int productCount;
  final String specialization;
  final String contact;

  Supplier({
    required this.id,
    required this.name,
    required this.location,
    required this.isVerified,
    required this.rating,
    required this.productCount,
    required this.specialization,
    required this.contact,
  });
}

// Sample Data
final List<Product> sampleProducts = [
  Product(
    id: '1',
    name: 'Hybrid Maize Seeds (10kg)',
    category: 'Seeds',
    price: 2500.0,
    supplier: 'Kenya Seed Company',
    location: 'Kitale',
    isVerified: true,
    rating: 4.5,
    inStock: true,
    description: 'High-yielding hybrid maize seeds suitable for various climatic conditions. Expected yield: 25-30 bags per acre.',
    deliveryOptions: ['Pickup', 'Delivery'],
    reviews: [
      Review(customerName: 'John Mwangi', rating: 5, comment: 'Excellent germination rate and high yield', date: '2024-01-15'),
      Review(customerName: 'Mary Wanjiku', rating: 4, comment: 'Good quality seeds, delivered on time', date: '2024-01-10'),
    ],
  ),
  Product(
    id: '2',
    name: 'NPK Fertilizer (50kg)',
    category: 'Fertilizers',
    price: 4200.0,
    supplier: 'Yara East Africa',
    location: 'Nakuru',
    isVerified: true,
    rating: 4.3,
    inStock: true,
    description: 'Complete NPK fertilizer for optimal crop nutrition. Suitable for cereals and vegetables.',
    deliveryOptions: ['Delivery'],
    reviews: [
      Review(customerName: 'Peter Kiprotich', rating: 4, comment: 'Good results on my maize farm', date: '2024-01-12'),
    ],
  ),
  Product(
    id: '3',
    name: 'Knapsack Sprayer (20L)',
    category: 'Equipment',
    price: 3500.0,
    supplier: 'Agrotech Supplies',
    location: 'Eldoret',
    isVerified: false,
    rating: 4.0,
    inStock: true,
    description: 'Durable knapsack sprayer for pesticide and herbicide application. Includes adjustable nozzles.',
    deliveryOptions: ['Pickup', 'Delivery'],
    reviews: [
      Review(customerName: 'Grace Nyong\'o', rating: 4, comment: 'Works well for my small farm', date: '2024-01-08'),
    ],
  ),
  Product(
    id: '4',
    name: 'Cabbage Seeds (100g)',
    category: 'Seeds',
    price: 450.0,
    supplier: 'Fresh Produce Seeds Ltd',
    location: 'Naivasha',
    isVerified: true,
    rating: 4.7,
    inStock: false,
    description: 'Premium cabbage seeds with high germination rate. Suitable for highland areas.',
    deliveryOptions: ['Pickup'],
    reviews: [
      Review(customerName: 'Samuel Kiprop', rating: 5, comment: 'Best cabbage seeds I\'ve used', date: '2024-01-05'),
    ],
  ),
  Product(
    id: '5',
    name: 'Roundup Herbicide (1L)',
    category: 'Pesticides',
    price: 1200.0,
    supplier: 'Crop Care Kenya',
    location: 'Meru',
    isVerified: true,
    rating: 4.2,
    inStock: true,
    description: 'Effective systemic herbicide for weed control. Non-selective post-emergence herbicide.',
    deliveryOptions: ['Delivery'],
    reviews: [
      Review(customerName: 'Ann Wambui', rating: 4, comment: 'Effective weed control', date: '2024-01-03'),
    ],
  ),
];

final List<Supplier> sampleSuppliers = [
  Supplier(
    id: '1',
    name: 'Kenya Seed Company',
    location: 'Kitale',
    isVerified: true,
    rating: 4.8,
    productCount: 45,
    specialization: 'Seeds & Planting Materials',
    contact: '+254 712 345 678',
  ),
  Supplier(
    id: '2',
    name: 'Yara East Africa',
    location: 'Nakuru',
    isVerified: true,
    rating: 4.6,
    productCount: 32,
    specialization: 'Fertilizers & Nutrition',
    contact: '+254 723 456 789',
  ),
  Supplier(
    id: '3',
    name: 'Agrotech Supplies',
    location: 'Eldoret',
    isVerified: false,
    rating: 4.2,
    productCount: 28,
    specialization: 'Farm Equipment & Tools',
    contact: '+254 734 567 890',
  ),
  Supplier(
    id: '4',
    name: 'Crop Care Kenya',
    location: 'Meru',
    isVerified: true,
    rating: 4.4,
    productCount: 56,
    specialization: 'Pesticides & Crop Protection',
    contact: '+254 745 678 901',
  ),
];