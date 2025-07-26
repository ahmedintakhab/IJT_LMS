import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utils/api_constant.dart';

class FilterSheet extends StatefulWidget {
  final String query;
  final List<Map<String, dynamic>> categoryData; // Added
  final Map<String, List<dynamic>> subcategoriesData; // Added
  final Function(List<dynamic>) onFilterApplied;
  const FilterSheet({Key? key, required this.query, required this.categoryData,
    required this.subcategoriesData,  required this.onFilterApplied}) : super(key: key);

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  RangeValues _currentRangeValues = const RangeValues(0, 20000);
  Set<int> selectedSubcategoryIds = {}; // Track selected subcategory IDs
  Map<int, bool> subcategorySelectionState = {}; // Track selection state for color toggling
  bool activevalue = false;
  List <String> categoryList = [];
  List <String> selectedCategory = [];
  double slidervalue = 0;
  double rate = 0;
  bool isLoading = true;
  String errorMessage = '';
  String? expandedCategoryId;


  @override
  void initState (){
    super.initState();
    // fetchCategories (); //Fetch categories on page load
    // fetchCategoriesAndSubcategories();

  }

  Widget buildSubcategories(String categoryId) {
    final subCats = widget.subcategoriesData[categoryId];
    if (subCats == null || subCats.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: subCats.map((subcategory) {
        final subcategoryId = subcategory['subcategory_id'];
        final isSelected = selectedSubcategoryIds.contains(subcategoryId);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedSubcategoryIds.remove(subcategoryId); // Deselect
              } else {
                selectedSubcategoryIds.add(subcategoryId); // Select
              }
              subcategorySelectionState[subcategoryId] = !isSelected; // Toggle selection state
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 20, top: 8),
            child: Text(
              subcategory['subcategory_name'].toString(),
              style: TextStyle(
                fontFamily: 'Gilroy',
                color: isSelected ? const Color(0XFF00AFEE) : const Color(0XFF6E758A),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }


  //Filter API Calling function
  Future<void> applyFilter() async {
    final url = Uri.parse('${ApiConstant.baseUrl}search-course-list');

    try {
      // Map selected category names to IDs
      final selectedCategoryIds = widget.categoryData
          .where((category) => selectedCategory.contains(category['category_name']))
          .map((category) => category['category_id'])
          .toList();

      // Convert selected subcategory IDs to a list
      final selectedSubcategoryIdsList = selectedSubcategoryIds.toList();

      // Print the values being sent in the API call
      print('Query: ${widget.query}');
      print('Min Price: ${_currentRangeValues.start}');
      print('Max Price: ${_currentRangeValues.end}');
      print('Rating: $rate');
      print('Selected Categories: $selectedCategoryIds');
      print('Selected Subcategories: $selectedSubcategoryIdsList');

      final response = await http.post(
        url,
        body: json.encode({
          'keyword': widget.query,
          'min_price': _currentRangeValues.start,
          'max_price': _currentRangeValues.end,
          'rating': rate,
          'category_ids': selectedCategoryIds,
          'subcategory_ids': selectedSubcategoryIdsList, // Pass selected subcategories
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Filter API Status Code: ${response.statusCode}');
        print('API Successfully filter data');
        // First access the 'data' object from the response
        final responseData = data['data'] ?? {};

        // Then extract course_results from the data object
        final List<dynamic> results = responseData['course_results'] ?? [];

        widget.onFilterApplied(results);
        Navigator.pop(context);
      } else {
        print('Failed to Apply filter. Please try again.');
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Failed to apply filter. Please try again.')),
        // );
      }
    } catch (e) {
      print('An error occurred: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('An error occurred: $e')),
      // );
    }
  }

  void clearAllFilters() {
    setState(() {
      _currentRangeValues = const RangeValues(0, 20000);
      selectedCategory.clear();
      selectedSubcategoryIds.clear(); // Clear selected subcategories
      subcategorySelectionState.clear(); // Reset selection state
      rate = 0; // Reset the rating
    });
  }


  @override
  Widget build(BuildContext context) {
    // print('check the query after passing: ${widget.query}');
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Filter",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Price range",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                    "\Rs.${_currentRangeValues.start.round().toString()}-\Rs.${_currentRangeValues.end.round().toString()}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold))
              ],
            ),
            RangeSlider(
              activeColor: Color(0XFF00AFEE),
              values: _currentRangeValues,
              min: 0,
              max: 20000,
              divisions: 20,
              labels: RangeLabels(
                _currentRangeValues.start.round().toString(),
                _currentRangeValues.end.round().toString(),
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _currentRangeValues = values;
                });
              },
            ),
            const SizedBox(height: 10),
            const Text(
              "Ratings",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                RatingBar.builder(
                  initialRating: rate, // Reflects the current rating
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star_rounded,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      rate = rating;
                    });
                  },
                ),
                const SizedBox(width: 20),
                Text(
                  "${rate}",
                  style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(width: 20, height: 10,),
            Text(
              "Categories",
              style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // if (isLoading)
            //   const Center(child: CircularProgressIndicator(color: Color(0XFF00AFEE)))
            // else if (errorMessage.isNotEmpty)
            //   Center(child: Text(errorMessage))
            // else
            Wrap(
              alignment: WrapAlignment.start,
              children: widget.categoryData.map((category) {
                final isSelected = selectedCategory.contains(category['category_name']);
                final hasSubcategories = category['has_subcategories'] == true;

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 13),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0XFFEBF2C2) : Colors.white,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: isSelected ? const Color(0XFF23408F) : const Color(0XFF6E758A),
                            width: 1,
                          ),
                        ),
                        child: IntrinsicWidth(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    final categoryName = category['category_name'].toString();
                                    if (isSelected) {
                                      selectedCategory.remove(categoryName);
                                    } else {
                                      selectedCategory.add(categoryName);
                                    }
                                  });
                                },
                                child: Text(
                                  category['category_name'].toString(),
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? const Color(0XFF23408F) : const Color(0XFF6E758A),
                                    fontFamily: 'Gilroy',
                                  ),
                                ),
                              ),
                              if (hasSubcategories)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (expandedCategoryId == category['category_id'].toString()) {
                                        expandedCategoryId = null;
                                      } else {
                                        expandedCategoryId = category['category_id'].toString();
                                      }
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Icon(
                                      expandedCategoryId == category['category_id'].toString()
                                          ? Icons.arrow_drop_up
                                          : Icons.arrow_drop_down,
                                      color: isSelected ? const Color(0XFF23408F) : const Color(0XFF6E758A),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (expandedCategoryId == category['category_id'].toString())
                        buildSubcategories(category['category_id'].toString()),
                    ],
                  ),
                );
              }).toList(),
            ),


            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: applyFilter,
                    child: Container(
                      height: 56,
                      width: 157,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        color: Color(0XFF00AFEE),
                      ),
                      child: const Center(
                          child: Text(
                            "Apply",
                            style: TextStyle(
                                fontSize: 18,
                                color: Color(0XFFFFFFFF),
                                fontFamily: 'Gilroy',
                                fontWeight: FontWeight.bold),
                          )),
                    ),
                  ),
                  GestureDetector(
                    onTap: clearAllFilters,
                    child: Container(
                      height: 56,
                      width: 157,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          color: Color(0XFFB7B7B7)
                      ),
                      child: const Center(
                          child: Text(
                            "Clear All",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontFamily: 'Gilroy',
                                fontWeight: FontWeight.bold),
                          )),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
