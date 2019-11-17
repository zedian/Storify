//
//  DetailControllerViewController.swift
//  MusicalJournal
//
//  Created by Philip Tam on 2019-11-16.
//  Copyright © 2019 musicaljournal. All rights reserved.
//

import UIKit


class DetailController: UIViewController, JournalListViewControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            let nib = UINib(nibName: "RecommendationCell", bundle: nil)
            collectionView.register(nib, forCellWithReuseIdentifier: "RecommendationCell")
            collectionView.dataSource = self
            collectionView.delegate = self
            
        }
    }
    
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var textField: UITextField! {
        didSet{
            textField.delegate = self
            
        }
    }
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.delegate = self
            self.textView.isExclusiveTouch = false
        }
    }
    
    @IBOutlet weak var recommendButton: UIButton! {
         didSet {
                   recommendButton.backgroundColor = UIColor(red: 26/255.0, green: 26/255.0, blue: 26/255.0, alpha: 1)
                   recommendButton.contentEdgeInsets = UIEdgeInsets(top: 11.75, left: 32.0, bottom: 11.75, right: 32.0)
                   recommendButton.translatesAutoresizingMaskIntoConstraints = false
                   let title = NSAttributedString(string: "RECOMMEND", attributes: [
                       .font: UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .heavy),
                       .foregroundColor: UIColor.white,
                       .kern: 2.0
                   ])
                   recommendButton.setAttributedTitle(title, for: .normal)
            }
    }
    
    @IBOutlet weak var clearView: UIView!
    @IBOutlet weak var spotifyView: UIView! {
        didSet {
            
        }
    }
    
    @IBOutlet weak var parentTextView: UIView!
    
    @IBOutlet var cornerShadowsView: [UIView]!
    
    var mainVC: JournalController?
    var journal: Journal?
    var indexPath: IndexPath?
    var recommended: Bool = false
    var recommendations: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gr = UITapGestureRecognizer(target: self, action: #selector(clearInput))
          clearView.addGestureRecognizer(gr)
        self.view.bringSubviewToFront(clearView)
          clearView.isUserInteractionEnabled = true
          clearView.alpha = 0
//        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        for view in cornerShadowsView {
            view.layer.cornerRadius = 15
            view.layer.shadowPath = UIBezierPath(roundedRect: view.layer.bounds, cornerRadius:view.layer.cornerRadius).cgPath
            view.layer.shadowColor = UIColor.white.cgColor
            view.layer.shadowRadius = 5
            view.layer.shadowOffset = CGSize(width: 1, height: 4)
            view.layer.shadowOpacity = 3
        }
        self.recommendButton.layer.cornerRadius = self.recommendButton.frame.height / 2
        self.recommendButton.layer.borderWidth = 1
        self.recommendButton.layer.borderColor =  UIColor.lightGray.cgColor
    }
    
    override func viewDidLayoutSubviews() {
        
    }
  
    func journalListViewController(_ controller: JournalController, didSelectJournal: Journal, indexPath: IndexPath, first: Bool) {
        self.mainVC = controller
        self.indexPath = indexPath
        self.journal = didSelectJournal
        textView.text = didSelectJournal.text
        textField.text = didSelectJournal.title
        self.textView.isEditable = true
        self.textField.isEnabled = true
        self.deleteButton.isHidden = false
        controller.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
        if(first) {
            textView.textColor = UIColor.lightGray
        }
    }
    
    @objc func clearInput() {
        clearView.alpha = 0
        self.view.endEditing(true)
    }
    
    @IBAction func deletePressed(_ sender: UIButton) {
        guard let indexPath = indexPath else {return}
        mainVC?.journals.remove(at: indexPath.row)
        guard let id = journal?.id else {return}
        FirebaseManager.shared.delete(id: id) { (success, error) in
            
        }
        self.journal = nil
        self.textView.text = ""
        self.textView.isEditable = false
        self.textField.isEnabled = false
        self.indexPath = nil
        self.textField.text = ""
        self.mainVC?.tableView.reloadData()
        self.deleteButton.isHidden = true
    }
    
    @IBAction func recommendationPressed(_ sender: Any) {
       makeRecommendation()
    }
    
    func makeRecommendation() {
        let texts  =  self.textView.text.split(whereSeparator: { (c) -> Bool in
            if (c == "." || c == "!" || c == "\n" || c == "?" ) {
                return true
            }
            return false
        })
        let text = texts.last
        guard let t = text else {return}
        let lastC: String = String(self.textView.text.last!)
        var string: String = ""
        if t == "" {
            string = String(texts[texts.count - 2]) + lastC
        } else {
            string = String(texts[texts.count - 1])
        }
            
       NaturalLanguageManager.shared.getSuggestions(data: string) { (success, recommendations) in
           if(success) {
               guard let recommendations = recommendations else {return}
               self.recommendations = Array(recommendations.values)
               self.recommended = true
               DispatchQueue.main.async {
                   self.recommended = true
                   self.collectionView.reloadData()
               }
           }
       }
    }
}

