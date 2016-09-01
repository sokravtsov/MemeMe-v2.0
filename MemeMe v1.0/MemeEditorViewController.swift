//
//  MemeEditorViewController.swift
//  MemeMe v1.0
//
//  Created by Sergey Kravtsov on 22.08.16.
//  Copyright © 2016 Sergey Kravtsov. All rights reserved.
//

import UIKit
import Foundation

protocol MemeEditorViewControllerDelegate: class {
    func dismissMemeEditorViewController()
}

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    weak var delegate: MemeEditorViewControllerDelegate?
    
    @IBOutlet var memeView: UIView!
    //@IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setToInitialState()
        topText.delegate = self
        bottomText.delegate = self
    }

    @IBAction func cancelAndReturnToOriginalView(sender: AnyObject) {
        setToInitialState()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setToInitialState() {
        setTextField(topText, placeHolderText: "TOP")
        setTextField(bottomText, placeHolderText: "BOTTOM")
        shareButton.enabled = false
        memeView.backgroundColor = UIColor.blackColor()
        image.image = nil
    }

    // MARK: Pick image
    // album button
    @IBAction func pickAnImageFromAlbum(sender: UIBarButtonItem) {
        presentImagePickerView(.PhotoLibrary)
    }
    
    // camera button
    @IBAction func pickAnImageFromCamera(sender: UIBarButtonItem) {
        presentImagePickerView(.Camera)
    }
    
    // present image picker view
    func presentImagePickerView(sourceType: UIImagePickerControllerSourceType) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        presentViewController(imagePickerController, animated: true, completion: nil)
    }

    // dimiss image picker view when user select a still image
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // display the original image to UIImageView box
        let userSelectedImageVal = info[UIImagePickerControllerOriginalImage] as! UIImage
        image.image = userSelectedImageVal
        image.contentMode = .ScaleAspectFit
        shareButton.enabled = true
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // dimiss image picker view when user hit cancel
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: TextAttributes
    func setTextField(textField: UITextField, placeHolderText: String) {
        
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor .blackColor(),
            NSForegroundColorAttributeName : UIColor .whiteColor(),
            NSFontAttributeName : UIFont(name: "Impact", size: 40)!,
            NSStrokeWidthAttributeName : -3.0
        ]
        
        textField.text = placeHolderText
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .Center
        textField.delegate = self
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if ((textField.text == "TOP") || (textField.text == "BOTTOM"))
        {
            textField.text = ""
        }
    }

    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text == "" {
            if textField == topText {
                textField.text = "TOP"
            } else if textField == bottomText {
                textField.text = "BOTTOM"
            }
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        subscribeKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    
    // MARK: Keyboard
    func keyboardWillShow(notification: NSNotification) {
        if bottomText.isFirstResponder() {
            view.frame.origin.y =  getKeyboardHeight(notification) * -1
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if bottomText.isFirstResponder() {
            view.frame.origin.y = 0
        }
    }
    
    // get keyboard height
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    // observe keyboard notifications
    func subscribeKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // remove keyboard notifications
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    @IBAction func share(sender: AnyObject) {
        let image = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        presentViewController(controller, animated: true, completion: nil)
        controller.completionWithItemsHandler = {
            (activityType, completed: Bool, returnedItems: [AnyObject]?, error: NSError? ) in
            if (!completed) {
                return
            } else {
                self.save(image)
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // create Meme object
    func save(memedImage: UIImage) {
        
        var meme = Meme(topText: topText.text!, bottomText: bottomText.text!, image: image.image!, memedImage: generateMemedImage())
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).memes.append(meme)
    
    }
    
    func generateMemedImage() -> UIImage {
       
        //navBar.hidden = true
        toolBar.hidden = true
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //navBar.hidden = false
        toolBar.hidden = false
        
        return memedImage
    }
}