//
//  ViewController.swift
//  WantedConcurrency
//
//  Created by 김동준 on 2023/03/01.
//

import UIKit

final class ViewController: UIViewController {
    private let photoUrls: [String] = ["https://picsum.photos/200/300", "https://picsum.photos/200/300", "https://picsum.photos/200/300", "https://picsum.photos/200/300", "https://picsum.photos/200/300"]
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        tableView.register(ImageDownCell.self, forCellReuseIdentifier: ImageDownCell.id)
        return tableView
    }()
    
    private let loadAllImage: UIButton = {
        let button = UIButton(frame: CGRect(x: 20.0, y: UIScreen.main.bounds.height - 100, width: UIScreen.main.bounds.width - 40, height: 40))
        button.setTitle("Load All Images", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        return button
    }()
    
    private let loadImages: ((String, UIImageView) -> ()) = { url, imageView in
        guard let url = URL(string: url) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            let fetchedImage = UIImage(data: data)
            DispatchQueue.main.async {
                imageView.image = fetchedImage
            }
        }.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewAttribute()
    }
    
    private func viewAttribute() {
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        view.addSubview(tableView)
        view.addSubview(loadAllImage)
    }
}
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImageDownCell.id) as? ImageDownCell else { return UITableViewCell() }
        cell.configuration(with: photoUrls[indexPath.item], loadImages: loadImages)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
}

final class ImageDownCell: UITableViewCell {
    static let id = String(describing: ImageDownCell.self)
    
    private let customImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 20.0, y: 20.0, width: 80, height: 60))
        imageView.image = UIImage.imageIcon
        return imageView
    }()
    
    private let loadButton: UIButton = {
        let button = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 100, y: 35.0, width: 80, height: 30))
        button.setTitle("load", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.isUserInteractionEnabled = true
        return button
    }()
    
    private let processView: UIProgressView = {
        let processView = UIProgressView(frame: CGRect(x: 100, y: 50.0, width: 200, height: 10))
        processView.progress = 0.5
        processView.trackTintColor = .systemGray4
        return processView
    }()
    
    private var loadImages: ((String, UIImageView) -> ())?
    private var url = ""
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        viewAttribute()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    override func prepareForReuse() {
        customImageView.image = UIImage.imageIcon
        loadImages = nil
        url = ""
    }
    
    private func viewAttribute() {
        contentView.addSubview(customImageView)
        contentView.addSubview(processView)
        contentView.addSubview(loadButton)
        
        loadButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            self.customImageView.image = UIImage.imageIcon
            self.loadImages?(self.url, self.customImageView)
        }), for: .touchUpInside)
    }
    
    func configuration(with url: String, loadImages: @escaping (String, UIImageView) -> ()) {
        self.url = url
        self.loadImages = loadImages
    }
}
extension UIImage {
    static let imageIcon = UIImage(systemName: "photo")
}
