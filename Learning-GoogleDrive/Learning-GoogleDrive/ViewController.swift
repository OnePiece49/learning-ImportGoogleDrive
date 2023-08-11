//
//  ViewController.swift
//  Learning-GoogleDrive
//
//  Created by Tiến Việt Trịnh on 11/08/2023.
//

import UIKit

import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher


class ViewController: UIViewController {
    
    //MARK: - Properties
    fileprivate let service = GTLRDriveService()
    
    //MARK: - UIComponent
    let button = GIDSignInButton(frame: .zero)
    
    private lazy var signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SignIn", for: .normal)
        button.tintColor = .black
        
        button.addTarget(self, action: #selector(handleSignInButtonTapped), for: .touchUpInside)
        return button
    }()
    

    
    private lazy var signOutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SignOut", for: .normal)
        button.tintColor = .black
        
        button.addTarget(self, action: #selector(handleSignOutButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("get Data", for: .normal)

        button.addTarget(self, action: #selector(handleSearchButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func handleSearchButtonTapped() {
        listFiles("240742351_244197850803598_8758922099910121959_n.png")
        downloadData(id: "18_qa4BWjgn1PsQpD4_GeRDC0dwcR6z2e")
    }
    
    @objc func handleSignInButtonTapped() {
        setupGoogleSignIn()
    }
    
    @objc func handleSignOutButtonTapped() {
        GIDSignIn.sharedInstance().signOut()
    }
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setupGoogleSignIn()
    }
    
    func configureUI() {
        view.backgroundColor = .red
        view.addSubview(button)
        view.addSubview(signInButton)
        view.addSubview(signOutButton)
        view.addSubview(searchButton)
        
        
        button.frame = .init(x: 50, y: 100, width: 300, height: 100)
        signInButton.frame = .init(x: 50, y: 200, width: 300, height: 100)
        signOutButton.frame = .init(x: 50, y: 300, width: 300, height: 100)
        searchButton.frame = .init(x: 50, y: 400, width: 300, height: 100)
        service.apiKey = "AIzaSyBbrMA36_nm36NCMiy3pQoLmmxhzROidBI"
    }
    
}

//MARK: - Method
extension ViewController {
    
    //MARK: - Helpers
    private func setupGoogleSignIn() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeDrive]
//        GIDSignIn.sharedInstance()?.signInSilently()
        GIDSignIn.sharedInstance().signIn()
    }
    
    //MARK: - Selectors
    
}


extension ViewController: GIDSignInDelegate, GIDSignInUIDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("DEBUG: \(error.localizedDescription)")
        } else {
            print("DEBUG: \(String(describing: user.profile.email))")
            service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
            print("Authenticate successfully")
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Did disconnect to user")
        
    }
    
    public func listFiles(_ folderID: String) {
        let root = "(mimeType = 'video/mp4' or mimeType = 'audio/mpeg') or (name contains '\(folderID)')"
        
        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 100
        query.q = root
        query.pageToken
        query.fields = "files(id,name,mimeType,modifiedTime,fileExtension,size,iconLink, thumbnailLink, hasThumbnail),nextPageToken"
        
        service.executeQuery(query)  { ticker, result, error in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            
            let data = result as! GTLRDrive_FileList
            print("DEBUG: \(String(describing: data.files?.count))")
            
            data.files?.forEach({ file in
                print("DEBUG: \(String(describing: file.name))")
            })
            print("DEBUG: \(String(describing: data.files?[1].identifier)) and \(String(describing: data.files?[1].name))")
            
        }
    }
    
    private func downloadData(id: String) {
        let query = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: id)

        
        service.executeQuery(query) { ticker, result, error in
            guard let result = result as? GTLRDataObject else {
                print("DEBUG: failed \(String(describing: result)) ")

                return
            }
            print("DEBUG: \(String(describing: result.contentType))")
            let filename = URL.videoEditorFolder()?.appendingPathComponent("Siuuuu.mp4")
            try? result.data.write(to: filename!)
            print("DEBUG: \(String(describing: URL.videoEditorFolder()))")
        }
    }
}
