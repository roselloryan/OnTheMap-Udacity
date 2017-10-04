import UIKit

class GradientView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        guard let theLayer = self.layer as? CAGradientLayer else {
            return;
        }
        
        theLayer.colors = [UIColor(red: 255/255, green: 150/255, blue: 0, alpha: 1).cgColor, UIColor(red: 255/255, green: 95/255, blue: 0, alpha: 1).cgColor]
        theLayer.frame = self.bounds
    }

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

}
