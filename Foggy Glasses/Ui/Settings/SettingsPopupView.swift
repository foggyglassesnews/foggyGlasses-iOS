//
//  SettingsPopupView.swift
//  Foggy Glasses
//
//  Created by Alec Barton on 7/13/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit

protocol SettingsPopupDelegate: AnyObject {
    func closeCancel()
    func closeSave(sentCategories:[String], sentFrequency:Int)
}


//popup menu to change group curation settings
class SettingPopUpView:UIView{
    weak var delegate:SettingsPopupDelegate?
    
    //columns of category buttons
    static let COLUMNNUMBER = 3
    static let BUTTONHEIGHT = 32
    //number of categories that can be selected
    static let MAXSELECTIONS = 3
    
    var viewWidth = CGFloat(0)
    
    //temporarily store selected setttings here
    var selectedCategories:[String]=[]
    var selectedFrequency:Int = 3
    
    //categories of articles a user can select
    //categories can be added or substracted from this array and the popup will scaleas needed
    static let surveyCategories: [String] = {
        return  [
            "US News",
            "World News",
            "Technology",
            "Health",
            "Entertainment",
            "Sports",
            "Science",
            "Finance",
            "Crypto",
            "Gaming",
            "Trending",
        ]
    }()
    
    //initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewWidth = (frame.width * 0.85)
        self.translatesAutoresizingMaskIntoConstraints = false
        loadPreferences()
        setupLayout()
        setupButtons()
    }
    
    func loadPreferences(preCategories:[String] = [], preFrequency:Int = 3){
        selectedCategories = preCategories
        selectedFrequency = preFrequency
        updateButtons()
    }
    
    let buttonArray:[UIButton] = {
        var buttonArray = [UIButton]()
        for i in surveyCategories {
            let button = UIButton()
            button.setTitle(i, for: .normal)
            button.titleLabel!.font = UIFont.boldSystemFont(ofSize: 12.0)
            button.setTitleColor(.black, for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.layer.cornerRadius = CGFloat(SettingPopUpView.BUTTONHEIGHT/2)
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.gray.cgColor
            button.layer.shadowColor = UIColor.lightGray.cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 1.5)
            button.layer.shadowOpacity = 0.5
            button.layer.shadowRadius = 2.5
            button.backgroundColor = UIColor.white
            button.addTarget(self, action: #selector(categoryBtnPressUp), for: .touchUpInside)
            button.addTarget(self, action: #selector(BtnPressDown), for: .touchDown)
            buttonArray.append(button)
        }
        return buttonArray
    }()
    var buttonRowArray:[UIView] = {
        var buttonRowArray = [UIView]()
        var count = Int(surveyCategories.count/COLUMNNUMBER)
        if surveyCategories.count % COLUMNNUMBER != 0 {
            count += 1
        }
        for i in 0..<count{
            let v = UIView()
            v.backgroundColor = UIColor.clear
            v.translatesAutoresizingMaskIntoConstraints = false
            buttonRowArray.append(v)
        }
        return buttonRowArray
    }()
    
    let frequencyButtonArray:[UIButton] = {
        var buttonArray = [UIButton]()
        for i in 0..<5 {
            let button = UIButton()
            button.setTitle(String(i+1), for: .normal)
            button.titleLabel!.font = UIFont.boldSystemFont(ofSize: 12.0)
            button.setTitleColor(.black, for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.layer.cornerRadius = CGFloat((SettingPopUpView.BUTTONHEIGHT+10)/2)
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.gray.cgColor
            button.layer.shadowColor = UIColor.lightGray.cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 1.5)
            button.layer.shadowOpacity = 0.5
            button.layer.shadowRadius = 2.5
            button.backgroundColor = UIColor.white
            button.addTarget(self, action: #selector(frequencyBtnPressUp), for: .touchUpInside)
            button.addTarget(self, action: #selector(BtnPressDown), for: .touchDown)
            buttonArray.append(button)
        }
        return buttonArray
    }()
    
    let headerView: UIView = {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.gray
        let foggyBlue = UIColor(red:0.79, green:0.86, blue:1.00, alpha:1.0)
        let foggyGrey = UIColor(red:0.70, green:0.70, blue:0.70, alpha:1.0)
        let frame = CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width * 0.9), height: 42)
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [foggyBlue.cgColor, foggyGrey.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = frame
        headerView.layer.insertSublayer(gradient, at: 0)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        return headerView
    }()
    let headerLabel: UILabel = {
        let headerLabel = UILabel()
        headerLabel.text = "Change Settings"
        headerLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        headerLabel.textAlignment = .center
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        return headerLabel
    }()
    let categoryLabel: UILabel = {
        let categoryLabel = UILabel()
        categoryLabel.text = "Topics for Curated Articles"
        categoryLabel.textAlignment = .center
        categoryLabel.adjustsFontSizeToFitWidth = true
        categoryLabel.numberOfLines = 2
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        return categoryLabel
    }()
    let categoryButtonContainer: UIView = {
        let categoryButtonContainer = UIView()
        categoryButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        return categoryButtonContainer
    }()
    let frequencyLabel: UILabel = {
        let label = UILabel()
        label.text = "Daily Curated Articles"
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.lightGray.cgColor
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let frequencyButtonContainer: UIView = {
        let frequencyButtonContainer = UIView()
        frequencyButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        return frequencyButtonContainer
    }()
    let submitContainer: UIView = {
        let submitContainer = UIView()
        submitContainer.backgroundColor = UIColor.white
        submitContainer.translatesAutoresizingMaskIntoConstraints = false
        return submitContainer
    }()
    let saveButton: UIButton = {
        let saveButton = UIButton()
        saveButton.setTitle("Save", for: .normal)
        saveButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 12.0)
        saveButton.setTitleColor(.black, for: .normal)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.layer.cornerRadius = CGFloat(SettingPopUpView.BUTTONHEIGHT/2)
        saveButton.layer.borderWidth = 1
        saveButton.layer.borderColor = UIColor.gray.cgColor
        saveButton.layer.shadowColor = UIColor.lightGray.cgColor
        saveButton.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        saveButton.layer.shadowOpacity = 0.5
        saveButton.layer.shadowRadius = 2.5
        saveButton.backgroundColor = UIColor.white
        saveButton.addTarget(self, action: #selector(saveBtnPressUp), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(BtnPressDown), for: .touchDown)
        return saveButton
    }()
    let cancelButton:UIButton = {
        let cancelButton = UIButton()
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 12.0)
        cancelButton.setTitleColor(.black, for: .normal)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.layer.cornerRadius = CGFloat(SettingPopUpView.BUTTONHEIGHT/2)
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.gray.cgColor
        cancelButton.layer.shadowColor = UIColor.lightGray.cgColor
        cancelButton.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        cancelButton.layer.shadowOpacity = 0.5
        cancelButton.layer.shadowRadius = 2.5
        cancelButton.backgroundColor = UIColor.white
        cancelButton.addTarget(self, action: #selector(cancelBtnPressUp), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(BtnPressDown), for: .touchDown)
        return cancelButton
    }()
    let lineView1: UIView = {
        let line = UIView();
        line.backgroundColor = UIColor.lightGray
        line.translatesAutoresizingMaskIntoConstraints = false
        line.layer.shadowColor = UIColor.lightGray.cgColor
        line.layer.shadowOffset = CGSize(width: 0, height: 0)
        line.layer.shadowOpacity = 0.75
        line.layer.shadowRadius = 1
        return line
    }()
    let lineView2: UIView = {
        let line = UIView();
        line.backgroundColor = UIColor.lightGray
        line.translatesAutoresizingMaskIntoConstraints = false
        line.layer.shadowColor = UIColor.lightGray.cgColor
        line.layer.shadowOffset = CGSize(width: 0, height: 0)
        line.layer.shadowOpacity = 0.75
        line.layer.shadowRadius = 1
        return line
    }()
    
    
    func setupLayout(){
        self.backgroundColor = UIColor.white
        self.clipsToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = 20
        
        addSubview(headerView)
        headerView.addSubview(headerLabel)
        addSubview(categoryButtonContainer)
        addSubview(categoryLabel)
        categoryLabel.addSubview(lineView1)
        
        addSubview(frequencyLabel)
        addSubview(frequencyButtonContainer)
        
        addSubview(submitContainer)
        submitContainer.addSubview(saveButton)
        submitContainer.addSubview(cancelButton)
        submitContainer.addSubview(lineView2)
        
        NSLayoutConstraint.activate([
            headerView.heightAnchor.constraint(equalToConstant: 42),
            headerView.widthAnchor.constraint(equalTo: self.widthAnchor),
            headerView.topAnchor.constraint(equalTo: self.topAnchor),
            headerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            headerLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            headerLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            headerLabel.widthAnchor.constraint(equalTo: headerView.widthAnchor),
            headerLabel.heightAnchor.constraint(equalTo: headerView.heightAnchor),
            
            categoryLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            categoryLabel.topAnchor.constraint(equalTo:headerView.bottomAnchor),
            categoryLabel.widthAnchor.constraint(equalTo:self.widthAnchor, multiplier: 0.8),
            categoryLabel.heightAnchor.constraint(equalToConstant: 40),
            
            lineView1.heightAnchor.constraint(equalToConstant: 0.5),
            lineView1.centerXAnchor.constraint(equalTo: categoryLabel.centerXAnchor),
            lineView1.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1),
            lineView1.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor),
            
            categoryButtonContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            categoryButtonContainer.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor),
            categoryButtonContainer.widthAnchor.constraint(equalTo: self.widthAnchor),
            
            frequencyLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            frequencyLabel.topAnchor.constraint(equalTo:categoryButtonContainer.bottomAnchor),
            frequencyLabel.widthAnchor.constraint(equalTo:self.widthAnchor, multiplier: 1),
            frequencyLabel.heightAnchor.constraint(equalToConstant: 40),
            
            frequencyButtonContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            frequencyButtonContainer.topAnchor.constraint(equalTo: frequencyLabel.bottomAnchor),
            frequencyButtonContainer.widthAnchor.constraint(equalTo: self.widthAnchor),
            frequencyButtonContainer.heightAnchor.constraint(equalToConstant: 60),
            
            submitContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            submitContainer.topAnchor.constraint(equalTo: frequencyButtonContainer.bottomAnchor),
            submitContainer.widthAnchor.constraint(equalTo: self.widthAnchor),
            submitContainer.heightAnchor.constraint(equalToConstant: (CGFloat(SettingPopUpView.BUTTONHEIGHT + 30))),
            
            saveButton.leadingAnchor.constraint(equalTo: submitContainer.centerXAnchor, constant: 15),
            saveButton.centerYAnchor.constraint(equalTo: submitContainer.centerYAnchor, constant: 0),
            saveButton.heightAnchor.constraint(equalToConstant: CGFloat(SettingPopUpView.BUTTONHEIGHT + 5)),
            saveButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.33),
            
            cancelButton.trailingAnchor.constraint(equalTo: submitContainer.centerXAnchor, constant: -15),
            cancelButton.centerYAnchor.constraint(equalTo: submitContainer.centerYAnchor, constant: 0),
            cancelButton.heightAnchor.constraint(equalToConstant: CGFloat(SettingPopUpView.BUTTONHEIGHT + 5)),
            cancelButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.33),
            
            lineView2.heightAnchor.constraint(equalToConstant: 0.5),
            lineView2.centerXAnchor.constraint(equalTo: submitContainer.centerXAnchor),
            lineView2.widthAnchor.constraint(equalTo: submitContainer.widthAnchor, multiplier: 1),
            lineView2.topAnchor.constraint(equalTo:submitContainer.topAnchor),
            
            self.topAnchor.constraint(equalTo: headerView.topAnchor),
            self.bottomAnchor.constraint(equalTo: submitContainer.bottomAnchor),
            ])
        
        let size = UIScreen.main.bounds
        self.transform = CGAffineTransform(translationX: 0, y: size.height*0.75)
        self.isHidden = true
    }
    
    func setupButtons(){
        for i in 0..<buttonRowArray.count {
            let h = CGFloat(i * (10 + SettingPopUpView.BUTTONHEIGHT) + 10)
            
            self.categoryButtonContainer.addSubview(buttonRowArray[i])
            NSLayoutConstraint.activate([
                buttonRowArray[i].widthAnchor.constraint(equalToConstant: CGFloat(viewWidth)),
                buttonRowArray[i].heightAnchor.constraint(equalToConstant: CGFloat(SettingPopUpView.BUTTONHEIGHT)),
                buttonRowArray[i].topAnchor.constraint(equalTo:self.categoryButtonContainer.topAnchor, constant: h)
                ])
        }
        categoryButtonContainer.bottomAnchor.constraint(equalTo: buttonRowArray[buttonRowArray.count-1].bottomAnchor, constant: 10).isActive = true
        
        let buttonWidth = CGFloat(viewWidth * CGFloat(0.85/Double(SettingPopUpView.COLUMNNUMBER)))
        let indent = ((viewWidth - CGFloat(buttonWidth * CGFloat(SettingPopUpView.COLUMNNUMBER)))/CGFloat(SettingPopUpView.COLUMNNUMBER+1))
        
        for i in 0..<buttonArray.count {
            let row = Int(i/SettingPopUpView.COLUMNNUMBER)
            let col = i%SettingPopUpView.COLUMNNUMBER
            
            
            let left = (CGFloat(col) * (CGFloat(indent) + buttonWidth) + CGFloat(indent))
            buttonRowArray[row].addSubview(buttonArray[i])
            NSLayoutConstraint.activate([
                buttonArray[i].widthAnchor.constraint(equalToConstant: buttonWidth),
                buttonArray[i].heightAnchor.constraint(equalTo: buttonRowArray[row].heightAnchor),
                buttonArray[i].leadingAnchor.constraint(equalTo:buttonRowArray[row].leadingAnchor, constant: left)
                ])
        }
        
        for i in buttonRowArray{
            let subCount = i.subviews.count
            let rowWidth = ((CGFloat(subCount) * buttonWidth) + (indent * CGFloat(subCount + 1)))
            i.widthAnchor.constraint(equalToConstant: rowWidth).isActive = true
            i.centerXAnchor.constraint(equalTo: categoryButtonContainer.centerXAnchor).isActive = true
        }
        
        let frequencyButtonSize = SettingPopUpView.BUTTONHEIGHT + 10
        let frequnecyIndent = ((viewWidth - CGFloat(frequencyButtonSize * 5))/6)
        
        for i in 0..<frequencyButtonArray.count{
            frequencyButtonContainer.addSubview(frequencyButtonArray[i])
            
            NSLayoutConstraint.activate([
                frequencyButtonArray[i].centerYAnchor.constraint(equalTo: frequencyButtonContainer.centerYAnchor),
                frequencyButtonArray[i].heightAnchor.constraint(equalToConstant: CGFloat(frequencyButtonSize)),
                frequencyButtonArray[i].widthAnchor.constraint(equalToConstant: CGFloat(frequencyButtonSize)),
                ])
            
            if i == 0 {
                frequencyButtonArray[i].leadingAnchor.constraint(equalTo: frequencyButtonContainer.leadingAnchor, constant: frequnecyIndent).isActive = true
            }
            else if i > 0 {
                frequencyButtonArray[i].leadingAnchor.constraint(equalTo: frequencyButtonArray[i-1].trailingAnchor, constant: frequnecyIndent).isActive = true
            }
            
        }
        
    }
    
    func updateButtons(){
        for i in buttonArray {
            i.backgroundColor = .white
            if selectedCategories.contains(i.titleLabel!.text ?? "error"){
                i.backgroundColor = UIColor.init(displayP3Red: 0.7, green: 0.7, blue: 0.8, alpha: 1.0)
            }
        }
        for i in frequencyButtonArray{
            i.backgroundColor = .white
        }
        if selectedFrequency > 0 {
            frequencyButtonArray[selectedFrequency-1].backgroundColor = UIColor.init(displayP3Red: 0.7, green: 0.7, blue: 0.8, alpha: 1.0)
        }
    }
    
    //show popup
    func show (){
        let size = UIScreen.main.bounds
        self.isHidden = false
        self.transform = CGAffineTransform(translationX: 0, y: size.height*0.75)
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 15, options: .curveEaseIn, animations: {
            self.transform = .identity
        })
    }
    
    //hide popup
    func hide (){
        let size = UIScreen.main.bounds
        
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(translationX: 0, y: size.height)
        },completion: { _ in
            self.isHidden = true
        })
    }
    
    @objc func categoryBtnPressUp(sender:UIButton){
        let tappedItem = sender.titleLabel!.text as! String
        sender.transform = CGAffineTransform.identity
        if selectedCategories.contains(tappedItem) {
            let i = selectedCategories.firstIndex(of: tappedItem)
            selectedCategories.remove(at: i!)
            sender.backgroundColor = UIColor.white
        }
        else {
            if selectedCategories.count < SettingPopUpView.MAXSELECTIONS{
                selectedCategories.append(tappedItem)
                sender.backgroundColor = UIColor.init(displayP3Red: 0.7, green: 0.7, blue: 0.8, alpha: 1.0)
            }
            else {
                sender.backgroundColor = UIColor.white
                
            }
        }
    }
    
    @objc func frequencyBtnPressUp(sender:UIButton){
        let tappedItem = Int(sender.titleLabel!.text ?? "0")
        sender.transform = CGAffineTransform.identity
        for i in frequencyButtonArray{
            i.backgroundColor = .white
        }
        sender.backgroundColor = UIColor.init(displayP3Red: 0.7, green: 0.7, blue: 0.8, alpha: 1.0)
        selectedFrequency = tappedItem ?? 0
    }
    
    @objc func saveBtnPressUp (sender:UIButton){
        sender.transform = CGAffineTransform.identity
        sender.backgroundColor = UIColor.white
        hide()
        delegate?.closeSave(sentCategories: selectedCategories, sentFrequency: selectedFrequency)
    }
    
    @objc func cancelBtnPressUp (sender:UIButton){
        sender.transform = CGAffineTransform.identity
        sender.backgroundColor = UIColor.white
        hide()
        delegate?.closeCancel()
    }
    
    @objc func BtnPressDown(sender:UIButton){
        sender.backgroundColor = UIColor.lightGray
        sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    }
}
