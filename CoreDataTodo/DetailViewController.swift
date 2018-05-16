//
//  DetailViewController.swift
//  CoreDataTodo
//
//  Created by Brian Vo on 2018-05-16.
//  Copyright © 2018 Brian Vo. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let detailLabel = detailDescriptionLabel, let priorityLabel = priorityLabel, let titleLabel = titleLabel {
                
                detailLabel.text = detail.todoDescription?.description
                priorityLabel.text = detail.priorityNumber.description
                titleLabel.text = detail.title?.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: ToDo? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

