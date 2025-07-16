import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:read_the_label/repositories/spring_backend_repository.dart';
import 'package:read_the_label/viewmodels/base_view_model.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';

class ProductAnalysisViewModel extends BaseViewModel {
  // Properties for product scanning and analysis
  File? _frontImage;
  File? _nutritionLabelImage;
  String _productName = "";
  Map<String, dynamic> _nutritionAnalysis = {};
  List<Map<String, dynamic>> parsedNutrients = [];
  List<Map<String, dynamic>> optimalNutrients = [];
  List<Map<String, dynamic>> moderateNutrients = [];
  List<Map<String, dynamic>> watchOutNutrients = [];
  List<Map<String, dynamic>> _primaryConcerns = [];
  Map<String, dynamic> totalPlateNutrients = {};

// Dependencies
  SpringBackendRepository aiRepository;
  UiViewModel uiProvider;

  ProductAnalysisViewModel({
    required this.aiRepository,
    required this.uiProvider,
  });

  // Getters
  File? get frontImage => _frontImage;
  File? get nutritionLabelImage => _nutritionLabelImage;
  String get productName => _productName;
  Map<String, dynamic> get nutritionAnalysis => _nutritionAnalysis;
  bool canAnalyze() => _frontImage != null && _nutritionLabelImage != null;
  List<Map<String, dynamic>> getOptimalNutrients() => optimalNutrients;
  List<Map<String, dynamic>> getModerateNutrients() => moderateNutrients;
  List<Map<String, dynamic>> getWatchOutNutrients() => watchOutNutrients;
  List<Map<String, dynamic>> get primaryConcerns => _primaryConcerns;

  // Methods for product analysis
  Future<void> captureImage({
    required ImageSource source,
    required bool isFrontImage,
  }) async {
    final imagePicker = ImagePicker();
    final image = await imagePicker.pickImage(source: source);

    if (image != null) {
      if (isFrontImage) {
        _frontImage = File(image.path);
      } else {
        _nutritionLabelImage = File(image.path);
      }
      notifyListeners();
    }
  }

  double getCalories() {
    var energyNutrient = parsedNutrients.firstWhere(
      (nutrient) => nutrient['name'] == 'Energy',
      orElse: () => {'quantity': '0.0'},
    );
    // Parse the quantity string to remove any non-numeric characters except decimal points
    var quantity = energyNutrient['quantity']
        .toString()
        .replaceAll(RegExp(r'[^0-9\.]'), '');
    return double.tryParse(quantity) ?? 0.0;
  }

  Future<String> analyzeImages() async {
    uiProvider.setLoading(true);

    try {
      // Use the repository to get structured response
      final response = await aiRepository.analyzeProductImages(
          _frontImage!, _nutritionLabelImage!);

      // Process response (much simpler now!)
      _productName = response.product.name;

      _nutritionAnalysis = {};
      // Process nutrients
      parsedNutrients = [];
      optimalNutrients = [];
      moderateNutrients = [];
      watchOutNutrients = [];
      _primaryConcerns = []; // Clear primary concerns

      for (var nutrient in response.nutritionAnalysis.nutrients) {
        final nutrientMap = {
          'name': nutrient.name,
          'quantity': nutrient.quantity,
          'daily_value': nutrient.dailyValue,
          'status': nutrient.status,
          'health_impact': nutrient.healthImpact,
        };
        parsedNutrients.add(nutrientMap);

        if (nutrient.healthImpact == "Good") {
          optimalNutrients.add(nutrientMap);
        } else if (nutrient.healthImpact == "Moderate") {
          moderateNutrients.add(nutrientMap);
        } else {
          watchOutNutrients.add(nutrientMap);
        }
      }

      // Process primary concerns
      if (response.nutritionAnalysis.primaryConcerns.isNotEmpty) {
        for (var concern in response.nutritionAnalysis.primaryConcerns) {
          final recommendationsList = concern.recommendations
              .map((rec) => {
                    'food': rec.food,
                    'quantity': rec.quantity,
                    'reasoning': rec.reasoning,
                  })
              .toList();

          _primaryConcerns.add({
            'issue': concern.issue,
            'explanation': concern.explanation,
            'recommendations': recommendationsList,
          });
        }
      }

      // Handle serving size
      final servingSizeStr = response.nutritionAnalysis.servingSize;
      final servingSizeNum =
          double.tryParse(servingSizeStr.replaceAll(RegExp(r'[^0-9\.]'), '')) ??
              0.0;

      if (servingSizeNum > 0) {
        print("Setting serving size to: $servingSizeNum");
        uiProvider.updateServingSize(servingSizeNum);
      }

      print("📝 Product: $_productName");
      print("📊 Good nutrients: ${optimalNutrients.length}");
      print("⚠️ Moderate nutrients: ${moderateNutrients.length}");
      print("⚠️ Bad nutrients: ${watchOutNutrients.length}");

      notifyListeners();
      return "✅Product Analysis complete";
    } catch (e) {
      print("❌ Error analyzing images: $e");
      return "Error: $e";
    } finally {
      uiProvider.setLoading(false);
    }
  }
}
