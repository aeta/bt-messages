/**
 Copyright 2016 Aeta
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

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
