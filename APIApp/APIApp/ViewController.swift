import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
//    var meals: [Meal] = []
    var meals = [Meal]()
    
    //    var selectedStrMeal:String?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        meals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TableViewOutlet.dequeueReusableCell(withIdentifier: "Cell", for:indexPath)
        cell.textLabel?.text = meals[indexPath.row].strMeal
//        selectedMealId = meals[indexPath.row].idMeal
        return cell
    }
    
    
    @IBOutlet weak var TableViewOutlet: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        TableViewOutlet.delegate = self
        TableViewOutlet.dataSource = self
        navigationItem.hidesBackButton = true
        fetchMeals(url: "https://themealdb.com/api/json/v1/1/filter.php?c=Dessert") { result in
            switch result {
            case .success(let fetchedMeals):
                self.meals = fetchedMeals
                DispatchQueue.main.async {
//                    print("Fetched Meals: \(self.meals)")
                    self.TableViewOutlet.reloadData()
                }
            case .failure(let error):
                print("Error fetching and decoding JSON: \(error)")
            }
        }
        
        
        
    }
    
    func fetchMeals(url: String, completion: @escaping (Result<[Meal], Error>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let mealsResponse = try JSONDecoder().decode(MealsResponse.self, from: data)
                let meals = mealsResponse.meals
                self.meals = meals
                DispatchQueue.main.async {
                    //                        print("Fetched Meals: \(self.meals)")
                    self.TableViewOutlet.reloadData()
                }
                completion(.success(meals))
            } catch {
                completion(.failure(error))
            }
        }
        dataTask.resume()
    }
    
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "DessertDescription" {
                    if let destination = segue.destination as? ResultViewController,
                       let selectedIndexPath = TableViewOutlet.indexPathForSelectedRow {
                        let selectedMealId = meals[selectedIndexPath.row].idMeal
                        destination.receivedMealId = selectedMealId
                    }
                }
        }
      
}
