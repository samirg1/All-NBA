//
//  UIViewControllerExtension.swift
//
//  Created by Samir Gupta on 1/3/22.
//

import Foundation
import UIKit

public extension UIViewController {
    
    /// Displays a simple message to the user with a single 'Dismiss' button.
    ///
    /// - Parameters:
    ///     - title: The title of the message.
    ///     - message: The message to display.
    ///
    /// Setup is as follows:
    ///
    ///              Title
    ///             Message
    ///            <Dismiss>
    func displaySimpleMessage(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: "dismiss"), style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func displayOption(title: String, message: String, optionName: String, callback: @escaping (UIAlertAction) -> Void){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: optionName, style: .default, handler: callback))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: "dismiss"), style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
