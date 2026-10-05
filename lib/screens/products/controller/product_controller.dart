import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modal/AddProductModal.dart' as add_product_modal;
import '../modal/AllBrandModal.dart' as brand_modal;
import '../modal/AllCateGoryModal.dart' as category_modal;
import '../modal/AllproductViewLIstModal.dart' as product_modal;
import '../modal/AllunitsModal.dart' as unit_modal;
import '../modal/DeleateproductModal.dart' as delete_modal;
import '../service/product_service.dart';

class ProductController extends GetxController {
  final ProductService _service = ProductService();

  // Observables for Lists
  final RxList<product_modal.Data> productsList = <product_modal.Data>[].obs;
  final RxList<brand_modal.Data> brandsList = <brand_modal.Data>[].obs;
  final RxList<category_modal.Data> categoriesList = <category_modal.Data>[].obs;
  final RxList<unit_modal.Data> unitsList = <unit_modal.Data>[].obs;

  // Loading States
  final RxBool isLoadingProducts = false.obs;
  final RxBool isLoadingDropdowns = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isDeleting = false.obs;

  // Search & Filters
  final RxString searchQuery = ''.obs;
  final RxString selectedCategoryFilter = 'All Categories'.obs;
  final RxString selectedBrandFilter = 'All Brands'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  /// Fetch products and all dropdowns
  Future<void> fetchAllData() async {
    await Future.wait([
      fetchProducts(),
      fetchDropdowns(),
    ]);
  }

  /// Fetch All Products
  Future<void> fetchProducts() async {
    isLoadingProducts.value = true;
    try {
      final res = await _service.getAllProducts();
      if (res.data != null) {
        productsList.assignAll(res.data!);
      }
    } catch (e) {
      debugPrint('Error loading products: $e');
    } finally {
      isLoadingProducts.value = false;
    }
  }

  /// Fetch Brands, Categories, and Units for Dropdowns
  Future<void> fetchDropdowns() async {
    isLoadingDropdowns.value = true;
    try {
      final results = await Future.wait([
        _service.getAllBrands(),
        _service.getAllCategories(),
        _service.getAllUnits(),
      ]);

      final brandRes = results[0] as brand_modal.AllBrandModal;
      final cateRes = results[1] as category_modal.AllCateGoryModal;
      final unitRes = results[2] as unit_modal.AllunitsModal;

      if (brandRes.data != null) brandsList.assignAll(brandRes.data!);
      if (cateRes.data != null) categoriesList.assignAll(cateRes.data!);
      if (unitRes.data != null) unitsList.assignAll(unitRes.data!);
    } catch (e) {
      debugPrint('Error loading dropdowns: $e');
    } finally {
      isLoadingDropdowns.value = false;
    }
  }

  /// Filtered Products List for UI
  List<product_modal.Data> get filteredProducts {
    return productsList.where((product) {
      final query = searchQuery.value.toLowerCase().trim();
      final nameMatches = (product.name ?? '').toLowerCase().contains(query) ||
          (product.sKU ?? '').toLowerCase().contains(query);

      final categoryMatches = selectedCategoryFilter.value == 'All Categories' ||
          (product.category?.name ?? '').toLowerCase() == selectedCategoryFilter.value.toLowerCase();

      final brandMatches = selectedBrandFilter.value == 'All Brands' ||
          (product.brand?.name ?? '').toLowerCase() == selectedBrandFilter.value.toLowerCase();

      return nameMatches && categoryMatches && brandMatches;
    }).toList();
  }

  /// Create Product API
  Future<bool> createProduct({
    required String name,
    required int categoryId,
    required int brandId,
    required int unitId,
    required double price,
    required double mrp,
    required double purchasePrice,
    required int quantity,
    required String sku,
    String itemType = 'normal',
    String status = 'active',
    String availability = 'in_stock',
    String gstOption = 'without_gst',
    int branchId = 1,
  }) async {
    isSubmitting.value = true;
    try {
      final payload = {
        "name": name,
        "category_id": categoryId,
        "brand_id": brandId,
        "unit_id": unitId,
        "price": price,
        "mrp": mrp,
        "purchase_price": purchasePrice,
        "quantity": quantity,
        "SKU": sku,
        "item_type": itemType,
        "status": status,
        "availablility": availability,
        "gst_option": gstOption,
        "branch_id": branchId,
      };

      final res = await _service.createProduct(payload);
      if (res.status == true) {
        Get.snackbar(
          'Success',
          res.message ?? 'Product created successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF15803D),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
        fetchProducts();
        return true;
      } else {
        Get.snackbar(
          'Error',
          res.message ?? 'Failed to create product.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFDC2626),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDC2626),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Update Product API
  Future<bool> updateProduct({
    required int id,
    required String name,
    required int categoryId,
    required int brandId,
    required int unitId,
    required double price,
    required double mrp,
    required double purchasePrice,
    required int quantity,
    required String sku,
    String itemType = 'normal',
    String status = 'active',
    String availability = 'in_stock',
    String gstOption = 'without_gst',
    int branchId = 1,
  }) async {
    isSubmitting.value = true;
    try {
      final payload = {
        "id": id,
        "name": name,
        "category_id": categoryId,
        "brand_id": brandId,
        "unit_id": unitId,
        "price": price,
        "mrp": mrp,
        "purchase_price": purchasePrice,
        "quantity": quantity,
        "SKU": sku,
        "item_type": itemType,
        "status": status,
        "availablility": availability,
        "gst_option": gstOption,
        "branch_id": branchId,
      };

      final res = await _service.updateProduct(payload);
      if (res.status == true) {
        Get.snackbar(
          'Success',
          res.message ?? 'Product updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF15803D),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
        fetchProducts();
        return true;
      } else {
        Get.snackbar(
          'Error',
          res.message ?? 'Failed to update product.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFDC2626),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDC2626),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Delete Product API
  Future<bool> deleteProduct(int productId) async {
    isDeleting.value = true;
    try {
      final res = await _service.deleteProduct(productId);
      if (res.status == true) {
        productsList.removeWhere((item) => item.id == productId);
        Get.snackbar(
          'Deleted',
          res.message ?? 'Product deleted successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFDC2626),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          res.message ?? 'Failed to delete product.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFDC2626),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDC2626),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return false;
    } finally {
      isDeleting.value = false;
    }
  }
}
