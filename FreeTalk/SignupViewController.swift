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
        print("email.text = \(email.text), password.text = \(password.text)")
        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (authResult, err) in
            let user = authResult?.user
            let uid = user?.uid
            let image = self.imageView.image!.jpegData(compressionQuality: 0.1)
            let imageRef = Storage.storage().reference().child("userImage")
            var imageURL : String?
            
            Storage.storage().reference().child("userImages").child(uid!).putData(image!, metadata: nil, completion: { (data, error) in
                    imageRef.downloadURL(completion: { (url, error) in
                    imageURL = url?.absoluteString
                })
            })
            Database.database().reference().child("users").child(uid!).setValue(["user":self.name.text!, "profileImageUrl":imageURL])
            
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

}
