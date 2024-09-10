import 'package:flutter/material.dart';
import 'package:food_delivery_flutter/controllers/location_controller.dart';
import 'package:food_delivery_flutter/controllers/popular_product_controller.dart';
import 'package:food_delivery_flutter/controllers/recommended_product_controller.dart';
import 'package:food_delivery_flutter/data/repository/recommended_product_repo.dart';
import 'package:food_delivery_flutter/models/address_model.dart';
import 'package:food_delivery_flutter/pages/home/food_page_body.dart';
import 'package:food_delivery_flutter/utils/SearchModal.dart';
import 'package:food_delivery_flutter/utils/colors.dart';
import 'package:food_delivery_flutter/utils/dimensions.dart';
import 'package:food_delivery_flutter/widgets/big_text.dart';
import 'package:get/get.dart';

class MainFoodPage extends StatefulWidget {
  const MainFoodPage({Key? key}) : super(key: key);

  @override
  State<MainFoodPage> createState() => _MainFoodPageState();
}

class _MainFoodPageState extends State<MainFoodPage> {
  final LocationController locationController = Get.find<LocationController>();
  final PopularProductController productController = Get.find<PopularProductController>();
  final RecommendedProductRepo proReco=Get.find<RecommendedProductRepo>();
  Future<void> _loadResource() async {
  try {
    // Await both methods to complete
   Future<void> _loadResource() async {
  await Future.wait([
    Get.find<PopularProductController>().getPopularProductList(),
    Get.find<RecommendedProductController>().getRecommendedProductList(),
  ]);
}

  } catch (e) {

    print("Error loading resources: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadResource,
      child: Column(
        children: [
          // Header with Search button and address
          Container(
            margin: EdgeInsets.only(top: Dimensions.height45, bottom: Dimensions.height15),
            padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Address Display
                FutureBuilder<List<AddressModel>>(
                  future: locationController.listAdd(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      AddressModel address = snapshot.data![0];
                      String truncatedAddress = address.address.length > 20
                          ? address.address.substring(0, 20) + '...'
                          : address.address;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BigText(text: truncatedAddress, color: AppColors.mainColor),
                        ],
                      );
                    } else {
                      return Text('No addresses found');
                    }
                  },
                ),
                
                // Search Button with Modal Trigger
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) => SearchModal(),
                    );
                  },
                  child: Container(
                    width: Dimensions.width45,
                    height: Dimensions.height45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.height15),
                      color: AppColors.mainColor,
                    ),
                    child: Icon(Icons.search, color: Colors.white, size: Dimensions.iconSize24),
                  ),
                ),
              ],
            ),
          ),

          // Body content (e.g., food listings)
          Expanded(
            child: SingleChildScrollView(
              child: FoodPageBody(),
            ),
          ),
        ],
      ),
    );
  }
}
