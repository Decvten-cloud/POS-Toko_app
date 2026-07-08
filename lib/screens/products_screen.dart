import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/product_provider.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  final ImagePicker _picker = ImagePicker();
  String? _qrisImagePath;
  final List<String> _productCategories = [
    'Makanan',
    'Minuman',
    'Snack',
    'Jajanan',
    'Roti',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _loadQrisImage();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _rupiah(int value) {
    final formatted = value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return 'Rp $formatted';
  }

  Future<void> _showProductForm(
    BuildContext context,
    ProductProvider provider, [
    Product? product,
  ]) async {
    final nameController = TextEditingController(text: product?.name ?? '');
    final sellingController = TextEditingController(
      text: product?.sellingPrice.toString() ?? '',
    );
    final costController = TextEditingController(
      text: product?.costPrice.toString() ?? '',
    );
    final stockController = TextEditingController(
      text: product?.stock.toString() ?? '',
    );
    final unitController = TextEditingController(text: product?.unit ?? '');
    final unitOptions = ['pcs', 'botol', 'strip', 'kg', 'liter', 'Lainnya'];
    String selectedUnit = unitOptions.contains(product?.unit)
        ? product?.unit ?? 'pcs'
        : 'Lainnya';
    String? selectedImagePath = product?.imagePath;
    String selectedCategory = _productCategories.contains(product?.category)
        ? product?.category ?? 'Lainnya'
        : 'Lainnya';

    await showDialog<void>(
      context: context,
      builder: (context) {
        final navigator = Navigator.of(context);
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(product == null ? 'Tambah Produk' : 'Edit Produk'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if ((selectedImagePath ?? '').isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(selectedImagePath!),
                          width: 160,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 160,
                              height: 160,
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                                size: 50,
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.image,
                          color: Colors.grey,
                          size: 50,
                        ),
                      ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final imagePath = await _pickProductImage();
                        if (imagePath != null) {
                          setState(() {
                            selectedImagePath = imagePath;
                          });
                        }
                      },
                      icon: const Icon(Icons.upload_file),
                      label: Text(
                        selectedImagePath != null
                            ? 'Ubah Gambar Produk'
                            : 'Upload Gambar Produk',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: _productCategories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Kategori'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama produk',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: sellingController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Harga Jual',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: costController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Harga Pokok',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Stok'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedUnit,
                      items: unitOptions
                          .map(
                            (unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          selectedUnit = value;
                          if (value != 'Lainnya') {
                            unitController.text = value;
                          } else if (product == null) {
                            unitController.text = '';
                          }
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Unit'),
                    ),
                    if (selectedUnit == 'Lainnya') ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: unitController,
                        decoration: const InputDecoration(
                          labelText: 'Masukkan unit lain',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final name = nameController.text.trim();
                    final selling = int.tryParse(sellingController.text) ?? 0;
                    final cost = int.tryParse(costController.text) ?? 0;
                    final stock = int.tryParse(stockController.text) ?? 0;
                    final unit = selectedUnit == 'Lainnya'
                        ? unitController.text.trim()
                        : selectedUnit;
                    if (name.isEmpty || unit.isEmpty || selling <= 0) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Nama, satuan, dan harga wajib'),
                        ),
                      );
                      return;
                    }
                    final newProduct = Product(
                      id: product?.id,
                      name: name,
                      sellingPrice: selling,
                      costPrice: cost,
                      stock: stock,
                      unit: unit,
                      category: selectedCategory,
                      imagePath: selectedImagePath,
                    );
                    if (product == null) {
                      await provider.addProduct(newProduct);
                    } else {
                      await provider.updateProduct(newProduct);
                    }
                    navigator.pop();
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<String?> _pickProductImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (pickedFile == null) return null;

    final appDir = await getApplicationDocumentsDirectory();
    final extension = path.extension(pickedFile.path);
    final fileName =
        'product_${DateTime.now().millisecondsSinceEpoch}$extension';
    final savedFile = await File(
      pickedFile.path,
    ).copy(path.join(appDir.path, fileName));
    return savedFile.path;
  }

  Future<void> _loadQrisImage() async {
    final appDir = await getApplicationDocumentsDirectory();
    final qrisFile = File(path.join(appDir.path, 'qris_qr_code.png'));
    if (await qrisFile.exists()) {
      setState(() {
        _qrisImagePath = qrisFile.path;
      });
    }
  }

  Future<void> _showQrisSettingDialog() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (pickedFile == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final savedImage = await File(
      pickedFile.path,
    ).copy(path.join(appDir.path, 'qris_qr_code.png'));
    setState(() {
      _qrisImagePath = savedImage.path;
    });
  }

  Future<void> _showRestockDialog(
    BuildContext context,
    ProductProvider provider,
    Product product,
  ) async {
    final restockController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) {
        final navigator = Navigator.of(context);
        return AlertDialog(
          title: Text('Restock ${product.name}'),
          content: TextField(
            controller: restockController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Jumlah restock'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final amount = int.tryParse(restockController.text) ?? 0;
                if (amount <= 0) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Masukkan jumlah valid')),
                  );
                  return;
                }
                await provider.restockProduct(product.id!, amount);
                navigator.pop();
              },
              child: const Text('Restock'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final products = provider.search(_searchText);

    return Padding(
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
              hintText: 'Cari produk',
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: _showQrisSettingDialog,
            icon: const Icon(Icons.qr_code),
            label: const Text('QRIS Setting'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _showProductForm(context, provider),
            icon: const Icon(Icons.add),
            label: const Text('Tambah Produk Baru'),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : products.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada produk. Tambahkan produk baru.',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.separated(
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          title: Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Sell: ${_rupiah(product.sellingPrice)} · Cost: ${_rupiah(product.costPrice)}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${product.stock} ${product.unit}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _showProductForm(
                                      context,
                                      provider,
                                      product,
                                    ),
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text('Edit'),
                                  ),
                                  const SizedBox(width: 6),
                                  TextButton.icon(
                                    onPressed: () => _showRestockDialog(
                                      context,
                                      provider,
                                      product,
                                    ),
                                    icon: const Icon(Icons.refresh, size: 18),
                                    label: const Text('Restock'),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () async {
                                      await provider.deleteProduct(product.id!);
                                    },
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
