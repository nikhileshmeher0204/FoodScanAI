import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/views/widgets/date_selector.dart';
import 'package:read_the_label/views/widgets/detailed_nutrients_card.dart';
import 'package:read_the_label/views/widgets/food_history_card.dart';
import 'package:read_the_label/views/widgets/header_widget.dart';
import 'package:read_the_label/views/widgets/macronutrien_summary_card.dart';

class DailyIntakeView extends StatefulWidget {
  const DailyIntakeView({super.key});

  @override
  State<DailyIntakeView> createState() => _DailyIntakeViewState();
}

class _DailyIntakeViewState extends State<DailyIntakeView> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initializeData() async {
    print("Initializing DailyIntakePage data...");
    final dailyIntakeProvider =
        Provider.of<DailyIntakeViewModel>(context, listen: false);

    // Debug check storage
    await dailyIntakeProvider.debugCheckStorage();

    // Load food history first
    print("Loading food history...");
    await dailyIntakeProvider.loadFoodHistory();

    // Then load daily intake for selected date
    print("Loading daily intake for selected date...");
    await dailyIntakeProvider.loadDailyIntake(DateTime.now());

    setState(() {
      _selectedDate = DateTime.now();
    });
  }

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
              'Daily Intake',
              style: AppTextStyles.heading2BoldClose,
            ),
            collapseMode: CollapseMode.pin,
          ),
        ),
        SliverToBoxAdapter(
          child: Consumer<DailyIntakeViewModel>(
              builder: (context, dailyIntakeProvider, _) {
            return Column(
              children: [
                HeaderCard(context, _selectedDate),
                DateSelector(
                  context,
                  _selectedDate,
                  (DateTime newDate) {
                    setState(() {
                      _selectedDate = newDate;
                      dailyIntakeProvider.loadDailyIntake(newDate);
                    });
                  },
                ),
                MacronutrientSummaryCard(
                    context, dailyIntakeProvider.dailyIntake),
                FoodHistoryCard(
                    context: context,
                    currentIndex: 2,
                    selectedDate: _selectedDate),
                DetailedNutrientsCard(context, dailyIntakeProvider.dailyIntake),
              ],
            );
          }),
        ),
      ],
    );
  }
}
