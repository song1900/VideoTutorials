//
//  RootViewController.swift
//  VideoTutorials
//
//  Created by 송우진 on 2021/02/10.
//

import UIKit

class RootViewController: UIViewController {
    
    // MARK: - Properties
    lazy var selectAndPlayButton: UIButton = {
        let bt = UIButton()
        bt.setTitle("Select And Play Video", for: .normal)
        bt.setTitleColor(.blue, for: .normal)
        bt.layer.borderWidth = 1.0
        bt.heightAnchor.constraint(equalToConstant: 40).isActive = true
        bt.addTarget(self, action: #selector(actionSelectAndPlay), for: .touchUpInside)
        return bt
    }()
    
    lazy var recordAndSaveButton: UIButton = {
        let bt = UIButton()
        bt.setTitle("Record And Save Video", for: .normal)
        bt.setTitleColor(.blue, for: .normal)
        bt.layer.borderWidth = 1.0
        bt.heightAnchor.constraint(equalToConstant: 40).isActive = true
        bt.addTarget(self, action: #selector(actionRecrodAndSave), for: .touchUpInside)
        return bt
    }()
    
    lazy var mergeButton: UIButton = {
        let bt = UIButton()
        bt.setTitle("Merge Video", for: .normal)
        bt.setTitleColor(.blue, for: .normal)
        bt.layer.borderWidth = 1.0
        bt.heightAnchor.constraint(equalToConstant: 40).isActive = true
        bt.addTarget(self, action: #selector(actionMerge), for: .touchUpInside)
        return bt
    }()
    
    private lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [selectAndPlayButton, recordAndSaveButton, mergeButton])
        sv.axis = .vertical
        sv.spacing = 50
        return sv
    }()
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configure()
    }
    
    // MARK: - Configure
    func configure() {
        view.backgroundColor = .systemBackground
        
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        stackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        
  
    }
    
    // MARK: - Actions
    @objc func actionSelectAndPlay() {
        let playVC = PlayViewController()
        navigationController?.pushViewController(playVC, animated: true)
    }
    
    @objc func actionRecrodAndSave() {
        let recordVC = RecordVideoViewController()
        navigationController?.pushViewController(recordVC, animated: true)
    }

    
    @objc func actionMerge() {
        let mergeVC = MergeVideoViewController()
        navigationController?.pushViewController(mergeVC, animated: true)
    }
    
}
