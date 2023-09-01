//
//  SecViewController.swift
//  todolist_test
//
//  Created by t2023-m0064 on 2023/09/01.
//

import Foundation
import UIKit


class SecViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let table: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "completedCell")
        return table
    }()

    
    var completedItems = [String]() // 완료된 할 일을 저장할 배열
    var completedTasks = [Bool]() // 완료 여부를 저장할 배열

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Completed"// 화면의 타이틀 설정

        
        view.addSubview(table) // TableView를 뷰에 추가
        table.dataSource = self // TableView의 데이터 소스를 self로 설정하여 이 클래스의 메서드들이 호출되도록 함
        table.delegate = self // TableView의 delegate를 self로 설정하여 행 선택 이벤트를 처리할 수 있도록 함
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 이 화면이 나타날 때마다 완료된 할 일 목록을 가져옴
        loadCompletedItems()
        // TableView를 다시 로드하여 완료된 할 일 목록을 갱신합니다.
        table.reloadData()
    }

    // 완료된 할 일 목록을 가져오는 함수
    private func loadCompletedItems() {
        // UserDefaults에서 할 일 목록을 불러옴
        let items = UserDefaults.standard.stringArray(forKey: "items") ?? []
        // UserDefaults에서 완료 여부 목록을 불러옴
        let completedTasks = UserDefaults.standard.array(forKey: "completedTasks") as? [Bool] ?? []

        // 완료된 할 일 목록을 가져옴
        let completedItems = zip(items, completedTasks).filter { $1 }.map { $0.0 }

        // 완료된 할 일 목록을 업데이트합니다.
        self.completedItems = completedItems
        self.completedTasks = Array(repeating: true, count: completedItems.count)
    }

    // TableView가 레이아웃될 때 TableView의 프레임을 뷰의 전체 크기로 설정합니다.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        table.frame = view.bounds
    }

    // TableView의 행 개수를 반환합니다.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return completedItems.count
    }

    // 각 행에 해당하는 셀을 반환합니다.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "completedCell", for: indexPath)

        // 해당 인덱스의 완료된 할 일을 셀의 텍스트로 표시합니다.
        cell.textLabel?.text = completedItems[indexPath.row]

        // 완료된 항목이므로 체크마크를 표시합니다.
        cell.accessoryType = .checkmark

        return cell
    }
}
