import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';

class CashierScreen extends StatefulWidget {
  const CashierScreen({super.key});

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  String _selectedCategory = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Makanan',
    'Minuman',
    'Snack',
    'Jajanan',
    'Roti',
  ];

  String _rupiah(int value) {
    final formatted = value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return 'Rp $formatted';
  }

  List<Product> _filterByCategory(List<Product> products) {
    if (_selectedCategory == 'Semua') {
      return products;
    }
    return products
        .where(
          (p) => p.category.toLowerCase() == _selectedCategory.toLowerCase(),
        )
        .toList();
  }

  void _showPaymentMethodDialog(
    CartProvider cartProvider,
    ProductProvider productProvider,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Metode Pembayaran'),
        content: const Text(
          'Pilih metode pembayaran untuk melanjutkan transaksi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await _processCheckout(cartProvider, productProvider, 'Tunai');
            },
            icon: const Icon(Icons.attach_money),
            label: const Text('Tunai'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showQrisDialog();
            },
            icon: const Icon(Icons.qr_code),
            label: const Text('QRIS'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showQrisDialog() {
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<File?>(
        future: _loadQrisImage(),
        builder: (context, snapshot) {
          return AlertDialog(
            title: const Text('Pembayaran QRIS'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: snapshot.hasData && snapshot.data != null
                      ? Image.file(
                          snapshot.data!,
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                        )
                      : _buildQrsPlaceholder(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Scan QR code di atas dengan aplikasi pembayaran Anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _processCheckout(
                    context.read<CartProvider>(),
                    context.read<ProductProvider>(),
                    'QRIS',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Konfirmasi'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<File?> _loadQrisImage() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final qrisFile = File('${appDir.path}/qris_qr_code.png');
      if (await qrisFile.exists()) {
        return qrisFile;
      }
    } catch (e) {
      print('Error loading QRIS image: $e');
    }
    return null;
  }

  Widget _buildQrsPlaceholder() {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code, size: 80, color: Colors.grey.shade600),
          const SizedBox(height: 16),
          Text(
            'QR Code tidak ditemukan',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload di Pengaturan',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Future<void> _processCheckout(
    CartProvider cartProvider,
    ProductProvider productProvider,
    String paymentMethod,
  ) async {
    final hasNullId = cartProvider.items.any((i) => i.product.id == null);

    if (hasNullId) {
      await _showResultDialog(
        'Checkout Gagal',
        'Beberapa produk belum disimpan ke database.',
      );
      return;
    }

    final success = await cartProvider.checkout(productProvider);
    if (success) {
      await _showResultDialog(
        'Checkout Berhasil',
        'Pembayaran $paymentMethod berhasil.',
      );
    } else {
      await _showResultDialog(
        'Checkout Gagal',
        'Stok tidak cukup atau keranjang kosong.',
      );
    }
  }

  Future<void> _showResultDialog(String title, String message) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final cartProvider = context.watch<CartProvider>();
    var products = productProvider.search(_searchText);
    products = _filterByCategory(products);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Cari barang untuk kasir',
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchText.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchText = '';
                            });
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category;
                    return FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      backgroundColor: Colors.grey.shade200,
                      selectedColor: Colors.teal.shade700,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Produk',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: productProvider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : products.isEmpty
                          ? const Center(
                              child: Text(
                                'Produk tidak ditemukan.',
                                style: TextStyle(fontSize: 18),
                              ),
                            )
                          : ListView.separated(
                              itemCount: products.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final product = products[index];
                                return Material(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(14),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: product.stock > 0
                                        ? () {
                                            cartProvider.addProduct(product);
                                          }
                                        : null,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 70,
                                            height: 70,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child:
                                                product.imagePath != null &&
                                                    product
                                                        .imagePath!
                                                        .isNotEmpty
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    child: Image.file(
                                                      File(product.imagePath!),
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) {
                                                            return Icon(
                                                              Icons.image,
                                                              color: Colors
                                                                  .grey
                                                                  .shade400,
                                                            );
                                                          },
                                                    ),
                                                  )
                                                : Icon(
                                                    Icons.image,
                                                    color: Colors.grey.shade400,
                                                  ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product.name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  '${_rupiah(product.sellingPrice)} • ${product.stock} ${product.unit}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          ElevatedButton(
                                            onPressed: product.stock > 0
                                                ? () {
                                                    cartProvider.addProduct(
                                                      product,
                                                    );
                                                  }
                                                : null,
                                            style: ElevatedButton.styleFrom(
                                              minimumSize: const Size(44, 44),
                                              padding: EdgeInsets.zero,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.add,
                                              size: 22,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 16),
                    if (!cartProvider.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.shopping_cart,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Keranjang',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 140),
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: cartProvider.items.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 6),
                                itemBuilder: (context, index) {
                                  final item = cartProvider.items[index];
                                  return Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${item.product.name} x${item.quantity}',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _rupiah(
                                                  item.product.sellingPrice *
                                                      item.quantity,
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.remove,
                                                  size: 14,
                                                ),
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                                onPressed:
                                                    item.product.id == null
                                                    ? null
                                                    : () {
                                                        cartProvider
                                                            .decreaseQuantity(
                                                              item.product.id!,
                                                            );
                                                      },
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                  ),
                                              child: Text(
                                                '${item.quantity}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.add,
                                                  size: 14,
                                                ),
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                                onPressed:
                                                    item.product.id == null
                                                    ? null
                                                    : () {
                                                        cartProvider
                                                            .increaseQuantity(
                                                              item.product.id!,
                                                            );
                                                      },
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            ElevatedButton.icon(
                                              onPressed: item.product.id == null
                                                  ? null
                                                  : () {
                                                      cartProvider.removeItem(
                                                        item.product.id!,
                                                      );
                                                    },
                                              icon: const Icon(
                                                Icons.delete,
                                                size: 18,
                                              ),
                                              label: const Text(
                                                'Hapus',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.red.shade600,
                                                foregroundColor: Colors.white,
                                                minimumSize: const Size(72, 34),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.teal.shade800,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          _rupiah(cartProvider.total),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: cartProvider.isEmpty
                          ? null
                          : () {
                              _showPaymentMethodDialog(
                                cartProvider,
                                productProvider,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'BAYAR SEKARANG',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
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
    );
  }
}
