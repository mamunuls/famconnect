import 'package:famconnect/features/common/ui/widgets/custom_app_bar.dart';
import 'package:famconnect/features/gifts/controller/gift_suggestion_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GiftSuggestionScreen extends StatelessWidget {
  GiftSuggestionScreen({super.key});
  final controller = Get.put(GiftSuggestionController());

  final RxnString selectedOccasion = RxnString();
  final RxnString selectedInterest = RxnString();
  final RxnString selectedGender = RxnString();
  final RxnString selectedAgeGroup = RxnString();

  final List<String> occasions = ['Birthday', 'Anniversary', 'Graduation', 'Holiday'];
  final List<String> interests = ['Tech', 'Fashion', 'Books', 'Fitness'];
  final List<String> genders = ['Male', 'Female'];
  final List<String> ageGroups = ['0-12', '13-19', '20-35', '36-60', '60+'];

  void triggerSearch() {
    if (selectedOccasion.value != null &&
        selectedInterest.value != null &&
        selectedGender.value != null &&
        selectedAgeGroup.value != null) {
      controller.fetchGiftSuggestions(
        occasion: selectedOccasion.value!,
        interest: selectedInterest.value!,
        gender: selectedGender.value!,
        ageGroup: selectedAgeGroup.value!,
      );
    } else {
      Get.snackbar("Missing", "Please select all fields");
    }
  }

  Widget buildDropdown(String label, List<String> items, RxnString selected) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        DropdownButton<String>(
          value: selected.value,
          hint: Text("Select $label"),
          isExpanded: true,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: (value) => selected.value = value,
        ),
        SizedBox(height: 10),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: ('Gift Suggestions')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildDropdown("Occasion", occasions, selectedOccasion),
            buildDropdown("Interest", interests, selectedInterest),
            buildDropdown("Gender", genders, selectedGender),
            buildDropdown("Age Group", ageGroups, selectedAgeGroup),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: triggerSearch,
              child: Obx(() => controller.isLoading.value
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator())
                  : const Text('Get Suggestions')),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                final suggestions = controller.suggestions;
                if (suggestions.isEmpty) {
                  return Center(child: Text('No suggestions yet.'));
                }
                return ListView.builder(
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: Icon(Icons.card_giftcard),
                    title: Text(suggestions[index]),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
