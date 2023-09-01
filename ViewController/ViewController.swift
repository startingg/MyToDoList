import UIKit

// 할 일 데이터 모델
struct ToDoItem : Codable {
    var name: String
    var category: String
    var isCompleted: Bool
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let table: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    var items = [ToDoItem]() // 할 일을 저장할 배열
    var completedTasks = [Bool]() // 완료 여부를 저장할 배열
    var todoItemsByCategory = [String: [ToDoItem]]() // 카테고리별로 정리된 할 일 항목
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UserDefaults에서 할 일 목록을 불러옴
        if let savedItems = UserDefaults.standard.array(forKey: "items") as? [ToDoItem] {
            self.items = savedItems
        }
        
        // 초기 완료 여부 설정 (모두 미완료로 초기화)
        self.completedTasks = Array(repeating: false, count: self.items.count)
        
        title = "To Do List" // 네비게이션 바의 타이틀 설정
        
        view.addSubview(table) // TableView를 뷰에 추가
        table.dataSource = self // TableView의 데이터 소스를 self로 설정하여 이 클래스의 메서드들이 호출되도록 함
        table.delegate = self // TableView의 delegate를 self로 설정하여 행 선택 이벤트를 처리할 수 있도록 함
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        // 오른쪽 상단에 "+" 버튼을 추가하고, 버튼을 누르면 didTapAdd 메서드가 호출되도록 합니다.
        
        // 뷰가 로드될 때 데이터를 카테고리별로 정리
        organizeToDoItemsByCategory()
    }
    
    // 할 일 목록을 UserDefaults에 저장하는 함수
    private func saveItems() {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(items), forKey: "items")
    }
    
    // 완료 여부를 UserDefaults에 저장하는 함수
    private func saveCompletedTasks() {
        UserDefaults.standard.setValue(completedTasks, forKey: "completedTasks")
    }
    
    // 카테고리별로 할 일 항목을 정리하는 함수
    private func organizeToDoItemsByCategory() {
        todoItemsByCategory.removeAll() // 기존 데이터 초기화
        
        for item in items {
            if var categoryItems = todoItemsByCategory[item.category] {
                categoryItems.append(item)
                todoItemsByCategory[item.category] = categoryItems
            } else {
                todoItemsByCategory[item.category] = [item]
            }
        }
    }
    
    @objc private func didTapAdd() {
        let alert = UIAlertController(title: "New Item", message: "Enter new to do list item!", preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = "Enter Item..."
        }
        alert.addTextField { field in
            field.placeholder = "Category"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] (_) in
            if let nameField = alert.textFields?.first, let categoryField = alert.textFields?[1] {
                if let name = nameField.text, !name.isEmpty, let category = categoryField.text, !category.isEmpty {
                    // 새로운 할 일을 출력하고, UserDefaults를 사용하여 할 일 목록을 저장합니다.
                    print(name, category)
                    DispatchQueue.main.async {
                        let newItem = ToDoItem(name: name, category: category, isCompleted: false)
                        self?.items.append(newItem)
                        self?.completedTasks.append(false) // 새로운 할 일은 미완료 상태로 추가됩니다.
                        
                        // 배열에 할 일과 완료 여부를 추가하고, TableView를 다시 로드하여 목록을 갱신합니다.
                        self?.saveItems()
                        self?.saveCompletedTasks()
                        self?.table.reloadData()
                        
                        // 데이터를 카테고리별로 정리
                        self?.organizeToDoItemsByCategory()
                        self?.table.reloadData()
                    }
                }
            }
        }))
        
        present(alert, animated: true)
    }
    
    // 할 일 목록을 삭제하는 기능 추가
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 배열과 UserDefaults에서 해당 위치의 할 일과 완료 여부를 삭제합니다.
            items.remove(at: indexPath.row)
            completedTasks.remove(at: indexPath.row)
            saveItems()
            saveCompletedTasks()
            
            // TableView에서 해당 행을 삭제합니다.
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // 데이터를 카테고리별로 정리
            organizeToDoItemsByCategory()
            tableView.reloadData()
        }
    }
    
    // TableView 데이터 소스 및 델리게이트 메서드 수정
    func numberOfSections(in tableView: UITableView) -> Int {
        return todoItemsByCategory.keys.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let categories = Array(todoItemsByCategory.keys)
        return categories[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let categories = Array(todoItemsByCategory.keys)
        let category = categories[section]
        return todoItemsByCategory[category]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let categories = Array(todoItemsByCategory.keys)
        let category = categories[indexPath.section]
        if let itemsInCategory = todoItemsByCategory[category] {
            let item = itemsInCategory[indexPath.row]
            cell.textLabel?.text = item.name
            
            if item.isCompleted {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        
        return cell
    }
    
    // 특정 행을 선택했을 때 완료 여부를 토글하고, 체크박스를 갱신하는 함수입니다.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let categories = Array(todoItemsByCategory.keys)
        let category = categories[indexPath.section]
        if let itemsInCategory = todoItemsByCategory[category] {
            var item = itemsInCategory[indexPath]
        }}}


