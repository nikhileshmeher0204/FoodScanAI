package com.scanmyfood.backend.services;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.auth.oauth2.GoogleCredentials;
import com.google.cloud.vertexai.VertexAI;
import com.google.cloud.vertexai.api.Content;
import com.google.cloud.vertexai.api.GenerateContentResponse;
import com.google.cloud.vertexai.generativeai.ContentMaker;
import com.google.cloud.vertexai.generativeai.GenerativeModel;
import com.google.cloud.vertexai.generativeai.PartMaker;

@Service
public class VertexAiServiceImpl implements AiService {
  private static final Logger logger = LoggerFactory.getLogger(VertexAiServiceImpl.class);
  private final ObjectMapper objectMapper;
  private final String projectId;
  private final String location;
  private final GoogleCredentials credentials;

  // Vertex AI constants
  private static final String PROJECT_ID = "foodscanai-d28bc";
  private static final String LOCATION = "us-central1";
  private static final String MODEL_NAME = "gemini-2.0-flash";

  @Autowired
  public VertexAiServiceImpl(ObjectMapper objectMapper, String projectId, String location,
      GoogleCredentials credentials) {
    this.objectMapper = objectMapper;
    this.projectId = projectId;
    this.location = location;
    this.credentials = credentials;
  }

  /**
   * Determines appropriate MIME type for an image file
   */
  private String determineMimeType(MultipartFile file) {
    String mimeType = file.getContentType();
    if (mimeType == null || mimeType.equals("application/octet-stream")) {
      String filename = file.getOriginalFilename();
      if (filename != null) {
        if (filename.toLowerCase().endsWith(".png")) {
          return "image/png";
        } else if (filename.toLowerCase().endsWith(".jpg") ||
            filename.toLowerCase().endsWith(".jpeg")) {
          return "image/jpeg";
        }
      }
      // Default to JPEG if can't determine
      return "image/jpeg";
    }
    return mimeType;
  }

  @Override
  public Map<String, Object> analyzeProductImages(MultipartFile frontImage, MultipartFile labelImage) {

    try (VertexAI vertexAI = new VertexAI.Builder()
        .setProjectId(projectId)
        .setLocation(location)
        .setCredentials(credentials)
        .build()) {

      GenerativeModel model = new GenerativeModel(MODEL_NAME, vertexAI);
      String frontMimeType = determineMimeType(frontImage);
      String labelMimeType = determineMimeType(labelImage);

      // Create prompt
      String prompt = """
          Analyze the food product, product name and its nutrition label. Provide response in this strict JSON format:
          {
            "product": {
              "name": "Product name from front image",
              "category": "Food category (e.g., snack, beverage, etc.)"
            },
            "nutrition_analysis": {
              "serving_size": "Serving size with unit",
              "nutrients": [
                {
                  "name": "Nutrient name",
                  "quantity": "Quantity with unit",
                  "daily_value": "daily value percentage with % symbol",
                  "status": "High/Moderate/Low based on DV%",
                  "health_impact": "Good/Bad/Moderate"
                }
              ],
              "primary_concerns": [
                {
                  "issue": "Primary nutritional concern",
                  "explanation": "Brief explanation of health impact",
                  "recommendations": [
                    {
                      "food": "Complementary food to add",
                      "quantity": "Recommended quantity to add",
                      "reasoning": "How this helps balance nutrition"
                    }
                  ]
                }
              ]
            }
          }

          Strictly follow these rules:
          1. Mention Quantity with units in the label
          2. Do not include any extra characters or formatting outside of the JSON object
          3. Use accurate escape sequences for any special characters
          4. Avoid including nutrients that aren't mentioned in the label
          5. For primary_concerns, focus on major nutritional imbalances
          6. For recommendations:
             - Suggest foods that can be added to complement the product
             - Focus on practical additions
             - Explain how each addition helps balance nutrition
          7. Use %DV guidelines:
             5% DV or less is considered low
             20% DV or more is considered high
             5% < DV < 20% is considered moderate
          8. For health_impact determination:
             "At least" nutrients (like fiber, protein):
               High status → Good health_impact
               Moderate status → Moderate health_impact
               Low status → Bad health_impact
             "Less than" nutrients (like sodium, saturated fat, trans fat, sugar, cholesterol):
               Low status → Good health_impact
               Moderate status → Moderate health_impact
               High status → Bad health_impact
          """;

      // Use ContentMaker and PartMaker
      Content content = ContentMaker.fromMultiModalData(
        prompt,
        PartMaker.fromMimeTypeAndData(frontMimeType, frontImage.getBytes()),
        PartMaker.fromMimeTypeAndData(labelMimeType, labelImage.getBytes())
);
      // Generate content
      GenerateContentResponse response = model.generateContent(content);

      // Extract and parse JSON from response
      String responseText = response.getCandidates(0).getContent().getParts(0).getText();
      return extractJsonFromResponse(responseText);

    } catch (Exception e) {
      logger.error("Error analyzing product images", e);
      throw new RuntimeException("Failed to analyze product images: " + e.getMessage());
    }
  }

