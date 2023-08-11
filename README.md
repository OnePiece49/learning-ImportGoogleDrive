# learning-ImportGoogleDrive

# I. What is oAuth
`OAuth` được viết tắt của `Open Authoriztation`, được sử dụng để cho phép 1 website hoặc 1 application có thể truy cập vào tài nguyên của 1 web app khác. `OAuth 2.0` là 1 authorization protocol and NOT an authentication protocol. Do đó, nó được thiết kế chủ yếu như một phương tiện cấp quyền truy cập vào một tập hợp tài nguyên, chẳng hạn như API từ xa hoặc dữ liệu người dùng.

`OAuth` sử dụng `Access Tokens`. Một `Access Tokens` là 1 phần của dữ liệu  đại diện cho quyền truy cập tài nguyên mà dựa trên user.

# II. Các bước để Authorization GoogleDrive

**B0**: Mở [Enable APIs & Services](https://console.cloud.google.com/apis/api/drive.googleapis.com/metrics?project=import-395603). Sau đó enable `Google Drive`


**B1**: Mở [OAuth consent screen](https://console.cloud.google.com/apis/credentials/consent?project=symbolic-yen-395310) thông qua Link sau hoặc thông qua các bước như. Mở [Google Console](https://console.cloud.google.com/welcome?project=symbolic-yen-395310), sau đó lựa chon `APIs & Services` ở thanh `Menu` và chọn `OAuth consent screen`

**B2:** Vẫn ở `OAuth consent screen`, ta lựa chọn `Publish App`

**B3:** Ta chuyển đến [Credentials](https://console.cloud.google.com/apis/credentials?project=import-395603). Sau đó nhấn `CREATE CREDENTIALS` và lựa chọn `OAuth client ID`. Sau đó ta cần lựa chọn các thông tin cho APP. Sau đó lưu file `.plist`

![](Images/create_oath.png)

**B4:** Khởi tạo `API Keys` bằng cách tương tự như **B3**
VD API: `AIzaSyBbrMA36_nm36NCMiy3pQoLmmxhzROidBI`

Sau đây là các bước tiến hành trong Code để yêu cầu quyền truy cập:

```swift
pod 'GoogleAPIClientForREST/Drive', '~> 1.2.1'
pod 'GoogleSignIn', '~> 4.1.1'
```

**B5:** Ta sẽ tìm `YOUR_REVERSED_CLIENT_ID` và `YOUR_CLIENT_ID` trong file `client.plist` đã lưu ở trên và dán lần lượt vào đây:

![](Images/reverse.png)

và 

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    GIDSignIn.sharedInstance().clientID = "YOUR_CLIENT_ID"
    return true
}
```

- Để có thể đăng nhập vào GoogleDrive, ta sử dụng `GIDSignInButton()`. Sau khi đã đăng nhập lần đầu, hoặc chưa signOut(), thì ta có thể sử dụng đoạn code sau để login.
```swift
private func setupGoogleSignIn() {
    GIDSignIn.sharedInstance().delegate = self
    GIDSignIn.sharedInstance().uiDelegate = self
    GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeDrive]
    GIDSignIn.sharedInstance()?.signInSilently()
    
}
```

Chú ý: Đoạn code này được sử dụng khi user đã đăng nhập vào các lần sau khi đã được login hoặc chưa signOut(). Khi user đã SignOut(), ta bắt buộc phải để user nhấn Button thuộc kiểu `GIDSignInButton` để đăng nhập lại.

# III. Get, Search Data from GoogleDrive

Để có thể access data của GGDrive, ta cần 1 biến `service` thuộc kiểu `GTLRDriveService().`

Để có thể access vào data, ta cần gán giá trị cho 2 properties của biến `service` đó là `apiKey` và `authorizer`(Chú ý rằng `APIKey` ta đã lấy ở phần `II B4.`)

```swift
let service = GTLRDriveService()
service.apiKey = "AIzaSyCXWVwY4a0OexdDyaYEWGxlWgKJ0AvaPv4"
service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
```

- Searching Data:

```swift
public func listFiles(_ nameFolder: String, token: String? = nil) {
    let root = "(mimeType = 'video/mp4' or mimeType = 'audio/mpeg') or (name contains '\(nameFolder)')"
    
    let query = GTLRDriveQuery_FilesList.query()
    query.pageSize = 100
    query.q = root
    query.pageToken = token
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
```

Ở đây ta lấy ra mọi files có kiểu mp4 và mp3, và cũng với file có tên trùng với `nameFolder`. Khi ta lấy được `data`, thì `data` sẽ có 1 thuộc tính là `nextPageToken`. Ta có thể sử dụng biến token này để lấy các files đằng sau. Vì max số lượng file lấy được 1 lần là 100 files, nên nó sẽ chia theo từng pageToken. 

- DownloadData:

```swift
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
```

Chú ý: `Id` được lấy từ phần searching kia bằng code, hoặc có thể lấy 1 cách thủ công bằng cách shareLink, ví dụ khi ta share 1 file và có link như này `https://drive.google.com/file/d/18_qa4BWjgn1PsQpD4_GeRDC0dwcR6z2e/view?usp=drive_link` thì `id` chính là `18_qa4BWjgn1PsQpD4_GeRDC0dwcR6z2e`.