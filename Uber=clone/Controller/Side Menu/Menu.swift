//
//  Menu.swift
//  Uber=clone
//
//  Created by 酒井ゆうき on 2020/02/15.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//



import UIKit

private let reuserIdentifier = "MenuCell"

class MenuController : UITableViewController {
    
    private lazy var menuHeader : SideMenuHeader = {
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width - 80, height: 140)
        let view = SideMenuHeader(frame: frame)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configuretableView()
        
    }
    
    func configuretableView() {
        
        view.backgroundColor = .white
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        
        tableView.isScrollEnabled = false
        tableView.rowHeight = 60
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuserIdentifier)
        
        // header View
        tableView.tableHeaderView = menuHeader
        

    }
}

// table View Delegate

extension MenuController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuserIdentifier, for: indexPath)
        cell.textLabel?.text = "Menu"
        return cell
    }
}


