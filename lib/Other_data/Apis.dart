import 'package:flutter/material.dart';
import 'package:unige_app/screens/ApplicationData.dart';

class Apis extends StatelessWidget {
  static String baseUrl = "https://unige-geneva.herokuapp.com/";

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  static String userExists(String mobile) {
    return "${baseUrl}userExists?mobile=$mobile";
  }

  static String createUser(String name, String mobile, String email) {
    return "${baseUrl}createUser?name=$name&mobile=$mobile&email=$email";
  }

  static String getUser(String mobile) {
    return "${baseUrl}getUser?mobile=$mobile";
  }

  static String getAllProducts() {
    return "${baseUrl}getAllProducts";
  }

  static String getFeaturesList(String productSelected) {
    return "${baseUrl}getFeatures?prodName=$productSelected";
  }

  static String registerProduct(String productName) {
    String value =
        "${baseUrl}registerProduct?userMobile=${ApplicationData.mobile}&productName=$productName";

    return value;
  }

  static String getUserProducts(String mobile) {
    return "${baseUrl}getUserProducts?userMobile=$mobile";
  }

  static submitFeedback(String mobile, String myProductSelected) {
    return "${baseUrl}submitFeedback?mobile=$mobile&productSelected=$myProductSelected";
  }

  static String ratingsArray() {
    return "${baseUrl}getRatingsArray";
  }

  static String getDefectSurveys(String mobile, String product) {
    return "${baseUrl}generateAndGetDefectSurveys?userMobile=$mobile&product=$product";
  }

  static String deleteProductFromUser(product) {
    return "${baseUrl}deleteUserProduct?userMobile=${ApplicationData.mobile}&userProduct=" +
        product;
  }

  static String getAllSurveys() {
    return "${baseUrl}getAllCategories";
  }

  static String setNextSurveyForFeedback(String mobile, String? productSelected,
      currentSurvey, bool isReplacementSurvey) {
    return "${baseUrl}setNextSurveyForFeedback?userMobile=$mobile"
        "&productName=$productSelected&surveyId=$currentSurvey"
        "&activateReplacementSurvey=$isReplacementSurvey";
  }
}
