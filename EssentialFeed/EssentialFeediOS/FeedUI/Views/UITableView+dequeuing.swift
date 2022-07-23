//
//  UITableView+dequeuing.swift
//  EssentialFeediOS
//
//  Created by AmritPandey on 23/07/22.
//

import UIKit

extension UITableView {
    func deqeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
} 
