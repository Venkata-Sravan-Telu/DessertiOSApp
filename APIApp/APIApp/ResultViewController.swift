import UIKit

class ResultViewController: UIViewController {
    var receivedMealId:String?
//    var receivedStrMeal:String?
    
    @IBOutlet weak var strMealOutlet: UILabel!
    
    @IBOutlet weak var IngredientsOutlet: UITextView!
    
    @IBOutlet weak var InstructionsOutlet: UITextView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if let mealId = receivedMealId {
                fetchMealDetails(for: mealId)
            } else {
                // Handle the case where receivedMealId is nil (optional value not set)
                print("receivedMealId is nil")
            }
    }
    
    func fetchMealDetails(for mealId: String) {
            let apiUrl = "https://themealdb.com/api/json/v1/1/lookup.php?i=\(mealId)"
//            print(apiUrl)
            
            URLSession.shared.dataTask(with: URL(string: apiUrl)!) { [weak self] data, response, error in
                guard let data = data, error == nil else {
                    print("Error fetching meal details: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let mealResponse = try decoder.decode(MealDetails.self, from: data)
                    DispatchQueue.main.async {
//                        print(mealResponse)
                        self?.updateUI(with: mealResponse.meals.first)
                    }
                } catch {
                    print("Error decoding meal details: \(error.localizedDescription)")
                }
            }.resume()
        }

    func updateUI(with meal: MealDetails.Meal?) {
        if let meal = meal {
            strMealOutlet.text = meal.value(for: "strMeal") as? String
            InstructionsOutlet.text = meal.value(for: "strInstructions") as? String

            var ingredientsList: [String] = []

            for i in 1...20 {
                if let ingredient = meal.value(for: "strIngredient\(i)") as? String,
                   !ingredient.isEmpty,
                   let measurement = meal.value(for: "strMeasure\(i)") as? String,
                   !measurement.isEmpty {
                    let ingredientString = "\(ingredient): \(measurement)"
                    ingredientsList.append(ingredientString)
                }
            }

            let ingredients = ingredientsList.joined(separator: "\n")
            IngredientsOutlet.text = ingredients
        }
    }



    
}