extension DetailController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.white
        }
        clearView.alpha = 1
        self.view.bringSubviewToFront(clearView)
        self.view.bringSubviewToFront(textView)
        self.view.bringSubviewToFront(self.deleteButton)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        guard let journal =  journal  else {return}
        journal.text = self.textView.text
        guard let indexPath = indexPath else {return}
        mainVC?.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
        
        FirebaseManager.shared.update(journal: journal, field: "text") { (success, error) in
            if(success) {
                
            } else {
                
            }
        }
        print("done")
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        guard let journal =  journal  else {return}
        journal.text = self.textView.text
        if textView.text.isEmpty {
            textView.text = "Write a story!"
            textView.textColor = UIColor.lightGray
        }
        
    }
}

extension DetailController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let journal =  journal  else {return}
        if textField.text == "" {
            journal.title = "New Story"
        } else {
            if let text = textField.text {
                journal.title = text
            } else {
                journal.title = "New Story"
            }
            
            FirebaseManager.shared.update(journal: journal, field: "title") { (success, error) in
               if(success) {
                   
               } else {
                   
               }
            }
        }
        self.mainVC?.tableView.reloadData()
        guard let indexPath = indexPath else {return}
        mainVC?.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.clearView.alpha = 1
         
         self.view.bringSubviewToFront(self.parentTextView)
        self.view.bringSubviewToFront(clearView)
        self.view.bringSubviewToFront(self.textField)
        self.view.bringSubviewToFront(self.deleteButton)
    }
    
}


extension DetailController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendationCell", for: indexPath)
        guard let rCell = cell as? RecommendationCell else {return cell}
    
        
        if !recommended {
            rCell.textLabel.text = "Search for a recommendation"
        } else {
            rCell.textLabel.text = recommendations[indexPath.item]
        }
        
        
        rCell.layer.cornerRadius = 5
        
        return rCell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if recommended {
            return CGSize(width: self.collectionView.frame.width/1.2 - 15, height: self.collectionView.frame.height / 3 -  15)
        } else {
            return CGSize(width: self.collectionView.frame.width - 15, height: self.collectionView.frame.height -  15)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if recommended {
            let totalCellWidth = self.collectionView.frame.width/1.2 - 15 * 3
                  let totalSpacingWidth: CGFloat = 10.0

                  let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
                  let rightInset = leftInset

                  return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
        } else {
            return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(recommended) {
            addRecommendation(indexPath: indexPath)
        }
    }
    
    func addRecommendation(indexPath: IndexPath) {
        let recommendedText = recommendations[indexPath.item]
        guard let journal = journal else {return}
        let texts  =  self.textView.text.split(whereSeparator: { (c) -> Bool in
          if (c == "." || c == "!" || c == "\n" || c == "?" ) {
              return true
          }
          return false
      })
         let text = texts.last
            let lastC: String = String(self.textView.text.last!)
         guard let t = text else {return}
        var string: String = ""
        if (t == "") {
            string = String(texts[texts.count - 2])
            if (lastC == "." || lastC == "!" || lastC == "\n" || lastC == "?" ) {
                string = String(texts[texts.count - 2]) + lastC
            }
        } else {
            string = String(texts[texts.count - 1])
        }
        
        let newText  = self.textView.text.replacingLastOccurrenceOfString(string, with: recommendedText)
        journal.text = newText
        self.textView.text = newText
        FirebaseManager.shared.update(journal: journal, field: "text") { (success, string) in
            if(success) {
                
            } else {
                
            }
        }
        makeRecommendation()
    }
    
    
}

 extension UITextView {

    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }

}

extension String
{
    func replacingLastOccurrenceOfString(_ searchString: String,
            with replacementString: String,
            caseInsensitive: Bool = true) -> String
    {
        let options: String.CompareOptions
        if caseInsensitive {
            options = [.backwards, .caseInsensitive]
        } else {
            options = [.backwards]
        }

        if let range = self.range(of: searchString,
                options: options,
                range: nil,
                locale: nil) {

            return self.replacingCharacters(in: range, with: replacementString)
        }
        return self
    }
}
