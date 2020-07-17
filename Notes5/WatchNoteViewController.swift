//
//  WatchNoteViewController.swift
//  Notes5
//
//  Created by Полина on 11.07.2020.
//  Copyright © 2020 Полина. All rights reserved.
//

import UIKit

protocol WatchNoteViewControllerDelegate: AnyObject {
    func save(note: Note)
}

class WatchNoteViewController: UIViewController {
    
    var note: Note
    weak var delegate: WatchNoteViewControllerDelegate?
    
    init(note: Note) {
        self.note = note
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var nameOfNote: UILabel!
    @IBOutlet weak var timeOfNote: UILabel!
    @IBOutlet weak var descrOfNote: UITextView!
    
    @objc func editNote(_ sender: Any) {
        let editViewController = EditViewController(note: note)
        editViewController.delegate = self
        navigationController?.pushViewController(editViewController, animated: true)
    }
    
    @objc func backToNotes(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "Просмотр"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Редактировать", style: .plain, target: self, action: #selector(WatchNoteViewController.editNote))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: self, action: #selector(WatchNoteViewController.backToNotes))
        let calendar = Calendar.current
        self.timeOfNote.text = "Создано в "+String(calendar.component(.hour, from: note.dateTime))+":"+String(calendar.component(.minute, from: note.dateTime))
        updateData()
    }
    
    private func updateData() {
        self.nameOfNote.text = note.name
        self.descrOfNote.text = note.descr
    }
}

extension WatchNoteViewController: EditNoteViewControllerDelegate {
    func save(note: Note) {
        self.note = note
        updateData()
        delegate?.save(note: note)
    }
    
}

