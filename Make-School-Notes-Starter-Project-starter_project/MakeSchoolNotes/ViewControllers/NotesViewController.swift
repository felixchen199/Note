//
//  NotesViewController.swift
//  MakeSchoolNotes
//
//  Created by Martin Walsh on 29/05/2015.
//  Updated by Chris Orcutt on 09/07/2015.
//  Copyright © 2015 MakeSchool. All rights reserved.
//

import RealmSwift
import UIKit

class NotesViewController: UITableViewController {
  
  @IBOutlet weak var searchBar: UISearchBar!
  //@IBOutlet weak var tableView: UITableView!
  
  enum State {
    case DefaultMode
    case SearchMode
  }
  
  var state: State = .DefaultMode{
    didSet {
      switch (state) {
      case .DefaultMode:
        do {
          let realm = try Realm()
          notes = realm.objects(Note).sorted("modificationDate", ascending: false) //1
          self.navigationController!.setNavigationBarHidden(false, animated: true) //2
          searchBar.resignFirstResponder() // 3
          searchBar.text = ""
          searchBar.showsCancelButton = false
        } catch {
          print("realm error")
        }
      case .SearchMode:
        let searchText = searchBar?.text ?? ""
        searchBar.setShowsCancelButton(true, animated: true) //4
        notes = searchNotes(searchText) //5
        self.navigationController!.setNavigationBarHidden(true, animated: true) //6
      }
    }
  }
  
  var notes: Results<Note>! {
    didSet {
        // Whenever notes update, update the table view
        tableView?.reloadData()
    }
  }
  
  var selectedNote: Note?
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view, typically from a nib.
    tableView.dataSource = self;
    tableView.delegate = self;
    searchBar.delegate = self;
    
    do {
        let realm = try Realm()
        notes = realm.objects(Note).sorted("modificationDate", ascending: false)
    } catch {
        print("handle error")
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    do {
      let realm = try Realm()
      notes = realm.objects(Note).sorted("modificationDate", ascending: false)
      state = .DefaultMode
    } catch {
      print("handle error")
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if (segue.identifier == "ShowExistingNote") {
      let noteViewController = segue.destinationViewController as! NoteDisplayViewController
      noteViewController.note = selectedNote
    }
  }
  
  func searchNotes(searchString: String) -> Results<Note>? {
    do {
      let realm = try Realm()
      let searchPredicate = NSPredicate(format: "title CONTAINS[c] %@ OR content CONTAINS[c] %@", searchString, searchString)
      return realm.objects(Note).filter(searchPredicate)
    } catch {
      print("realm error")
      return nil
    }
  }
}

extension NotesViewController {
  
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NoteCell", forIndexPath: indexPath) as! NoteTableViewCell //1
        
        let row = indexPath.row
        let note = notes[row] as Note
        cell.note = note
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes?.count ?? 0
    }
    
    @IBAction func unwindToSegue(segue: UIStoryboardSegue) {
        
        if let identifier = segue.identifier {
            do {
                let realm = try Realm()
                
                switch identifier {
                    
                case "Save":
                    // 1
                    let source = segue.sourceViewController as! NewNoteViewController
                    try realm.write() {
                        realm.add(source.newNote!)
                    }
                case "Delete":
                    try realm.write() {
                        realm.delete(self.selectedNote!)
                    }
                    
                    let source = segue.sourceViewController as! NoteDisplayViewController
                    source.note = nil;
                default:
                    print("No one loves \(identifier)")
                    
                }
                
                // 2
                notes = realm.objects(Note).sorted("modificationDate", ascending: false)
            } catch {
                print("handle error")
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //1
        selectedNote = notes[indexPath.row]
        
        // 2
        self.performSegueWithIdentifier("ShowExistingNote", sender: self)
    }
    
    // 3
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // 4
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let note = notes[indexPath.row] as Object
            
            do {
                let realm = try Realm()
                try realm.write() {
                    realm.delete(note)
                }
                
                notes = realm.objects(Note).sorted("modificationDate", ascending: false)
            } catch {
                print("handle error")
            }
        }
    }
}

extension NotesViewController: UISearchBarDelegate {
  
  func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
    state = .SearchMode
  }
  
  func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    state = .DefaultMode
  }
  
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    notes = searchNotes(searchText)
  }
  
}
