//
//  AddServiceViewController.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 2/19/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import UIKit
import CoreData

protocol NewServiceDelegate {
    func onSaved(newService: ServiceModel)
}

class AddServiceViewController: UIViewController {
    @IBOutlet weak var serviceUrlTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var logoImageView: UIImageView!
    
    public var newServiceDelegate: NewServiceDelegate?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var persistenceClient = PersistenceClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        serviceUrlTextField.delegate = self
        nameTextField.delegate = self
    }
    
    @IBAction func urlTextFieldEditingDidEnd(_ sender: UITextField) {
        guard let url = sender.text else {
            return
        }
        
        NetworkService.fetchFavicon(for: StringUtils.convertString(toHttpsUrl: url)).call { [weak self] result in
            do {
                let favicon = try result.value()
                self?.logoImageView.image = favicon
                
                // If an image is more than twice as wide as it is tall, ensure it doesn't get
                // clipped to oblivion
                let shouldScaleImage = favicon.size.width / favicon.size.height > 1.5 
                self?.logoImageView.contentMode = shouldScaleImage ? .scaleAspectFit : .scaleAspectFill
            } catch {
                self?.logoImageView.image = UIImage(named: "missing-image")
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        guard let name = nameTextField.text,
            let url = serviceUrlTextField.text,
            let image = logoImageView.image else {
            // TODO handle error
            return
        }
        
        // TODO save image and use url
        let imageUrl = ""
        
        let service = NSEntityDescription.insertNewObject(forEntityName: ServiceModel.entityName, into: appDelegate.persistentContainer.viewContext) as! ServiceModel
        service.populate(name: name, url: url, imageUrl: imageUrl)
        
//        persistenceClient.save(newService: service)
        newServiceDelegate?.onSaved(newService: service)
        
        dismiss(animated: true, completion: nil)
    }
}

extension AddServiceViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Search for next first responder
        if let nextTextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return false
    }
}
