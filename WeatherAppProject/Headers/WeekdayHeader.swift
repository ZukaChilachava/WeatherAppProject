//
//  WeekdayHeader.swift
//  WeatherAppProject
//
//  Created by Zuka Chilachava on 25.01.22.
//

import UIKit

protocol ExpandDelegate{
    func clickExpandCollapse(section: Int)
}

struct HeaderModel{
    var text: String!
    var section: Int!
    var isExpanded: Bool!
    var expandDelegate: ExpandDelegate!
}

class WeekdayHeader: UITableViewHeaderFooterView {
    
    @IBOutlet var label: UILabel!
    @IBOutlet var expandButton: UIButton!
    
    var headerModel: HeaderModel?
    
    func configure(model: HeaderModel){
        label.text = model.text
        headerModel = model

        expandButton.transform = CGAffineTransform.identity
        if headerModel!.isExpanded == false{
            expandButton.transform = expandButton.transform.rotated(by: CGFloat.pi / 2)
        }
    }
    
    @IBAction func expandCollapse(){
        self.expandButton.isUserInteractionEnabled = false

        if headerModel!.isExpanded{
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
                self.expandButton.transform = self.expandButton.transform.rotated(by: CGFloat.pi / 2)
            }, completion: {_ in self.expandButton.isUserInteractionEnabled = true})
        }else{
            UIView.animate(withDuration: 0.25, delay: 0, options:.curveEaseIn, animations: {
                self.expandButton.transform = self.expandButton.transform.rotated(by: -CGFloat.pi / 2)
            }, completion: {_ in self.expandButton.isUserInteractionEnabled = true})
        }
        
        headerModel!.isExpanded.toggle()
        
        headerModel!.expandDelegate?.clickExpandCollapse(section: headerModel!.section)
    }
    
}
