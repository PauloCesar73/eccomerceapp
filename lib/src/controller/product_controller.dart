import 'package:eccomerceapp/core/app_data.dart';
import 'package:eccomerceapp/core/extensions.dart';
import 'package:eccomerceapp/src/model/numerical.dart';
import 'package:eccomerceapp/src/model/product.dart';
import 'package:eccomerceapp/src/model/product_category.dart';
import 'package:eccomerceapp/src/model/product_size_type.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class ProductController extends GetxController {
  RxList<Product> allProducts = AppData.products.obs;
  RxList<Product> filteredProducts = AppData.products.obs;
  RxList<Product> cartProducts = <Product>[].obs;
  RxList<ProductCategory> categories = AppData.categories.obs;
  int length = ProductType.values.length;
  RxInt totalPrice = 0.obs;
  RxInt currentBottomNavItemIndex = 0.obs;
  RxInt productImageDefaultIndex = 0.obs;

  void filterItemsByCategory(int index) {
    for (ProductCategory element in categories) {
      element.isSelected = false;
    }
    categories[index].isSelected = true;

    if (categories[index].type == ProductType.all) {
      filteredProducts.assignAll(allProducts);
    } else {
      filteredProducts.assignAll(allProducts.where((item) {
        return item.type == categories[index].type;
      }).toList());
    }
  }

  void isLiked(int index) {
    filteredProducts[index].isLiked = !filteredProducts[index].isLiked;
    filteredProducts.refresh();
  }

  void addToCart(Product product) {
    product.quantity++;
    cartProducts.add(product);
    cartProducts.assignAll(cartProducts.distinctBy((item) => item));
    calculateTotalPrice();
  }

  void increaseItem(int index) {
    Product product = cartProducts[index];
    product.quantity++;
    calculateTotalPrice();
    update();
  }

  bool isPriceOff(Product product) => product.off != null;

  bool get isEmptyCart => cartProducts.isEmpty;

  bool isNominal(Product product) => product.sizes?.numerical != null;

  void decreaseItem(int index) {
    Product product = cartProducts[index];
    if (product.quantity > 0) {
      product.quantity--;
    }
    calculateTotalPrice();
    update();
  }

  void calculateTotalPrice() {
    totalPrice.value = 0;
    for (var element in cartProducts) {
      if (isPriceOff(element)) {
        totalPrice.value += element.quantity * element.off!;
      } else {
        totalPrice.value += element.quantity * element.price;
      }
    }
  }

  void switchBetweenBottomNavigationItems(int index) {
    switch (index) {
      case 0:
        filteredProducts.assignAll(allProducts);
        break;
      case 1:
        getLikedItems;
        break;
      case 2:
        cartProducts.assignAll(allProducts.where((item) => item.quantity > 0));
    }
    currentBottomNavItemIndex.value = index;
  }

  void switchBetweenProductImages(int index) {
    productImageDefaultIndex.value = index;
  }

  get getLikedItems => filteredProducts.assignAll(
        allProducts.where((item) => item.isLiked),
      );

  List<Numerical> sizeType(Product product) {
    ProductSizeType? productSize = product.sizes;
    List<Numerical> numericalList = [];

    if (productSize?.numerical != null) {
      for (var element in productSize!.numerical!) {
        numericalList.add(Numerical(element.numerical, element.isSelected));
      }
    }

    if (productSize?.categorical != null) {
      for (var element in productSize!.categorical!) {
        numericalList.add(
          Numerical(
            element.categorical.name,
            element.isSelected,
          ),
        );
      }
    }

    return numericalList;
  }

  void switchBetweenProductSizes(Product product, int index) {
    sizeType(product).forEach((element) {
      element.isSelected = false;
    });

    if (product.sizes?.categorical != null) {
      for (var element in product.sizes!.categorical!) {
        element.isSelected = false;
      }

      product.sizes?.categorical![index].isSelected = true;
    }

    if (product.sizes?.numerical != null) {
      for (var element in product.sizes!.numerical!) {
        element.isSelected = false;
      }

      product.sizes?.numerical![index].isSelected = true;
    }

    update();
  }

  String getCurrentSize(Product product) {
    String currentSize = "";
    if (product.sizes?.categorical != null) {
      for (var element in product.sizes!.categorical!) {
        if (element.isSelected) {
          currentSize = "Size: ${element.categorical.name}";
        }
      }
    }

    if (product.sizes?.numerical != null) {
      for (var element in product.sizes!.numerical!) {
        if (element.isSelected) {
          currentSize = "Size: ${element.numerical}";
        }
      }
    }
    return currentSize;
  }
}