  @Override
  public Map<String, Object> analyzeFoodImage(MultipartFile imageFile) {
    try (VertexAI vertexAI = new VertexAI.Builder()
            .setProjectId(projectId)
            .setLocation(location)
            .setCredentials(credentials)
            .build()) {

      // Initialize model
      GenerativeModel model = new GenerativeModel(MODEL_NAME, vertexAI);

      String foodMimeType = determineMimeType(imageFile);


      // Create prompt
      String prompt = """
              Analyze this food image and break down each visible food item.
              Provide response in this strict JSON format:
              {
                "plate_analysis": {
                "meal_name": "Name of the meal",
                  "items": [
                    {
                      "food_name": "Name of the food item",
                      "estimated_quantity": {
                        "amount": 0,
                        "unit": "g",
                      },
                      "nutrients_per_100g": {
                        "calories": 0,
                        "protein": {"value": 0, "unit": "g"},
                        "carbohydrates": {"value": 0, "unit": "g"},
                        "fat": {"value": 0, "unit": "g"},
                        "fiber": {"value": 0, "unit": "g"}
                      },
                      "total_nutrients": {
                        "calories": 0,
                        "protein": {"value": 0, "unit": "g"},
                        "carbohydrates": {"value": 0, "unit": "g"},
                        "fat": {"value": 0, "unit": "g"},
                        "fiber": {"value": 0, "unit": "g"}
                      },
                      "visual_cues": ["List of visual indicators used for estimation"],
                      "position": "Description of item location in the image"
                    }
                  ],
                  "total_plate_nutrients": {
                    "calories": 0,
                    "protein": {"value": 0, "unit": "g"},
                    "carbohydrates": {"value": 0, "unit": "g"},
                    "fat": {"value": 0, "unit": "g"},
                    "fiber": {"value": 0, "unit": "g"}
                  }
                }
              }
              
              Consider:
              1. Use visual cues to estimate portions (size relative to plate, height of food, etc.)
              2. Take a deeper look into the container size of food, don't consider a zoomed in container to be a big container
              3. Provide nutrients both per 100g and for estimated total quantity
              4. Prioritize using values from the USDA FoodData Central database
              5. Consider common serving sizes and preparation methods
              6. Account for density and volume-to-weight conversions
              7. Take a deeper look into the container size of food, don't consider a zoomed in container to be a big container
              
              """;

      // Use ContentMaker and PartMaker with the determined MIME type
      Content content = ContentMaker.fromMultiModalData(
              prompt,
              PartMaker.fromMimeTypeAndData(foodMimeType, imageFile.getBytes()));

      // Generate content
      GenerateContentResponse response = model.generateContent(content);

      // Extract and parse JSON from response
      String responseText = response.getCandidates(0).getContent().getParts(0).getText();
      return extractJsonFromResponse(responseText);

    } catch (Exception e) {
      logger.error("Error analyzing food image", e);
      throw new RuntimeException("Failed to analyze food image: " + e.getMessage());
    }
  }

