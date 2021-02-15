////
////  SettingsSlideinView.swift
////  Foggy Glasses
////
////  Created by Alec Barton on 7/19/19.
////  Copyright © 2019 Foggy Glasses. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//protocol SettingsSlideinDelegate: AnyObject {
//    func closeCancel()
//    func closeSave(sentCategories:[String], sentTimes:[String:Int])
//}
//
//class SettingSlideinView:UIView{
//    weak var delegate:SettingsSlideinDelegate?
//    
//    //columns of category buttons
//    static let COLUMNNUMBER = 3
//    static let TIMECOLUMNNUMBER = 4
//    static let BUTTONHEIGHT = 32
//    //number of categories that can be selected
//    static let MAXSELECTIONS = 3
//    
//    var viewWidth = CGFloat(0)
//    
//    //temporarily store selected setttings here
//    var selectedCategories:[String]=[]
////    var selectedFrequency:Int = 3
//    var selectedTimes: [String: Int] = [:]
//    
//    //categories of articles a user can select
//    //categories can be added or substracted from this array and the popup will scaleas needed
//    static let surveyCategories: [String] = {
//        return  [
//            "US News",
//            "World News",
//            "Technology",
//            "Health",
//            "Entertainment",
//            "Sports",
//            "Science",
//            "Finance",
//            "Crypto",
//            "Gaming",
//            "Trending",
//        ]
//    }()
//    
//    static let curationTimes: [String] = {
//        return  [
//            "7 am",
//            "12 pm",
//            "6 pm",
//            "9 pm",
//        ]
//    }()
//    
//    //initializers
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        viewWidth = (frame.width )
//        self.translatesAutoresizingMaskIntoConstraints = false
//        loadPreferences()
//        setupLayout()
//        setupButtons()
//    }
//    
//    func loadPreferences(preCategories:[String] = [], preTimes:[String] = []){
//        selectedCategories = preCategories
//        
////        for i in preTimes
//        
//        
//        for i in SettingSlideinView.curationTimes {
////            if preTimes.contains(toStandardTimeString(militaryTime: i)){
////                selectedTimes[toMilitaryTime(standardTime: i)] = 1
////            }
////            else{
//            selectedTimes[toMilitaryTime(standardTime: i)] = 0
////            }
//
//        }
//        for i in preTimes {
//            selectedTimes[i] = 1
//        }
//        
//        
//        updateButtons()
//    }
//    
//    let buttonArray:[UIButton] = {
//        var buttonArray = [UIButton]()
//        for i in surveyCategories {
//            let button = UIButton()
//            button.setTitle(i, for: .normal)
//            button.titleLabel!.font = UIFont.boldSystemFont(ofSize: 12.0)
//            button.setTitleColor(.black, for: .normal)
//            button.translatesAutoresizingMaskIntoConstraints = false
//            button.layer.cornerRadius = CGFloat(SettingSlideinView.BUTTONHEIGHT/2)
//            button.layer.borderWidth = 1
//            button.layer.borderColor = UIColor.clear.cgColor
//            button.layer.shadowColor = UIColor.lightGray.cgColor
//            button.layer.shadowOffset = CGSize(width: 0, height: 1.5)
//            button.layer.shadowOpacity = 0.5
//            button.layer.shadowRadius = 2.5
//            button.backgroundColor = UIColor.white
//            button.addTarget(self, action: #selector(categoryBtnPressUp), for: .touchUpInside)
//            button.addTarget(self, action: #selector(BtnPressDown), for: .touchDown)
//            buttonArray.append(button)
//        }
//        return buttonArray
//    }()
//    var buttonRowArray:[UIView] = {
//        var buttonRowArray = [UIView]()
//        var count = Int(surveyCategories.count/COLUMNNUMBER)
//        if surveyCategories.count % COLUMNNUMBER != 0 {
//            count += 1
//        }
//        for i in 0..<count{
//            let v = UIView()
//            v.backgroundColor = UIColor.clear
//            v.translatesAutoresizingMaskIntoConstraints = false
//            buttonRowArray.append(v)
//        }
//        return buttonRowArray
//    }()
//    
//    let timeButtonArray:[UIButton] = {
//        var buttonArray = [UIButton]()
//        for i in curationTimes {
//            let button = UIButton()
//            button.setTitle(i, for: .normal)
//            button.titleLabel!.font = UIFont.boldSystemFont(ofSize: 12.0)
//            button.setTitleColor(.black, for: .normal)
//            button.translatesAutoresizingMaskIntoConstraints = false
//            button.layer.cornerRadius = CGFloat(SettingSlideinView.BUTTONHEIGHT/2)
//            button.layer.borderWidth = 1
//            button.layer.borderColor = UIColor.clear.cgColor
//            button.layer.shadowColor = UIColor.lightGray.cgColor
//            button.layer.shadowOffset = CGSize(width: 0, height: 1.5)
//            button.layer.shadowOpacity = 0.5
//            button.layer.shadowRadius = 2.5
//            button.backgroundColor = UIColor.white
//            button.addTarget(self, action: #selector(timeBtnPressUp), for: .touchUpInside)
//            button.addTarget(self, action: #selector(BtnPressDown), for: .touchDown)
//            buttonArray.append(button)
//        }
//        return buttonArray
//    }()
//    
//    let timeButtonRowArray:[UIView] = {
//        var buttonRowArray = [UIView]()
//        var count = Int(curationTimes.count/TIMECOLUMNNUMBER)
//        if curationTimes.count % TIMECOLUMNNUMBER != 0 {
//            count += 1
//        }
//        for i in 0..<count{
//            let v = UIView()
//            v.backgroundColor = UIColor.clear
//            v.translatesAutoresizingMaskIntoConstraints = false
//            buttonRowArray.append(v)
//        }
//        return buttonRowArray
//    }()
//    
//    let backgroundView: UIView = {
//        let backgroundView = UIView()
//        backgroundView.backgroundColor = .feedBackground
//        backgroundView.translatesAutoresizingMaskIntoConstraints = false
//        return backgroundView
//    }()
//    
//    let mainView: UIView = {
//        let mainView = UIView()
//        mainView.backgroundColor = .feedBackground
//        mainView.translatesAutoresizingMaskIntoConstraints = false
//        return mainView
//    }()
//    
//    let headerView: UIView = {
//        let headerView = UIView()
//        let frame = CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width * 0.9), height: 42)
//        headerView.translatesAutoresizingMaskIntoConstraints = false
//        return headerView
//    }()
//    let headerLabel: UILabel = {
//        let headerLabel = UILabel()
//        headerLabel.text = "Change Curation Settings"
//        headerLabel.font = UIFont.systemFont(ofSize: 20.0)
//        headerLabel.textColor = .gray
//        headerLabel.textAlignment = .center
//        headerLabel.translatesAutoresizingMaskIntoConstraints = false
//        return headerLabel
//    }()
//    let categoryLabel: UILabel = {
//        let categoryLabel = UILabel()
//        categoryLabel.text = "Topics for Curated Articles"
//        categoryLabel.font = UIFont.systemFont(ofSize: 14.0)
//        categoryLabel.textAlignment = .left
//        categoryLabel.adjustsFontSizeToFitWidth = true
//        categoryLabel.numberOfLines = 2
//        categoryLabel.textColor = UIColor(red:0.56, green:0.56, blue:0.58, alpha:1.0)
//        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
//        return categoryLabel
//    }()
//    let categoryButtonContainer: UIView = {
//        let categoryButtonContainer = UIView()
//        categoryButtonContainer.translatesAutoresizingMaskIntoConstraints = false
//        return categoryButtonContainer
//    }()
//    let frequencyLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Times to receive Curated Articles"
//        label.font = UIFont.systemFont(ofSize: 14.0)
//        label.textAlignment = .left
//        label.adjustsFontSizeToFitWidth = true
//        label.numberOfLines = 2
//        label.textColor = UIColor(red:0.56, green:0.56, blue:0.58, alpha:1.0)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    let frequencyButtonContainer: UIView = {
//        let frequencyButtonContainer = UIView()
//        frequencyButtonContainer.translatesAutoresizingMaskIntoConstraints = false
//        return frequencyButtonContainer
//    }()
//    let submitContainer: UIView = {
//        let submitContainer = UIView()
//        submitContainer.backgroundColor = UIColor.clear
//        submitContainer.translatesAutoresizingMaskIntoConstraints = false
//        return submitContainer
//    }()
//    let saveButton: UIButton = {
//        let saveButton = UIButton()
//        saveButton.setTitle("Save", for: .normal)
//        saveButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 12.0)
//        saveButton.setTitleColor(.black, for: .normal)
//        saveButton.translatesAutoresizingMaskIntoConstraints = false
//        saveButton.layer.cornerRadius = CGFloat(SettingSlideinView.BUTTONHEIGHT/2)
//        saveButton.layer.borderWidth = 1
//        saveButton.layer.borderColor = UIColor.clear.cgColor
//        saveButton.layer.shadowColor = UIColor.lightGray.cgColor
//        saveButton.layer.shadowOffset = CGSize(width: 0, height: 1.5)
//        saveButton.layer.shadowOpacity = 0.5
//        saveButton.layer.shadowRadius = 2.5
//        saveButton.backgroundColor = UIColor.white
//        saveButton.addTarget(self, action: #selector(saveBtnPressUp), for: .touchUpInside)
//        saveButton.addTarget(self, action: #selector(BtnPressDown), for: .touchDown)
//        return saveButton
//    }()
//    let cancelButton:UIButton = {
//        let cancelButton = UIButton()
//        cancelButton.setTitle("Cancel", for: .normal)
//        cancelButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 12.0)
//        cancelButton.setTitleColor(.black, for: .normal)
//        cancelButton.translatesAutoresizingMaskIntoConstraints = false
//        cancelButton.layer.cornerRadius = CGFloat(SettingSlideinView.BUTTONHEIGHT/2)
//        cancelButton.layer.borderWidth = 1
//        cancelButton.layer.borderColor = UIColor.clear.cgColor
//        cancelButton.layer.shadowColor = UIColor.lightGray.cgColor
//        cancelButton.layer.shadowOffset = CGSize(width: 0, height: 1.5)
//        cancelButton.layer.shadowOpacity = 0.5
//        cancelButton.layer.shadowRadius = 2.5
//        cancelButton.backgroundColor = UIColor.white
//        cancelButton.addTarget(self, action: #selector(cancelBtnPressUp), for: .touchUpInside)
//        cancelButton.addTarget(self, action: #selector(BtnPressDown), for: .touchDown)
//        return cancelButton
//    }()
//    let lineView1: UIView = {
//        let line = UIView();
//        line.backgroundColor = UIColor.lightGray
//        line.translatesAutoresizingMaskIntoConstraints = false
//        line.layer.shadowColor = UIColor.lightGray.cgColor
//        line.layer.shadowOffset = CGSize(width: 0, height: 0)
//        line.layer.shadowOpacity = 0.75
//        line.layer.shadowRadius = 1
//        return line
//    }()
//    let lineView2: UIView = {
//        let line = UIView();
//        line.backgroundColor = UIColor.lightGray
//        line.translatesAutoresizingMaskIntoConstraints = false
//        line.layer.shadowColor = UIColor.lightGray.cgColor
//        line.layer.shadowOffset = CGSize(width: 0, height: 0)
//        line.layer.shadowOpacity = 0.75
//        line.layer.shadowRadius = 1
//        return line
//    }()
//    
//    
//    func setupLayout(){
//        self.backgroundColor = .feedBackground
//        
//        addSubview(backgroundView)
//        addSubview(mainView)
//        
//        
//        mainView.addSubview(headerView)
//        headerView.addSubview(headerLabel)
//        mainView.addSubview(categoryButtonContainer)
//        mainView.addSubview(categoryLabel)
//        categoryLabel.addSubview(lineView1)
//        
//        mainView.addSubview(frequencyLabel)
//        mainView.addSubview(frequencyButtonContainer)
//        
//        mainView.addSubview(submitContainer)
//        submitContainer.addSubview(saveButton)
//        submitContainer.addSubview(cancelButton)
//        submitContainer.addSubview(lineView2)
//        
//        NSLayoutConstraint.activate([
//            backgroundView.heightAnchor.constraint(equalTo: self.heightAnchor),
//            backgroundView.widthAnchor.constraint(equalTo: self.widthAnchor),
//            backgroundView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//            backgroundView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
//            
//            mainView.widthAnchor.constraint(equalTo: self.widthAnchor),
//            mainView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//            mainView.topAnchor.constraint(equalTo: self.topAnchor),
////            mainView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
//            
//            headerView.heightAnchor.constraint(equalToConstant: 50),
//            headerView.widthAnchor.constraint(equalTo: mainView.widthAnchor, multiplier: 0.9),
//            headerView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 10),
//            headerView.centerXAnchor.constraint(equalTo: mainView.centerXAnchor),
//            
//            headerLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
//            headerLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
//            headerLabel.widthAnchor.constraint(equalTo: headerView.widthAnchor),
//            headerLabel.heightAnchor.constraint(equalTo: headerView.heightAnchor),
//            
//            categoryLabel.centerXAnchor.constraint(equalTo: mainView.centerXAnchor),
//            categoryLabel.topAnchor.constraint(equalTo:headerView.bottomAnchor, constant: 20),
//            categoryLabel.widthAnchor.constraint(equalTo:mainView.widthAnchor, multiplier: 0.9),
//            categoryLabel.heightAnchor.constraint(equalToConstant: 25),
//            
//            lineView1.heightAnchor.constraint(equalToConstant: 0.5),
//            lineView1.centerXAnchor.constraint(equalTo: categoryLabel.centerXAnchor),
//            lineView1.widthAnchor.constraint(equalTo: mainView.widthAnchor, multiplier: 1),
//            lineView1.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor),
//            
//            lineView2.heightAnchor.constraint(equalToConstant: 0.5),
//            lineView2.centerXAnchor.constraint(equalTo: submitContainer.centerXAnchor),
//            lineView2.widthAnchor.constraint(equalTo: submitContainer.widthAnchor, multiplier: 1),
//            lineView2.topAnchor.constraint(equalTo:frequencyLabel.bottomAnchor),
//            
//            categoryButtonContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
//            categoryButtonContainer.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor),
//            categoryButtonContainer.widthAnchor.constraint(equalTo: mainView.widthAnchor),
//            
//            frequencyLabel.centerXAnchor.constraint(equalTo: mainView.centerXAnchor),
//            frequencyLabel.topAnchor.constraint(equalTo:categoryButtonContainer.bottomAnchor, constant: 35),
//            frequencyLabel.widthAnchor.constraint(equalTo: mainView.widthAnchor, multiplier: 0.9),
//            frequencyLabel.heightAnchor.constraint(equalToConstant: 25),
//            
//            frequencyButtonContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
//            frequencyButtonContainer.topAnchor.constraint(equalTo: frequencyLabel.bottomAnchor),
//            frequencyButtonContainer.widthAnchor.constraint(equalTo: mainView.widthAnchor),
//            frequencyButtonContainer.heightAnchor.constraint(equalToConstant: 60),
//            
//            submitContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
//            submitContainer.topAnchor.constraint(equalTo: frequencyButtonContainer.bottomAnchor, constant:40),
//            submitContainer.widthAnchor.constraint(equalTo: mainView.widthAnchor),
//            submitContainer.heightAnchor.constraint(equalToConstant: (CGFloat(SettingSlideinView.BUTTONHEIGHT + 30))),
//            
//            saveButton.leadingAnchor.constraint(equalTo: submitContainer.centerXAnchor, constant: 15),
//            saveButton.centerYAnchor.constraint(equalTo: submitContainer.centerYAnchor, constant: 0),
//            saveButton.heightAnchor.constraint(equalToConstant: CGFloat(SettingSlideinView.BUTTONHEIGHT + 5)),
//            saveButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.33),
//            
//            cancelButton.trailingAnchor.constraint(equalTo: submitContainer.centerXAnchor, constant: -15),
//            cancelButton.centerYAnchor.constraint(equalTo: submitContainer.centerYAnchor, constant: 0),
//            cancelButton.heightAnchor.constraint(equalToConstant: CGFloat(SettingSlideinView.BUTTONHEIGHT + 5)),
//            cancelButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.33),
//            
//            
//            
//            mainView.topAnchor.constraint(equalTo: headerView.topAnchor),
//            mainView.bottomAnchor.constraint(equalTo: submitContainer.bottomAnchor),
//            ])
//        
//        let size = UIScreen.main.bounds
//        self.transform = CGAffineTransform(translationX: 0, y: size.height*0.75)
//        self.isHidden = true
//    }
//    
//    func setupButtons(){
//        for i in 0..<buttonRowArray.count {
//            let h = CGFloat(i * (10 + SettingSlideinView.BUTTONHEIGHT) + 10)
//            
//            self.categoryButtonContainer.addSubview(buttonRowArray[i])
//            NSLayoutConstraint.activate([
//                buttonRowArray[i].widthAnchor.constraint(equalToConstant: CGFloat(viewWidth)),
//                buttonRowArray[i].heightAnchor.constraint(equalToConstant: CGFloat(SettingSlideinView.BUTTONHEIGHT)),
//                buttonRowArray[i].topAnchor.constraint(equalTo:self.categoryButtonContainer.topAnchor, constant: h)
//                ])
//        }
//        categoryButtonContainer.bottomAnchor.constraint(equalTo: buttonRowArray[buttonRowArray.count-1].bottomAnchor, constant: 10).isActive = true
//        
//        let buttonWidth = CGFloat((viewWidth * 0.95) * CGFloat(0.85/Double(SettingSlideinView.COLUMNNUMBER)))
//        let indent = (((viewWidth * 0.95) - CGFloat(buttonWidth * CGFloat(SettingSlideinView.COLUMNNUMBER)))/CGFloat(SettingSlideinView.COLUMNNUMBER+1))
//        
//        for i in 0..<buttonArray.count {
//            let row = Int(i/SettingSlideinView.COLUMNNUMBER)
//            let col = i%SettingSlideinView.COLUMNNUMBER
//            
//            
//            let left = (CGFloat(col) * (CGFloat(indent) + buttonWidth) + CGFloat(indent))
//            buttonRowArray[row].addSubview(buttonArray[i])
//            NSLayoutConstraint.activate([
//                buttonArray[i].widthAnchor.constraint(equalToConstant: buttonWidth),
//                buttonArray[i].heightAnchor.constraint(equalTo: buttonRowArray[row].heightAnchor),
//                buttonArray[i].leadingAnchor.constraint(equalTo:buttonRowArray[row].leadingAnchor, constant: left)
//                ])
//        }
//        
//        for i in buttonRowArray{
//            let subCount = i.subviews.count
//            let rowWidth = ((CGFloat(subCount) * buttonWidth) + (indent * CGFloat(subCount + 1)))
//            i.widthAnchor.constraint(equalToConstant: rowWidth).isActive = true
//            i.centerXAnchor.constraint(equalTo: categoryButtonContainer.centerXAnchor).isActive = true
//        }
//        
//        //
//        
//        for i in 0..<timeButtonRowArray.count {
//            let h = CGFloat(i * (10 + SettingSlideinView.BUTTONHEIGHT) + 10)
//            
//            self.frequencyButtonContainer.addSubview(timeButtonRowArray[i])
//            NSLayoutConstraint.activate([
//                timeButtonRowArray[i].widthAnchor.constraint(equalToConstant: CGFloat(viewWidth)),
//                timeButtonRowArray[i].heightAnchor.constraint(equalToConstant: CGFloat(SettingSlideinView.BUTTONHEIGHT)),
//                timeButtonRowArray[i].topAnchor.constraint(equalTo:self.frequencyButtonContainer.topAnchor, constant: h)
//                ])
//        }
//        frequencyButtonContainer.bottomAnchor.constraint(equalTo: timeButtonRowArray[timeButtonRowArray.count-1].bottomAnchor, constant: 10).isActive = true
//        
//        let timeButtonWidth = CGFloat((viewWidth * 0.95) * CGFloat(0.85/Double(SettingSlideinView.TIMECOLUMNNUMBER)))
//        let timeIndent = (((viewWidth * 0.95) - CGFloat(timeButtonWidth * CGFloat(SettingSlideinView.TIMECOLUMNNUMBER)))/CGFloat(SettingSlideinView.TIMECOLUMNNUMBER+1))
//        
//        for i in 0..<timeButtonArray.count {
//            let row = Int(i/SettingSlideinView.TIMECOLUMNNUMBER)
//            let col = i%SettingSlideinView.TIMECOLUMNNUMBER
//            
//            
//            let left = (CGFloat(col) * (CGFloat(timeIndent) + timeButtonWidth) + CGFloat(timeIndent))
//            timeButtonRowArray[row].addSubview(timeButtonArray[i])
//            NSLayoutConstraint.activate([
//                timeButtonArray[i].widthAnchor.constraint(equalToConstant: timeButtonWidth),
//                timeButtonArray[i].heightAnchor.constraint(equalToConstant: CGFloat(SettingSlideinView.BUTTONHEIGHT)),
//                timeButtonArray[i].leadingAnchor.constraint(equalTo:timeButtonRowArray[row].leadingAnchor, constant: left)
//                ])
//        }
//        
//        for i in timeButtonRowArray{
//            let subCount = i.subviews.count
//            let rowWidth = ((CGFloat(subCount) * timeButtonWidth) + (timeIndent * CGFloat(subCount + 1)))
//            i.widthAnchor.constraint(equalToConstant: rowWidth).isActive = true
//            i.centerXAnchor.constraint(equalTo: frequencyButtonContainer.centerXAnchor).isActive = true
//        }
//        
//        
//    }
//    
//    func updateButtons(){
//        for i in buttonArray {
//            i.backgroundColor = .white
//            if selectedCategories.contains(i.titleLabel!.text ?? "error"){
//                i.backgroundColor = UIColor.init(displayP3Red: 0.7, green: 0.7, blue: 0.8, alpha: 1.0)
//            }
//        }
//        for i in timeButtonArray {
//            let key = toMilitaryTime(standardTime: i.titleLabel!.text ?? "error")
//            if (selectedTimes[key]==1){
//                i.backgroundColor = UIColor.init(displayP3Red: 0.7, green: 0.7, blue: 0.8, alpha: 1.0)
//            }
//            else if (selectedTimes[key]==0) {
//                i.backgroundColor = .white
//            }
//        }
//    }
//    
//    //show popup
//    func show (){
//        let size = UIScreen.main.bounds
//        self.isHidden = false
//        self.transform = CGAffineTransform(translationX: size.width, y: 0)
//        UIView.animate(withDuration: 0.25, animations: {
//            self.transform = .identity
//        })
//    }
//    
//    //hide popup
//    func hide (){
//        let size = UIScreen.main.bounds
//        
//        UIView.animate(withDuration: 0.25, animations: {
//            self.transform = CGAffineTransform(translationX: size.width, y: 0)
//        },completion: { _ in
//            self.isHidden = true
//        })
//    }
//    
//    @objc func categoryBtnPressUp(sender:UIButton){
//        let tappedItem = sender.titleLabel!.text as! String
//        sender.transform = CGAffineTransform.identity
//        if selectedCategories.contains(tappedItem) {
//            let i = selectedCategories.firstIndex(of: tappedItem)
//            selectedCategories.remove(at: i!)
//            sender.backgroundColor = UIColor.white
//        }
//        else {
//            if selectedCategories.count < SettingSlideinView.MAXSELECTIONS{
//                selectedCategories.append(tappedItem)
//                sender.backgroundColor = UIColor.init(displayP3Red: 0.7, green: 0.7, blue: 0.8, alpha: 1.0)
//            }
//            else {
//                sender.backgroundColor = UIColor.white
//                
//            }
//        }
//    }
//    
//    @objc func timeBtnPressUp(sender:UIButton){
//        var tappedItem = sender.titleLabel!.text as! String
//        sender.transform = CGAffineTransform.identity
//        sender.backgroundColor = UIColor.white
//        
//        tappedItem = toMilitaryTime(standardTime: tappedItem)
//       
//        if selectedTimes[tappedItem] == 1 {
//            var count = 0
//            //make sure there is at least 1 selected time
//            for keys in selectedTimes{
//                if keys.value == 1 {
//                    count += 1
//                }
//                if (count > 1) {
//                    break
//                }
//            }
//            //if time is last selected time, dont allow it to be removed
//            if count > 1{
//                selectedTimes[tappedItem] = 0
//            }
//            else{
//                selectedTimes[tappedItem] = 1
//                sender.backgroundColor = UIColor.init(displayP3Red: 0.7, green: 0.7, blue: 0.8, alpha: 1.0)
//            }
//        }
//        else if selectedTimes[tappedItem] == 0 {
//            selectedTimes[tappedItem] = 1
//            sender.backgroundColor = UIColor.init(displayP3Red: 0.7, green: 0.7, blue: 0.8, alpha: 1.0)
//        }
//
//        
//    }
//
//    
//    @objc func saveBtnPressUp (sender:UIButton){
//        sender.transform = CGAffineTransform.identity
//        sender.backgroundColor = UIColor.white
//        hide()
//        delegate?.closeSave(sentCategories: selectedCategories, sentTimes: selectedTimes)
//    }
//    
//    @objc func cancelBtnPressUp (sender:UIButton){
//        sender.transform = CGAffineTransform.identity
//        sender.backgroundColor = UIColor.white
//        hide()
//        delegate?.closeCancel()
//    }
//    
//    @objc func BtnPressDown(sender:UIButton){
//        sender.backgroundColor = UIColor.lightGray
//        sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
//    }
//    
//    func toMilitaryTime (standardTime: String) -> String{
//        let splitTime = standardTime.split(separator: " ")
//        var militaryTime = ""
//        if var hourInt = Int(splitTime[0])  {
//            if splitTime[1] == "pm" && hourInt != 12 {
//                hourInt += 12
//            }
//            let timeString = String(hourInt) + ":00"
//            militaryTime = timeString
//        }
//        else{
//            militaryTime = ""
//        }
//        return militaryTime
//    }
//    
//    func toStandardTimeString (militaryTime: String) ->String{
//        let splitTime = militaryTime.split(separator: ":")
//        var standardTime = ""
//        var suffix = ""
//        if var hourInt = Int(splitTime[0]){
//            if hourInt > 12 {
//                hourInt = hourInt - 12
//                suffix = " pm"
//                standardTime = String(hourInt) + suffix
//            }
//            else {
//                if hourInt == 12{
//                    suffix = " pm"
//                }
//                else{
//                    suffix = " am"
//                }
//                
//                standardTime = String(hourInt) + suffix
//            }
//        }
//        return (standardTime)
//    }
//}
