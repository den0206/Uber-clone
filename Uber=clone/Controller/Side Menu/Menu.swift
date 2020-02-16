//
//  Menu.swift
//  Uber=clone
//
//  Created by 酒井ゆうき on 2020/02/15.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//



import UIKit

private let reuserIdentifier = "MenuCell"

enum MenuOptions : Int, CaseIterable,CustomStringConvertible {
    case yourTrip
    case settings
    case logout
    
    var description: String {
        switch self {
        
        case .yourTrip:
            return "Your Trip"
        case .settings:
            return "Settings"
        case .logout:
            return "Log Out"

        }
    }
}

protocol MenuControllerDelegate : class {
    func didSelect(option : MenuOptions)
}

class MenuController : UITableViewController {
    
    private let user : FUser
    weak var delegate : MenuControllerDelegate?
    private lazy var menuHeader : SideMenuHeader = {
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width - 80, height: 140)
        let view = SideMenuHeader(user: user, frame: frame)
        return view
        
    }()
    
    init(user : FUser) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        return MenuOptions.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuserIdentifier, for: indexPath)
        
        guard let options = MenuOptions(rawValue: indexPath.row) else {return UITableViewCell()}
        cell.textLabel?.text = options.description
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let option = MenuOptions(rawValue: indexPath.row) else {return}
        delegate?.didSelect(option: option)
        
    }
}