  @Override
  public Map<String, Object> analyzeFoodDescription(String description) {
    try (VertexAI vertexAI = new VertexAI.Builder()
        .setProjectId(projectId)
        .setLocation(location)
        .setCredentials(credentials)
        .build()) {

      // Initialize model
      GenerativeModel model = new GenerativeModel(MODEL_NAME, vertexAI);

      // Create prompt
      String prompt = """
          You are a highly qualified and experienced nutritionist specializing in providing accurate nutritional information.
          Analyze these food items (always consider items in cooked form whenever applicable) and their quantities:

          %s

          Generate nutritional info for each of the mentioned food items and their respective quantities and respond using this JSON schema:
          {
            "meal_analysis": {
            "meal_name": "Name of the meal",
              "items": [
                {
                  "food_name": "Name of the food item",
                  "mentioned_quantity": {
                    "amount": 0,
                    "unit": "g",
                  },
                  "nutrients_per_100g": {
                    "calories": 0,
                    "protein": {"value": 0, "unit": "g"},
                    "carbohydrates": {"value": 0, "unit": "g"},
                    "fat": {"value": 0, "unit": "g"},
                    "fiber": {"value": 0, "unit": "g"}
                  },
                  "nutrients_in_mentioned_quantity": {
                    "calories": 0,
                    "protein": {"value": 0, "unit": "g"},
                    "carbohydrates": {"value": 0, "unit": "g"},
                    "fat": {"value": 0, "unit": "g"},
                    "fiber": {"value": 0, "unit": "g"}
                  },
                }
              ],
              "total_nutrients": {
                "calories": 0,
                "protein": {"value": 0, "unit": "g"},
                "carbohydrates": {"value": 0, "unit": "g"},
                "fat": {"value": 0, "unit": "g"},
                "fiber": {"value": 0, "unit": "g"}
              }
            }
          }
          
          
              Important considerations:
              1. Analyze the provided food items and their quantities in the meal description.
              2. Generate nutritional information for each food item and the total meal, adhering to the provided JSON schema.
              3. Prioritize using values from the USDA FoodData Central database. If data is unavailable in the USDA database, use other reputable sources like the EFSA (European Food Safety Authority) Comprehensive Food Consumption Database or national food composition databases, ensuring data reliability and scientific validity.
              4. Account for common preparation methods (e.g., boiled, fried, baked) when calculating nutritional values. If the preparation method is not specified, assume the most common method for that food item.
              5. Convert all measurements to grams (g) or milliliters (ml) as appropriate. If only volume is provided, use standard density values to convert to weight.  If a unit is not specified, assume grams (g).
              6. Consider regional variations in portion sizes when interpreting quantities. If the description is ambiguous, use standard serving sizes.
              7. Round all nutritional values to one decimal place.
              8. Account for density and volume-to-weight conversions
              
              Provide accurate nutritional data based on the most reliable food databases and scientific sources.
              """
          .formatted(description);

      // Use ContentMaker (text-only in this case)
      Content content = ContentMaker.fromString(prompt);

      // Generate content
      GenerateContentResponse response = model.generateContent(content);

      // Extract and parse JSON from response
      String responseText = response.getCandidates(0).getContent().getParts(0).getText();
      return extractJsonFromResponse(responseText);

    } catch (Exception e) {
      logger.error("Error analyzing food description", e);
      throw new RuntimeException("Failed to analyze food description: " + e.getMessage());
    }
  }

  private Map<String, Object> extractJsonFromResponse(String responseText) throws IOException {
    // Extract JSON from the response text using regex
    Pattern pattern = Pattern.compile("\\{.*\\}", Pattern.DOTALL);
    Matcher matcher = pattern.matcher(responseText);

    if (matcher.find()) {
      String jsonString = matcher.group(0);
      return objectMapper.readValue(jsonString, HashMap.class);
    } else {
      throw new IOException("No valid JSON found in the response");
    }
  }
}