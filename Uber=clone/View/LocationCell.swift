//
//  locationCell.swift
//  Uber=clone
//
//  Created by 酒井ゆうき on 2020/02/08.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit
import MapKit

class LocationCell: UITableViewCell {
    
    var placeMark : MKPlacemark? {
        didSet {
            titleLable.text = placeMark?.name
            addresslabel.text = placeMark?.address
        }
    }
    
    var type : LocationType? {
        didSet {
            titleLable.text = type?.description
            addresslabel.text = type?.subtitle
        }
    }
    
    //MARK: Parts
    
    var titleLable : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
//        label.text = "123"
        return label
    }()
    
    private var addresslabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
//        label.text = "123 adress"
        return label
    }()
    
    //MARK: Life Cycle(init)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        let stackView = UIStackView(arrangedSubviews: [titleLable, addresslabel])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        
        addSubview(stackView)
        stackView.centerY(inView: self, leftAnchor:  leftAnchor, paddingLeft: 12)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

