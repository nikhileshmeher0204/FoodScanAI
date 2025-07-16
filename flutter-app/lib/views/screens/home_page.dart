import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';
import 'package:read_the_label/views/screens/product_analysis_view.dart';
import 'package:read_the_label/views/screens/food_analysis_view.dart';
import 'package:read_the_label/views/screens/daily_intake_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: IndexedStack(
          index: Provider.of<UiViewModel>(context).currentIndex,
          children: const [
            ProductAnalysisView(),
            FoodAnalysisView(),
            DailyIntakeView(),
          ],
        ),
      ),
      bottomNavigationBar: Consumer<UiViewModel>(
        builder: (context, uiProvider, _) {
          return Container(
            color: Colors.transparent,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: BottomNavigationBar(
                    elevation: 0,
                    selectedLabelStyle: AppTextStyles.bodySmallOrangeAccent,
                    unselectedLabelStyle: AppTextStyles.bodySmall,
                    backgroundColor: Colors.transparent,
                    selectedItemColor: AppColors.secondaryOrange,
                    unselectedItemColor: AppColors.primaryWhite,
                    currentIndex: uiProvider.currentIndex,
                    onTap: (index) {
                      uiProvider.updateCurrentIndex(index);
                    },
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.document_scanner),
                        label: 'Scan Label',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.food_bank),
                        label: 'Scan Food',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.pie_chart),
                        label: 'Daily Intake',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
