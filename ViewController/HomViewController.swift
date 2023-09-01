//
//  HomViewController.swift
//  todolist_test
//
//  Created by t2023-m0064 on 2023/09/01.
//

import Foundation
import Alamofire
import UIKit




class HomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "" // 홈 화면의 타이틀 설정
        
        let imageView = UIImageView(frame: CGRect(x: 25, y: 180, width: 340, height: 210))
                let imageURL = "https://spartacodingclub.kr/css/images/scc-og.jpg"
                AF.request(imageURL)
                    .response {response in
                        switch response.result {
                        case .success(let data):
                            DispatchQueue.main.async {
                                imageView.image = UIImage(data: data!)
                                self.view.addSubview(imageView) // Add imageView to the view hierarchy after image is loaded
                            }
                        case .failure(_):
                            print("error")
                }
                
            }
//        self.view.addSubview(imageView)
        
    }

    @IBAction func didTapToDoListButton(_ sender: UIButton) {
        // "ToDoList"라는 Identifier를 가진 Segue를 실행하여 화면 전환
        performSegue(withIdentifier: "ToDoList", sender: nil)
    }
    
    
    
    @IBAction func didTapGotToDoListButton(_ sender: UIButton) {
        // "ToDoList"라는 Identifier를 가진 Segue를 실행하여 화면 전환
        performSegue(withIdentifier: "Completed!", sender: nil)
    }
}




