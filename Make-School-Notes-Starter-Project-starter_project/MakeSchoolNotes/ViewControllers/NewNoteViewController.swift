//
//  NewNoteViewController.swift
//  MakeSchoolNotes
//
//  Created by HeFeng on 2015-12-06.
//  Copyright © 2015 Chris Orcutt. All rights reserved.
//

import UIKit

class NewNoteViewController: UIViewController {

    var newNote: Note?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
      if (segue.identifier == "ShowNewNote") {
        // create a new Note and hold onto it, to be able to save it later
        newNote = Note()
        let noteViewController = segue.destinationViewController as! NoteDisplayViewController
        noteViewController.note = newNote
        noteViewController.edit = true
      }
        
    }
    

}
