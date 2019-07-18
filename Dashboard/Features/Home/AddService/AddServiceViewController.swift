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

enum Mode {
    case create
    case edit
}

class AddServiceViewController: UIViewController {
    @IBOutlet weak var serviceUrlTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var logoImageContainer: UIStackView!
    @IBOutlet weak var logoImageView: UIImageView!
    
    public var serviceDelegate: ServiceDelegate?
    public var serviceToEdit: ServiceModel?
    
    var mode: Mode = .create
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped(_:)))
    private var database: ServiceDatabase = PersistenceClient.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        serviceUrlTextField.delegate = self
        nameTextField.delegate = self
        setupNavigationBar()
        setupView()
        addGestureRecognizers()
    }
    
    private func setupNavigationBar() {
        guard let navigationController = navigationController else {
            return
        }
        
        navigationController.navigationBar.topItem?.title = mode == .create ? "Add Service" : "Edit Service"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped(_:)))
        updateDoneButton()
    }
    
    private func setupView() {
        serviceUrlTextField.text = serviceToEdit?.url
        serviceUrlTextField.textColor = .textColor
        
        nameTextField.text = serviceToEdit?.name
        nameTextField.textColor = .textColor
        
        logoImageView.image = serviceToEdit?.image ?? UIImage(named: "missing-image")!
        logoImageView.layer.cornerRadius = 15
    }
    
    private func addGestureRecognizers() {
        // Note: even though these 2 gesture recognizers are synonymous, they must be unique
        logoImageContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editImage(_:))))
    }
    
    private func updateDoneButton() {
        let bothTextFieldsNContainText = serviceUrlTextField.text?.count ?? 0 > 0 && nameTextField.text?.count ?? 0 > 0
        
        if mode == .edit || bothTextFieldsNContainText {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped(_:)))
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    @IBAction func urlTextFieldEditingDidEnd(_ sender: UITextField) {
        guard let url = sender.text else {
            return
        }
        
        updateDoneButton()
        
        logoImageView.image = nil
        
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = .loadingIndicatorColor
        activityIndicator.center = logoImageView.center
        logoImageView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        NetworkService.fetchFavicon(for: StringUtils.convertString(toHttpsUrlString: url)).call { [weak self] result in
            do {
                let favicon = try result.value()
                self?.logoImageView.image = favicon
                
                // If an image is more than twice as wide as it is tall, ensure it doesn't get
                // clipped to oblivion
                let shouldScaleImage = favicon.size.width / favicon.size.height > 1.5 
                self?.logoImageView.contentMode = shouldScaleImage ? .scaleAspectFit : .scaleAspectFill
            } catch {
                self?.logoImageView.image = UIImage(named: "missing-image")!
            }
            
            activityIndicator.removeFromSuperview()
        }
    }
    
    @IBAction func nameTextFieldEditingChanged(_ sender: UITextField) {
        updateDoneButton()
    }
    
    
    @objc func editImage(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        
        present(imagePickerController, animated: true)
    }
    
    @objc func cancelButtonTapped(_ sender: UIBarButtonItem) {
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
            database.edit(service: editedService,name: name, url: serviceUrl, image: image)
            serviceDelegate?.onServiceChanged(service: editedService)
        } else {
            database.createService(name: name, url: serviceUrl, image: image) { [weak self] result in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    do {
                        let newService = try result.get()
                        self.serviceDelegate?.onNewServiceCreated(newService: newService)
                    } catch {
                        self.show(error: error)
                    }
                }
            }
        }

        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextField Delegate
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
    // Empty stub to conform to UIImagePickerControllerDelegate
}
