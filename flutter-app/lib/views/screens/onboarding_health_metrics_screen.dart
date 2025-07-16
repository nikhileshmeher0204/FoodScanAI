import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/main.dart';
import 'package:read_the_label/repositories/user_repository.dart';
import 'package:read_the_label/services/auth_service.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/viewmodels/onboarding_view_model.dart';
import 'package:read_the_label/views/widgets/goal_button.dart';

class OnboardingHealthMetricsScreen extends StatefulWidget {
  const OnboardingHealthMetricsScreen({super.key});

  @override
  State<OnboardingHealthMetricsScreen> createState() =>
      _OnboardingHealthMetricsScreenState();
}

class _OnboardingHealthMetricsScreenState
    extends State<OnboardingHealthMetricsScreen> {
  // Height values
  int _selectedHeightFeet = 5;
  int _selectedHeightInches = 8;

  // Weight value
  int _selectedWeight = 65; // Default weight in kg instead of 140 lb

  int _selectedGoalIndex = -1;

  @override
  Widget build(BuildContext context) {
    final onboardingViewModel = Provider.of<OnboardingViewModel>(context);
    final userRepo = Provider.of<UserRepository>(context, listen: false);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/onboarding_health_metrics_screen_image.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.onboardingTitle,
                children: [
                  TextSpan(
                      text: "Tell us about \nyourself. \n",
                      style: AppTextStyles.heading1),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: AppTextStyles.onboardingTitle,
                            children: [
                              const TextSpan(
                                text: "Let's personalize recommendations for ",
                              ),
                              TextSpan(
                                  text: "your health goals.",
                                  style: AppTextStyles.onboardingAccent),
                            ],
                          ),
                        ),
                        // Height selection
                        _buildMetricSelector(
                          icon: Icons.height,
                          label: "Height",
                          value:
                              "$_selectedHeightFeet ft $_selectedHeightInches in",
                          onTap: () => _showHeightPicker(context),
                        ),
                        // Weight selection
                        _buildMetricSelector(
                          icon: Icons.monitor_weight_outlined,
                          label: "Weight",
                          value: "$_selectedWeight kg",
                          onTap: () => _showWeightPicker(context),
                        ),
                        // What's your goal section
                        Text(
                          "Select your priority",
                          style: AppTextStyles.heading2
                              .copyWith(color: AppColors.primaryWhite),
                        ),
                        // const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: GoalButton(
                                title: "Balanced\nDiet",
                                iconPath: "assets/icons/balanced_diet_icon.png",
                                isSelected: onboardingViewModel.fitnessGoal ==
                                    FitnessGoal.balancedDiet,
                                accentColor:
                                    AppColors.secondaryGreen.withOpacity(0.9),
                                onTap: () {
                                  onboardingViewModel
                                      .setFitnessGoal(FitnessGoal.balancedDiet);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GoalButton(
                                title: "Muscle\nGain",
                                iconPath: "assets/icons/muscle_gain_icon.png",
                                isSelected: onboardingViewModel.fitnessGoal ==
                                    FitnessGoal.muscleGain,
                                accentColor: const Color(0xFF9370DB), // Purple
                                onTap: () {
                                  onboardingViewModel
                                      .setFitnessGoal(FitnessGoal.muscleGain);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GoalButton(
                                title: "Weight\nLoss",
                                iconPath: "assets/icons/weight_loss_icon.png",
                                isSelected: onboardingViewModel.fitnessGoal ==
                                    FitnessGoal.weightLoss,
                                accentColor: const Color(0xFFFFA500), // Orange
                                onTap: () {
                                  onboardingViewModel
                                      .setFitnessGoal(FitnessGoal.weightLoss);
                                },
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 14,
                            ),
                            Flexible(
                              child: Text(
                                " Product insights are customized for your priority.",
                                style: AppTextStyles.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  try {
                                    final authService =
                                        Provider.of<AuthService>(context,
                                            listen: false);
                                    final user = authService.currentUser;
                                    if (user == null) {
                                      logger.e(
                                          'User is null, cannot complete onboarding');
                                      return;
                                    }

                                    // Single API call to complete all onboarding data
                                    await userRepo.completeOnboarding(
                                      firebaseUid: user.uid,
                                      dietaryPreference: onboardingViewModel
                                          .getDietaryPreferenceString(),
                                      country:
                                          onboardingViewModel.selectedCountry,
                                      heightFeet: onboardingViewModel
                                          .selectedHeightFeet,
                                      heightInches: onboardingViewModel
                                          .selectedHeightInches,
                                      weightKg: onboardingViewModel
                                          .selectedWeight
                                          .toDouble(),
                                      goal: onboardingViewModel.getGoalString(),
                                    );

                                    // Navigate to home screen
                                    if (context.mounted) {
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        '/home',
                                        (route) => false,
                                      );
                                    }
                                  } catch (e) {
                                    logger.e('Error completing onboarding: $e');
                                    // Show error to user
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Error saving information: ${e.toString()}'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryWhite,
                                  foregroundColor: AppColors.primaryBlack,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                child: Text(
                                  "Continue",
                                  style: AppTextStyles.buttonTextBlack,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Helper method to build metric selectors (height and weight)
  Widget _buildMetricSelector({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            width: double.infinity,
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppTextStyles.secondaryTextColor,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: AppTextStyles.withColor(
                    AppTextStyles.heading4,
                    AppColors.primaryWhite,
                  ),
                ),
                const Spacer(),
                RichText(
                  text: TextSpan(
                    children: _buildValueTextSpans(value),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppTextStyles.secondaryTextColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Add this helper method to parse and style the value text
  List<TextSpan> _buildValueTextSpans(String value) {
    List<TextSpan> spans = [];

    // Handle height format (e.g., "5 ft 8 in")
    if (value.contains("ft") && value.contains("in")) {
      final parts = value.split(" ");
      if (parts.length >= 4) {
        // Number before "ft"
        spans.add(TextSpan(
          text: "${parts[0]} ",
          style: const TextStyle(
            color: AppColors.primaryWhite,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            fontFamily: AppTextStyles.fontFamily,
          ),
        ));

        // "ft" text
        spans.add(TextSpan(
          text: "${parts[1]} ",
          style: const TextStyle(
            color: AppTextStyles.secondaryTextColor,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            fontFamily: AppTextStyles.fontFamily,
          ),
        ));

        // Number before "in"
        spans.add(TextSpan(
          text: "${parts[2]} ",
          style: const TextStyle(
            color: AppColors.primaryWhite,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            fontFamily: AppTextStyles.fontFamily,
          ),
        ));

        // "in" text
        spans.add(TextSpan(
          text: parts[3],
          style: const TextStyle(
            color: AppTextStyles.secondaryTextColor,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            fontFamily: AppTextStyles.fontFamily,
          ),
        ));
      }
    }
    // Handle weight format (e.g., "65 kg")
    else if (value.contains("kg")) {
      final parts = value.split(" ");
      if (parts.length >= 2) {
        // Number before "kg"
        spans.add(TextSpan(
          text: "${parts[0]} ",
          style: const TextStyle(
            color: AppColors.primaryWhite,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            fontFamily: AppTextStyles.fontFamily,
          ),
        ));

        // "kg" text
        spans.add(TextSpan(
          text: parts[1],
          style: const TextStyle(
            color: AppTextStyles.secondaryTextColor,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            fontFamily: AppTextStyles.fontFamily,
          ),
        ));
      }
    }
    // Fallback for any other format
    else {
      spans.add(TextSpan(
        text: value,
        style: const TextStyle(
          color: AppColors.primaryWhite,
          fontSize: 20,
          fontWeight: FontWeight.w500,
          fontFamily: AppTextStyles.fontFamily,
        ),
      ));
    }

    return spans;
  }

  // Height picker
  void _showHeightPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          decoration: const BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppTextStyles.secondaryTextColor,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text(
                        'Cancel',
                        style:
                            TextStyle(color: AppTextStyles.secondaryTextColor),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoButton(
                      child: const Text(
                        'Done',
                        style: TextStyle(color: AppColors.secondaryGreen),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    // Feet picker
                    Expanded(
                      child: CupertinoPicker(
                        magnification: 1.22,
                        squeeze: 1.2,
                        useMagnifier: true,
                        backgroundColor: AppColors.cardBackground,
                        itemExtent: 40,
                        scrollController: FixedExtentScrollController(
                          initialItem: _selectedHeightFeet - 3,
                        ),
                        onSelectedItemChanged: (int index) {
                          setState(() {
                            _selectedHeightFeet =
                                index + 3; // Starting from 3 feet
                          });
                        },
                        children: List<Widget>.generate(
                          8,
                          (index) {
                            return Center(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "${index + 3} ",
                                      style: const TextStyle(
                                        color: AppColors.primaryWhite,
                                        fontSize: 22,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: "ft",
                                      style: TextStyle(
                                        color: AppTextStyles.secondaryTextColor,
                                        fontSize: 22,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Inches picker
                    Expanded(
                      child: CupertinoPicker(
                        magnification: 1.22,
                        squeeze: 1.2,
                        useMagnifier: true,
                        backgroundColor: AppColors.cardBackground,
                        itemExtent: 40,
                        scrollController: FixedExtentScrollController(
                          initialItem: _selectedHeightInches,
                        ),
                        onSelectedItemChanged: (int index) {
                          setState(() {
                            _selectedHeightInches = index;
                          });
                        },
                        children: List<Widget>.generate(
                          12,
                          (index) {
                            return Center(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "$index ",
                                      style: const TextStyle(
                                        color: AppColors.primaryWhite,
                                        fontSize: 22,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: "in",
                                      style: TextStyle(
                                        color: AppTextStyles.secondaryTextColor,
                                        fontSize: 22,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Weight picker
  void _showWeightPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          decoration: const BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppTextStyles.secondaryTextColor,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text(
                        'Cancel',
                        style:
                            TextStyle(color: AppTextStyles.secondaryTextColor),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoButton(
                      child: const Text(
                        'Done',
                        style: TextStyle(color: AppColors.secondaryGreen),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    // Weight picker
                    Expanded(
                      child: CupertinoPicker(
                        magnification: 1.22,
                        squeeze: 1.2,
                        useMagnifier: true,
                        backgroundColor: AppColors.cardBackground,
                        itemExtent: 40,
                        scrollController: FixedExtentScrollController(
                          initialItem: _selectedWeight - 20, // Start at 20 kg
                        ),
                        onSelectedItemChanged: (int index) {
                          setState(() {
                            _selectedWeight = index + 20; // 20 kg to 220 kg
                          });
                        },
                        children: List<Widget>.generate(201, (index) {
                          return Center(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "${index + 20} ",
                                    style: const TextStyle(
                                      color: AppColors.primaryWhite,
                                      fontSize: 22,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: "kg",
                                    style: TextStyle(
                                      color: AppTextStyles.secondaryTextColor,
                                      fontSize: 22,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
