//
//  SecondaryWeatherInfo.swift
//  WeatherAppProject
//
//  Created by Zuka Chilachava on 24.01.22.
//

import UIKit

class SecondaryWeatherInfo: UIView{
    
    @IBOutlet var label: UILabel!
    @IBOutlet var image: UIImageView!
    @IBOutlet var contentView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    
    func commonInit(){
        let bundle = Bundle(for: SecondaryWeatherInfo.self)
        bundle.loadNibNamed("SecondaryWeatherInfo", owner: self, options: nil)
        
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.backgroundColor = .clear
        
        addSubview(contentView)
    }
    
    func setInformation(text: String, info: String){
        label.text = text
        
        if info == "humidity"{
            image.image = UIImage(named: "drop.pdf")
        }else if info == "cloud"{
            image.image = UIImage(named: "raining.pdf")
        }else if info == "pressure"{
            image.image = UIImage(named: "celsius.pdf")
        }else if info == "wind"{
            image.image = UIImage(systemName: "wind")
        }else if info == "direction"{
            image.image = UIImage(named: "compass.pdf")
        }
    }
    
}
