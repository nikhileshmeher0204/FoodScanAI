import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';

class NutrientGrid extends StatefulWidget {
  final List<NutrientData> nutrients;

  const NutrientGrid({
    super.key,
    required this.nutrients,
  });

  @override
  State<NutrientGrid> createState() => _NutrientGridState();
}

class _NutrientGridState extends State<NutrientGrid> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 20.0,
      children: widget.nutrients
          .map((nutrient) => NutrientTile(
                nutrient: nutrient.name,
                status: nutrient.status,
                healthSign: nutrient.healthSign,
                quantity: nutrient.quantity,
                dailyValue: nutrient.dailyValue,
                insight: nutrient.insight,
              ))
          .toList(),
    );
  }
}

class NutrientTile extends StatefulWidget {
  final String nutrient;
  final String status;
  final String healthSign;
  final String quantity;
  final String dailyValue;
  final String? insight;

  const NutrientTile({
    super.key,
    required this.nutrient,
    required this.status,
    required this.healthSign,
    required this.quantity,
    required this.dailyValue,
    this.insight,
  });

  @override
  State<NutrientTile> createState() => _NutrientTileState();
}

class _NutrientTileState extends State<NutrientTile>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = AppColors.cardBackground;
    IconData statusIcon;

    switch (widget.healthSign) {
      case "Good":
        statusIcon = Icons.check_circle_rounded;
        break;
      case "Bad":
        statusIcon = Icons.warning_outlined;
        break;
      default:
        statusIcon = Icons.warning_outlined;
    }

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
            if (_isExpanded) {
              _animationController.forward();
            } else {
              _animationController.reverse();
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          width: double.infinity,
          decoration: BoxDecoration(
            color: backgroundColor,
          ),
          clipBehavior: Clip.antiAlias,
          child: ClipRRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        widget.nutrient,
                                        style: AppTextStyles.bodyLargeBold,
                                      ),
                                      Expanded(
                                        child: Container(),
                                      ),
                                      Text(
                                        widget.quantity,
                                        style: AppTextStyles.bodyLargeBold,
                                      ),
                                      // RotationTransition(
                                      //   turns: Tween(begin: 0.0, end: 0.5)
                                      //       .animate(_animationController),
                                      //   child: Icon(
                                      //     Icons.keyboard_arrow_down,
                                      //     color: Theme.of(context)
                                      //         .textTheme
                                      //         .bodyMedium!
                                      //         .color,
                                      //     size: 20,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        statusIcon,
                                        size: 16,
                                        color: widget.healthSign == "Good"
                                            ? AppColors.secondaryGreen
                                            : widget.healthSign == "Bad"
                                                ? AppColors.secondaryRed
                                                : AppColors.secondaryOrange,
                                      ),
                                      const SizedBox(width: 4),
                                      widget.healthSign == "Good"
                                          ? Text("Good",
                                              style: AppTextStyles
                                                  .bodyMediumGreenAccent)
                                          : widget.healthSign == "Bad" &&
                                                  widget.status == "Low"
                                              ? Text("Insufficient",
                                                  style: AppTextStyles
                                                      .bodyMediumRedAccent)
                                              : Text("Limit",
                                                  style: AppTextStyles
                                                      .bodyMediumOrangeAccent),
                                      Expanded(
                                        child: Container(),
                                      ),
                                      Text(
                                        "${widget.dailyValue} DV",
                                        style: TextStyle(
                                          color: widget.healthSign == "Good"
                                              ? AppColors.secondaryGreen
                                              : widget.healthSign == "Bad"
                                                  ? AppColors.secondaryRed
                                                  : AppColors.secondaryOrange,
                                          fontSize: 16,
                                          letterSpacing: -0.2,
                                          height: 1.5,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (_isExpanded && widget.insight != null)
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: _isExpanded ? 1.0 : 0.0,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Text(
                                widget.insight!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color,
                                  height: 1.5,
                                  fontFamily: 'Inter',
                                ),
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
        ),
      ),
    );
  }
}

// Data model for nutrient information
class NutrientData {
  final String name;
  final String healthSign;
  final String status;
  final String quantity;
  final String dailyValue;
  final String? insight;

  NutrientData({
    required this.name,
    required this.healthSign,
    required this.status,
    required this.quantity,
    required this.dailyValue,
    this.insight,
  });
}
