//
//  SignupViewController.swift
//  FreeTalk
//
//  Created by 설구 on 28/01/2019.
//  Copyright © 2019 sulgosu. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import FirebaseStorage

class SignupViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    let remoteconfig = RemoteConfig.remoteConfig()
    var color : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { (make) in
            make.right.top.left.equalTo(self.view)
            make.height.equalTo(20)
        }
        color = remoteconfig["splash_background"].stringValue
        statusBar.backgroundColor = UIColor(hex: color)
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imagePicker)))
        
        signupButton.backgroundColor = UIColor(hex: color)
        cancelButton.backgroundColor = UIColor(hex: color)
        
        signupButton.addTarget(self, action: #selector(signupEvent), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelEvent), for: .touchUpInside)
    }
    
    @objc func imagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        dismiss(animated: true, completion: nil)
    }
    
    @objc func signupEvent() {
        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (authResult, err) in
            let uid = authResult?.user.uid
            let image = self.imageView.image?.jpegData(compressionQuality: 0.05)
            let storageRef = Storage.storage().reference().child("userImages").child(uid!)
            storageRef.putData(image!, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Error uploading: \(error)")
                    return
                }
                self.uploadSuccess(uid!, storageRef)
            }
        }
    }

    @objc func cancelEvent() {
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func uploadSuccess(_ uid: String, _ storageRef: StorageReference) {
        print("Upload Succeeded!")
        var imageUrl : String?
        imageUrl = "init imageUrl"
        storageRef.downloadURL { (url, error) in
            if let error = error {
                print("Error getting download URL: \(error)")
                imageUrl = "error"
                return
            }
            imageUrl = url?.absoluteString ?? "no url"
            print("imageUrl = \(imageUrl ?? "is nil")")
            let values = ["userName":self.name.text!, "profileImageUrl":imageUrl]
            Database.database().reference().child("users").child(uid).setValue(values) { (error, ref) in
                if (error == nil) {
                    self.cancelEvent()
                }
            }            
        }
    }
}
