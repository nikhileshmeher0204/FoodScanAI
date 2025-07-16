import 'dart:io';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/theme/app_theme.dart';
import 'package:read_the_label/views/screens/ask_ai_view.dart';
import 'package:rive/rive.dart' as rive;
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/viewmodels/meal_analysis_view_model.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';
import 'package:read_the_label/views/widgets/ask_ai_widget.dart';
import 'package:read_the_label/views/widgets/food_item_card.dart';
import 'package:read_the_label/views/widgets/food_item_card_shimmer.dart';
import 'package:read_the_label/views/widgets/product_image_capture_buttons.dart';
import 'package:read_the_label/views/widgets/total_nutrients_card.dart';
import 'package:read_the_label/views/widgets/total_nutrients_card_shimmer.dart';

class FoodAnalysisView extends StatefulWidget {
  const FoodAnalysisView({
    super.key,
  });

  @override
  State<FoodAnalysisView> createState() => _FoodAnalysisViewState();
}

class _FoodAnalysisViewState extends State<FoodAnalysisView> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          pinned: true,
          expandedHeight: 120,
          flexibleSpace: FlexibleSpaceBar(
            expandedTitleScale: 1.75,
            titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
            title: Text(
              'Scan Food',
              style: AppTextStyles.heading2BoldClose,
            ),
            collapseMode: CollapseMode.pin,
          ),
        ),
        SliverToBoxAdapter(
          child: Consumer3<UiViewModel, MealAnalysisViewModel,
                  DailyIntakeViewModel>(
              builder: (context, uiProvider, mealAnalysisProvider,
                  dailyIntakeProvider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Scanning Section
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.transparent),
                  ),
                  child: DottedBorder(
                    borderPadding: const EdgeInsets.all(-20),
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(20),
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.2),
                    strokeWidth: 1,
                    dashPattern: const [6, 4],
                    child: Column(
                      children: [
                        if (mealAnalysisProvider.foodImage != null)
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image(
                                    image: FileImage(
                                        mealAnalysisProvider.foodImage!)),
                              ),
                              if (uiProvider.loading)
                                const Positioned.fill(
                                  left: 5,
                                  right: 5,
                                  top: 5,
                                  bottom: 5,
                                  child: rive.RiveAnimation.asset(
                                    'assets/riveAssets/qr_code_scanner.riv',
                                    fit: BoxFit.fill,
                                    artboard: 'scan_board',
                                    animations: ['anim1'],
                                    stateMachines: ['State Machine 1'],
                                  ),
                                )
                            ],
                          )
                        else
                          Icon(
                            Icons.restaurant_outlined,
                            size: 70,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                          ),
                        const SizedBox(height: 20),
                        Text(
                          "Snap a picture of your meal or pick one from your gallery",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 20),
                        FoodImageCaptureButtons(
                          onImageCapturePressed: _handleFoodImageCapture,
                        ),
                      ],
                    ),
                  ),
                ),

                //Loading animation

                if (uiProvider.loading)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Analysis Results',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter'),
                        ),
                      ),
                      const FoodItemCardShimmer(),
                      const FoodItemCardShimmer(),
                      const TotalNutrientsCardShimmer(),
                    ],
                  ),

                // Results Section
                if (mealAnalysisProvider.foodImage != null &&
                    mealAnalysisProvider.analyzedScannedFoodItems.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Analysis Results',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...mealAnalysisProvider.analyzedScannedFoodItems
                          .asMap()
                          .entries
                          .map((entry) => FoodItemCard(
                                item: entry.value,
                                index: entry.key,
                              )),
                      TotalNutrientsCard(
                          mealName: mealAnalysisProvider.scannedMealName,
                          numberOfFoodItems: mealAnalysisProvider
                              .analyzedScannedFoodItems.length,
                          totalPlateNutrients:
                              mealAnalysisProvider.totalScannedPlateNutrients),
                      InkWell(
                        onTap: () {
                          print("Tap detected!");
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => AskAiView(
                                foodContext: "food",
                                mealName: mealAnalysisProvider.scannedMealName,
                                foodImage: mealAnalysisProvider.foodImage!,
                              ),
                            ),
                          );
                        },
                        child: const AskAiWidget(),
                      ),
                    ],
                  ),
              ],
            );
          }),
        ),
      ],
    );
  }

  void _handleFoodImageCapture(ImageSource source) async {
    final mealAnalysisProvider =
        Provider.of<MealAnalysisViewModel>(context, listen: false);
    final imagePicker = ImagePicker();
    final image = await imagePicker.pickImage(source: source);

    if (image != null) {
      // Use the setter method instead of direct assignment
      mealAnalysisProvider.setFoodImage(File(image.path));

      await mealAnalysisProvider.analyzeFoodImage(
        imageFile: mealAnalysisProvider.foodImage!,
      );
    }
  }
}
