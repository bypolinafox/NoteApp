//
//  ViewController.swift
//  Notes5
//
//  Created by Полина on 11.07.2020.
//  Copyright © 2020 Полина. All rights reserved.
//

import UIKit
import RealmSwift


class Note: Object {
    @objc dynamic var id : String = ""
    @objc dynamic var name : String = ""
    @objc dynamic var descr : String = ""
    @objc dynamic var dateTime : Date = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    init(id: String, name: String, descr: String, dateTime: Date) {
        self.id = id
        self.name = name
        self.descr = descr
        self.dateTime = dateTime
    }
    
    required init() {}
}

@available(iOS 11.0, *)
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let realm = try! Realm()
    var items : Results<Note>!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items.count != 0 {
            return items.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellID")
        let item = items[indexPath.row]
        let dateTime = item.dateTime
        let calendar = Calendar.current
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = String(calendar.component(.day, from: dateTime))+"."+String(calendar.component(.month, from: dateTime))+"."+String(calendar.component(.year, from: dateTime))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row < items.count else {
            return
        }
        let noteFromDb = items[indexPath.row]
        showWatchNoteViewController(note: noteFromDb)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let editingRow = items[indexPath.row]
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            try! self.realm.write {
                self.realm.delete(editingRow)
            }
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        action.backgroundColor = .red
        return action
    }
    
    func showWatchNoteViewController(note: Note) {
        let watchNoteViewController = WatchNoteViewController(note: note)
        watchNoteViewController.delegate = self
        self.navigationController?.pushViewController(watchNoteViewController, animated: true)
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func makeNote(_ sender: Any) {
        let editViewController = EditViewController(note: nil)
        editViewController.delegate = self
        self.navigationController?.pushViewController(editViewController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        items = realm.objects(Note.self).sorted(byKeyPath: "dateTime", ascending: false)
    }
}

@available(iOS 11.0, *)
extension ViewController: WatchNoteViewControllerDelegate, EditNoteViewControllerDelegate {
    func save(note: Note) {
        try! realm.write {
            realm.add(note, update: .modified)
        }
        
        items = items!.sorted(byKeyPath: "dateTime", ascending: false)
        self.tableView.reloadData()
    }
}

