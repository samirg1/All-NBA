//
//  UIViewController-sgup0027.swift
//  FIT3178-W01-Lab
//
//  Created by Samir Gupta on 1/3/22.
//

import Foundation
import UIKit

// Alerts, messages and action sheets
extension UIViewController {
    
    //              Title
    //             Message
    //            <Dismiss>
    func displayMessage_sgup0027(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    //              Title
    //             Message
    //       <Cancel>  <Positive>
    func showSimpleAlert_sgup0027(title: String, message: String, positiveTitle: String, positiveFunc: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: positiveTitle,style:.default, handler: {(_: UIAlertAction!) in positiveFunc()}))
        self.present(alert, animated: true, completion: nil)
    }
    
    //            Title
    //           Message
    //          <Default1>
    //          <Default2>
    //         <!Negaitve!>
    //           <Dismiss>
    func showSimpleActionSheet_sgup0027(title: String, message: String, default1_title: String, default1_fun: @escaping () -> Void, default2_title: String, default2_fun: @escaping () -> Void, negative_title: String, negative_fun: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: default1_title, style: .default, handler: { (_) in default1_fun()}))
        alert.addAction(UIAlertAction(title: default2_title, style: .default, handler: { (_) in
            default2_fun()}))
        alert.addAction(UIAlertAction(title: negative_title, style: .destructive, handler: { (_) in negative_fun()}))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //             Title
    //            Message
    //       <Cancel>  <!Neg!>
    func showAlertDestructive_sgup0027(title: String, message: String, neg_title: String, neg_func: @escaping () -> Void){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: neg_title, style: .destructive, handler: {(_: UIAlertAction!) in
            neg_func()}))
        self.present(alert, animated: true, completion: nil)
    }
    
    //              Title
    //          [Placeholder]
    //        <Cancel>   <Confirm>
    func showAlertText_sgup0027(title: String, confirm: String, placeholder: String, pos_fun: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: confirm, style: .default) { (_) in
            if let txtField = alertController.textFields?.first, let text = txtField.text {
               pos_fun(text)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addTextField { (textField) in
            textField.placeholder = placeholder
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
