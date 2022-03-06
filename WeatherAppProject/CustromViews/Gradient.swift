//
//  Gradient.swift
//  WeatherAppProject
//
//  Created by Zuka Chilachava on 24.01.22.
//

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
        
        let firstColor = UIColor(red: 167.0/255.0, green: 126.0/255.0, blue: 242.0/255.0, alpha: 1)
        let secondColor = UIColor(red: 44.0/255.0, green: 83.0/255.0, blue: 100.0/255.0, alpha: 1)
        

        theLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        theLayer.locations = [0.0, 1.0]
        theLayer.frame = self.bounds
    }

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
}
