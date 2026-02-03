import UIKit
import Flutter
import Photos
import ActivityKit // iOS 16.1+

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    private let CHANNEL = "com.aura.app/photos"
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: CHANNEL,
                                              binaryMessenger: controller.binaryMessenger)
        
        channel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "saveToAuraAlbum" {
                 guard let args = call.arguments as? [String: Any],
                       let filePath = args["filePath"] as? String else {
                     result(FlutterError(code: "INVALID_ARGS", message: "Missing filePath", details: nil))
                     return
                 }
                self.saveToAlbum(filePath: filePath, result: result)
            } else if call.method == "startLiveActivity" {
                // Placeholder for ActivityKit logic
                // self.startLiveActivity(status: "Friend is sending...", result: result)
                result(FlutterMethodNotImplemented)
            } else {
                result(FlutterMethodNotImplemented)
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func saveToAlbum(filePath: String, result: @escaping FlutterResult) {
        let albumName = "Aura Moments"
        
        func save() {
            var albumPlaceholder: PHObjectPlaceholder?
            
            // 1. Find or Create Album
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
            let rotation = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            
            if let album = rotation.firstObject {
                // Album exists, save to it
                self.saveImage(filePath: filePath, to: album, result: result)
            } else {
                // Create Album
                PHPhotoLibrary.shared().performChanges({
                    let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
                    albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
                }, completionHandler: { success, error in
                    if success, let placeholder = albumPlaceholder {
                        let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                        if let album = collectionFetchResult.firstObject {
                            self.saveImage(filePath: filePath, to: album, result: result)
                        } else {
                            result(FlutterError(code: "ALBUM_ERROR", message: "Failed to fetch created album", details: nil))
                        }
                    } else {
                        result(FlutterError(code: "CREATE_ALBUM_FAILED", message: error?.localizedDescription, details: nil))
                    }
                })
            }
        }

        // Check Permissions
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized || status == .limited {
            save()
        } else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization { newStatus in
                if newStatus == .authorized || newStatus == .limited {
                    save()
                } else {
                    result(FlutterError(code: "PERMISSION_DENIED", message: "Photo library access denied", details: nil))
                }
            }
        } else {
            result(FlutterError(code: "PERMISSION_DENIED", message: "Photo library access denied", details: nil))
        }
    }
    
    private func saveImage(filePath: String, to album: PHAssetCollection, result: @escaping FlutterResult) {
        PHPhotoLibrary.shared().performChanges({
            let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: URL(fileURLWithPath: filePath))
            
            guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: album),
                  let assetPlaceholder = assetRequest?.placeholderForCreatedAsset else { return }
            
            // Add asset to the album
            albumChangeRequest.addAssets([assetPlaceholder] as NSArray)
            
        }, completionHandler: { success, error in
            if success {
                result(true)
            } else {
                result(FlutterError(code: "SAVE_FAILED", message: error?.localizedDescription, details: nil))
            }
        })
    }
}
