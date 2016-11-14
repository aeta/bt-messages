//
//  PhotoDetail.swift
//  bt-messages
//
//  Created by Alan Chu on 11/13/16.
//  Copyright © 2016 Team Auxiliary. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController {
    var image: UIImage!
    @IBOutlet weak var imageHolder: UIImageView! {
        didSet {
            imageHolder.image = image
        }
    }
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBAction func closeButtonDidPress(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareButtonDidPress(_ sender: AnyObject) {
        let shareVC: UIActivityViewController = UIActivityViewController(activityItems: [self.imageHolder.image!], applicationActivities: nil)
        self.present(shareVC, animated: true, completion: nil)
    }
    
    @IBAction func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }

    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
}

// MARK: - UIScrollViewDelegate methods
extension PhotoDetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageHolder
    }
}
