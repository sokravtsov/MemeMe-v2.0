//
//  MemeDetailViewController.swift
//  MemeMe v1.0
//
//  Created by Sergey Kravtsov on 01.09.16.
//  Copyright © 2016 Sergey Kravtsov. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
    
    var meme: Meme?
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        imageView.image = meme?.memedImage
        
        tabBarController?.tabBar.hidden = true
    }
    
}