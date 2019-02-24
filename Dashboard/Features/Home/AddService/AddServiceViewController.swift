//
//  AddServiceViewController.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 2/19/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import UIKit
import CoreData

protocol ServiceDelegate {
    func onNewServiceCreated(newService: ServiceModel)
    func onServiceChanged(service: ServiceModel)
}

class AddServiceViewController: UIViewController {
    @IBOutlet weak var serviceUrlTextField: UITextField!
    @IBOutlet weak var logoImageContainer: UIStackView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var editImageButton: UIButton!
    
    public var serviceDelegate: ServiceDelegate?
    public var serviceToEdit: ServiceModel?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var database: Database = PersistenceClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        serviceUrlTextField.delegate = self
        nameTextField.delegate = self
        addGestureRecognizers() 
        populateView()
    }
    
    private func addGestureRecognizers() {
    let editImageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(editImageButtonTapped(_:)))
        logoImageContainer.addGestureRecognizer(editImageTapGestureRecognizer)
        editImageButton.addGestureRecognizer(editImageTapGestureRecognizer)
    }
    
    private func populateView() {
        guard let serviceToEdit = serviceToEdit else {
            return
        }
        
        serviceUrlTextField.text = serviceToEdit.url
        nameTextField.text = serviceToEdit.name
        logoImageView.image = serviceToEdit.image
    }
    
    @IBAction func urlTextFieldEditingDidEnd(_ sender: UITextField) {
        guard let url = sender.text else {
            return
        }
        
        NetworkService.fetchFavicon(for: StringUtils.convertString(toHttpsUrlString: url)).call { [weak self] result in
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
    
    @objc func editImageButtonTapped(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        
        present(imagePickerController, animated: true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func doneButtonTapped(_ sender: UIBarButtonItem) {
        guard let name = nameTextField.text,
            let url = serviceUrlTextField.text,
            let image = logoImageView.image else {
            return
        }
        
        let serviceUrl = StringUtils.convertString(toHttpsUrlString: url)
        
        if let editedService = serviceToEdit {
//            database.renameFile(from: editedService.name, to: name)
            editedService.populate(name: name, url: serviceUrl, image: image)
            serviceDelegate?.onServiceChanged(service: editedService)
        } else {
            let service = NSEntityDescription.insertNewObject(forEntityName: ServiceModel.entityName, into: appDelegate.persistentContainer.viewContext) as! ServiceModel
            
            service.populate(name: name, url: serviceUrl, image: image)
            serviceDelegate?.onNewServiceCreated(newService: service)
        }
        database.save(image: image, named: name)

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

// MARK: - ImagePickerController Delegate
extension AddServiceViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            logoImageView.contentMode = .scaleAspectFit
            logoImageView.image = pickedImage
        }
        
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

extension AddServiceViewController: UINavigationControllerDelegate {
    
}
