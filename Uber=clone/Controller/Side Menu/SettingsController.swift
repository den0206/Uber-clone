//
//  SettingsController.swift
//  Uber=clone
//
//  Created by 酒井ゆうき on 2020/02/16.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit

private let reuserIdentifier = "locationCell"

enum LocationType : Int, CaseIterable, CustomStringConvertible {
    case home
    case work
    
    var description: String {
        switch self {
            
        case .home:
            return "Home"
        case .work:
            return "Work"
            
        }
    }
    
    var subtitle : String {
        switch self {
            
        case .home:
            return "Add"
        case .work:
            return "Word"
            
        }
    }
    
}

class SettingViewController: UITableViewController {
    
    private let user : FUser
    
    private lazy var infoHeader : UserInfoHeader = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
        let view = UserInfoHeader(user: user, frame: frame)
        
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
        
        configureTableView()
        configureNavigationController()
    }
    
    func configureTableView() {
        tableView.rowHeight = 60
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuserIdentifier)
        tableView.backgroundColor = .white
        tableView.tableHeaderView = infoHeader
    }
    
    func configureNavigationController() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .black
        navigationItem.title = "Setting"
        navigationController?.navigationBar.barTintColor = .backGroundColor
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_highlight_off_white_2x").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(dismissSetting))
        
    }
    
    //MARK: - Selector
    
    @objc func dismissSetting() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - TableView Delegate

extension SettingViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationType.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuserIdentifier, for: indexPath) as! LocationCell
        
        guard let type = LocationType(rawValue: indexPath.row) else {return cell }
        cell.type = type
        
        return cell
    }
    
    
    // Header View
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .black
        
        
        let title = UILabel()
        title.text = "Favorite"
        title.textColor = .white
        title.font = UIFont.systemFont(ofSize: 16)
        
        view.addSubview(title)
        title.centerY(inView: view, leftAnchor: view.leftAnchor, paddingLeft: 16 )
        
        return view
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let type = LocationType(rawValue: indexPath.row) else {return}
        print(type.description)
        
        
    }
    
    
}
