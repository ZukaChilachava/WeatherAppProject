//
//  ErrorView.swift
//  WeatherAppProject
//
//  Created by Zuka Chilachava on 25.01.22.
//

import UIKit

protocol ReloadDelegate: AnyObject{
    func reloadInfo()
}

class ErrorView: UIView{
    
    @IBOutlet var label: UILabel!
    @IBOutlet var reload: UIButton!
    @IBOutlet var contentView: UIView!
    
    var relDelegate: ReloadDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    
    func commonInit(){
        let bundle = Bundle(for: ErrorView.self)
        bundle.loadNibNamed("ErrorView", owner: self, options: nil)
        
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.backgroundColor = .clear
        
        addSubview(contentView)
    }
    
    func setDelegate(delegate: ReloadDelegate){
        relDelegate = delegate
        reload.layer.cornerRadius = 4
    }
    
    func setInformation(text: String){
        label.text = text
        
    }
    
    @IBAction func reloadClicked(){
        relDelegate?.reloadInfo()
    }
    
}

