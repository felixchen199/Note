//
//  NoteDisplayViewController.swift
//  MakeSchoolNotes
//
//  Created by HeFeng on 2015-12-08.
//  Copyright © 2015 Chris Orcutt. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import ConvenienceKit

class NoteDisplayViewController: UIViewController {

  @IBOutlet weak var titleTextField: UITextField!
  @IBOutlet weak var contentTextView: UITextView!
  @IBOutlet weak var deleteButton: UIBarButtonItem!
  @IBOutlet weak var toolbarBottomSpace: NSLayoutConstraint!
  var keyboardNotificationHandler: KeyboardNotificationHandler?
  var edit = false
  var note: Note? {
      didSet {
          displayNote(note)
      }
  }
    
  func displayNote(note: Note?) {
    if let note = note, titleTextField = titleTextField, contentTextView = contentTextView  {
      titleTextField.text = note.title
      contentTextView.text = note.content
      if note.title.characters.count == 0 && note.content.characters.count == 0 {
        titleTextField.becomeFirstResponder()
      }
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    saveNote()
  }
  
  func saveNote() {
    if let note = note {
      do {
        let realm = try Realm()
        
        try realm.write {
          if (note.title != self.titleTextField.text || note.content != self.contentTextView.text) {
            note.title = self.titleTextField.text!
            note.content = self.contentTextView.text
            note.modificationDate = NSDate()
          }
        }
        
      } catch {
        print("handle error")
      }
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    self.navigationController!.setNavigationBarHidden(false, animated: true)
    
    displayNote(note)
    // 1
    titleTextField.returnKeyType = .Next
    // 2
    titleTextField.delegate = self
    
    keyboardNotificationHandler = KeyboardNotificationHandler()
    
    
    keyboardNotificationHandler!.keyboardWillBeHiddenHandler = { (height: CGFloat) in
      UIView.animateWithDuration(0.3){
        self.toolbarBottomSpace.constant = 0
        self.view.layoutIfNeeded()
      }
    }
    
    keyboardNotificationHandler!.keyboardWillBeShownHandler = { (height: CGFloat) in
      UIView.animateWithDuration(0.3) {
        self.toolbarBottomSpace.constant = height
        self.view.layoutIfNeeded()
      }
    }
    
    if edit {
      deleteButton.enabled = false
    }
  }
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension NoteDisplayViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    
    if (textField == titleTextField) {  //1
      contentTextView.returnKeyType = .Done
      contentTextView.becomeFirstResponder()
    }
    
    return false
  }
}
