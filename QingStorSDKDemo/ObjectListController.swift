//
//  ObjectListController.swift
//  QingStorSDKDemo
//
//  Created by Chris on 16/12/29.
//  Copyright © 2016年 Yunify. All rights reserved.
//

import UIKit
import QingStorSDK
import MobileCoreServices

public class ObjectListController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var bucketModel: BucketModel! {
        didSet {
            title = bucketModel.name
            bucketService = QingStor().bucket(bucketName: bucketModel.name!, zone: bucketModel.location!)
        }
    }
    
    fileprivate var bucketService: Bucket!
    fileprivate var listObjectsOutput: ListObjectsOutput?
    
    fileprivate lazy var spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(pickImage))
    }
    
    func setupView() {
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        let refresh = UIRefreshControl()
        refresh.tintColor = .gray
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        refreshControl = refresh
        beginRefresh()
    }
    
    private dynamic func handleRefresh() {
        requestObjectList()
    }
    
    private func requestObjectList() {
        bucketService.listObjects(input: ListObjectsInput()) { response, error in
            if let response = response {
                if response.output.errMessage == nil {
                    self.listObjectsOutput = response.output
                    self.tableView.reloadData()
                } else {
                    print("error: \(response.output.errMessage)")
                }
            } else {
                print("error: \(error)")
            }
            
            self.refreshControl?.endRefreshing()
        }
    }
    
    private dynamic func pickImage() {
        let alertController = UIAlertController(title: "Image Source", message: nil, preferredStyle: .actionSheet)
        let handler: (UIImagePickerControllerSourceType) -> Void = { sourceType in
            let pickerVC = UIImagePickerController()
            pickerVC.view.backgroundColor = .white
            pickerVC.delegate = self
            pickerVC.allowsEditing = true
            pickerVC.sourceType = sourceType
            
            self.present(pickerVC, animated: true, completion: nil)
        }

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(UIAlertAction(title: "Take Photo", style: .`default`) { action in
                handler(.camera)
            })
        }
        
        alertController.addAction(UIAlertAction(title: "Choose from Album", style: .`default`) { action in
            handler(.savedPhotosAlbum)
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func beginRefresh() {
        if !refreshControl!.isRefreshing {
            UIView.animate(withDuration: 0.25, animations: {
                self.tableView.contentOffset = CGPoint(x: 0, y: -self.refreshControl!.frame.size.height - 64)
            }, completion: { finished in
                self.refreshControl?.beginRefreshing()
                self.refreshControl?.sendActions(for: .valueChanged)
            })
        }
    }
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listObjectsOutput?.keys?.count ?? 0;
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectCell", for: indexPath) as? ObjectTableViewCell else { return UITableViewCell() }
        
        let object = listObjectsOutput?.keys?[indexPath.row]
        cell.textLabel?.text = object?.key
        
        return cell
    }
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    override public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let object = listObjectsOutput?.keys?[indexPath.row]
            bucketService.deleteObject(objectKey: object!.key!) { response, error in
                if let response = response {
                    if response.output.errMessage == nil {
                        self.listObjectsOutput?.keys?.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    } else {
                        print("error: \(response.output.errMessage)")
                    }
                } else {
                    print("error: \(error)")
                }
            }
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)

        var contentType: String? = nil
        if let UTI = info[UIImagePickerControllerMediaType], let type = UTTypeCopyPreferredTagWithClass(UTI as! CFString, kUTTagClassMIMEType)?.takeRetainedValue() {
            contentType = type as String
        } else {
            contentType = "image/jpeg"
        }

        var pathExtension = "jpg"
        if let url = info[UIImagePickerControllerReferenceURL] as? URL {
            pathExtension = url.pathExtension.lowercased()
        }

        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            let originRightBarButtonItem = navigationItem.rightBarButtonItem
            
            spinner.startAnimating()
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
            
            let data = UIImageJPEGRepresentation(image, 0.8)!
            let input = PutObjectInput(contentLength: data.count, contentType: contentType, bodyInputStream: InputStream(data: data))
            let key = "\(Int(Date().timeIntervalSince1970)).\(pathExtension)"
            bucketService.putObject(objectKey: key, input: input) { response, error in
                if let response = response {
                    if response.output.errMessage == nil {
                        self.beginRefresh()
                    } else {
                        print("error: \(response.output.errMessage)")
                    }
                } else {
                    print("error: \(error)")
                }
                
                self.navigationItem.rightBarButtonItem = originRightBarButtonItem
            }
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

class ObjectTableViewCell: UITableViewCell {

}
