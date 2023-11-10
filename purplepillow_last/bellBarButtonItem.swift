import UIKit

class bellBarButtonItem: UIBarButtonItem {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Create a custom UIButton to use as the UIBarButtonItem's view
        let customButton = UIButton(type: .custom)
        customButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30) // Adjust the frame size as needed
        
        // Set the custom button's appearance, e.g., add an image
        customButton.setImage(UIImage(named: "your_bell_icon"), for: .normal)
        customButton.contentMode = .scaleAspectFit // To maintain the aspect ratio
        

        // Create a custom view and set the customButton as its subview
        let customView = UIView(frame: customButton.frame)
        customView.addSubview(customButton)
        
        // Set the custom view as the UIBarButtonItem's view
        self.customView = customView
    }
    
}
