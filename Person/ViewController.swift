//
//  ViewController.swift
//  Person
//
//  Created by Ekaterina Akchurina on 29.09.2020.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    var people = [Person]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load the array
        let defaults = UserDefaults.standard
        if let savedPeople = defaults.object(forKey: "people") as? Data {
            if let decodedPeople = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPeople) as? [Person] {
                people = decodedPeople
            }
        }// Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
    }
    
    // MARK: - collectionView methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue PersonCell")
        }
        
        let currentPerson = people[indexPath.item]
        cell.name.text = currentPerson.name
        
        let path = getDocumentsDirectory().appendingPathComponent(currentPerson.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var selectedPerson = people[indexPath.item]
        
        let selectAC = UIAlertController(title: "Choose action", message: nil, preferredStyle: .alert)
        selectAC.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] action in
            self?.people.remove(at: indexPath.item)
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                self?.save()
            }
        }))
        
        selectAC.addAction(UIAlertAction(title: "Rename", style: .default, handler: { [weak self] action in
            let nameAC = UIAlertController(title: "Type the name", message: nil, preferredStyle: .alert)
            nameAC.addTextField(configurationHandler: nil)
            nameAC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            nameAC.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak nameAC, weak self]  action in
                guard let text = nameAC?.textFields?[0].text else {return}
                selectedPerson.name = text
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                    self?.save()
                }
            }))
            self?.present(nameAC, animated: true, completion: nil)
        }))
        
        present(selectAC, animated: true, completion: nil)
    }
    // MARK: - add new picture
    @objc func addNewPerson(){
        let picker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
            }
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {return}
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        save()
        collectionView.reloadData()
        dismiss(animated: true, completion: nil)
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    func save() {
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: people, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "people")
        }
    }



}

