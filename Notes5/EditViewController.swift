//
//  EditViewController.swift
//  Notes5
//
//  Created by Полина on 11.07.2020.
//  Copyright © 2020 Полина. All rights reserved.
//

import UIKit

protocol EditNoteViewControllerDelegate: AnyObject {
    func save(note: Note)
}

class EditViewController: UIViewController, UITextFieldDelegate {
    
    var note: Note
    weak var delegate: EditNoteViewControllerDelegate?
    
    init(note: Note?) {
        let dateTime = Date()
        self.note = note ?? Note(id: UUID().uuidString, name: "", descr: "", dateTime:dateTime)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var currNameOfNote: UITextField!
    @IBOutlet weak var currDescrOfNote: UITextView!
    
    
    @objc func backToNote(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func saveAndClose(_ sender: Any) {
        if (self.currNameOfNote.text?.isEmpty ?? false || self.currDescrOfNote.text?.isEmpty ?? false) {
            let alert = UIAlertController(title: "Ошибка", message: "Некорректные данные (пустая строка)", preferredStyle: .alert)
            let okBtn = UIAlertAction(title: "Ок", style: .default, handler: dismissAfterAlert)
            alert.addAction(okBtn)
            present(alert, animated: true, completion: nil)
        }
        else {
            let newNote = Note(id: note.id, name: self.currNameOfNote.text!, descr: self.currDescrOfNote.text!, dateTime: note.dateTime)
            delegate?.save(note: newNote)
            if let navstack = self.navigationController?.viewControllers{
                let wc = WatchNoteViewController(note: newNote)
                if #available(iOS 11.0, *) {
                    let viewController = navstack.first as! ViewController
                    wc.delegate = viewController
                    let newstack: [UIViewController] = [viewController, wc]
                    self.navigationController?.setViewControllers(newstack, animated: true)
                }
            }
        }
    }
    
    func dismissAfterAlert(btn: UIAlertAction) -> Void {
        dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            currDescrOfNote.contentInset = .zero
        } else {
            if #available(iOS 11.0, *) {
                currDescrOfNote.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
            }
        }

        currDescrOfNote.scrollIndicatorInsets = currDescrOfNote.contentInset

        let selectedRange = currDescrOfNote.selectedRange
        currDescrOfNote.scrollRangeToVisible(selectedRange)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сохранить", style: .plain, target: self, action: #selector(EditViewController.saveAndClose))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: self, action: #selector(EditViewController.backToNote))
        self.currNameOfNote.text = note.name
        self.currDescrOfNote.text = note.descr
        if (self.currDescrOfNote.text == "") {
            self.currDescrOfNote.placeholder = "Текст заметки"
        }
    }
}

extension EditViewController: WatchNoteViewControllerDelegate {
    func save(note: Note) {
        self.note = note
    }
}
