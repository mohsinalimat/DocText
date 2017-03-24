//
//  FileUtils.swift
//  Dr.Text
//
//  Created by SoftSuave on 24/01/17.
//  Copyright © 2017 SoftSuave. All rights reserved.
//

import UIKit

class FileUtils: NSObject {
    
    class func getUniqueFileName(fileType: String) -> String {
        let date = Date()
        let timeInterval = date.timeIntervalSince1970 * 1000
        let dateString = String(timeInterval)
        
        var fileName = dateString
        fileName = "\(Utils.user.id)_\(fileType)_\(fileName)"
        return fileName
    }
    
    class func getMediaPath() -> String? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths.first
        let path = documentsDirectory?.stringByAppendingPathComponent(path: "Media")
        
        if !FileManager.default.fileExists(atPath: path!) {
            do {
                try FileManager.default.createDirectory(atPath: path!, withIntermediateDirectories: false, attributes: nil)
                return path
            } catch {
                print("Exception occured while creating directory...")
                return path
            }
        }
        
        return path
    }
    
    class func getImageFilePath(fileName: String) -> String? {
        let component = fileName.components(separatedBy: "/")
        
        let folderPath = FileUtils.getMediaPath()
        let imageFolderPath = folderPath?.stringByAppendingPathComponent(path: "Image")
        
        if !FileManager.default.fileExists(atPath: imageFolderPath!) {
            do {
                try FileManager.default.createDirectory(atPath: imageFolderPath!, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print("Exception occured while creating image file directory... \(error)")
            }
        }
        
        let imagePath = imageFolderPath?.stringByAppendingPathComponent(path: component.last!)
        return imagePath
    }
    
    class func getAudioFilePath(fileName: String) -> String? {
        
        let folderPath = FileUtils.getMediaPath()
        
        let audioPath = folderPath?.stringByAppendingPathComponent(path: "\(fileName).m4a")
        return audioPath
    }
    
    class func getVideoFilePath(fileName: String) -> String? {
        
        let folderPath = FileUtils.getMediaPath()      
        let videoPath = folderPath?.stringByAppendingPathComponent(path: "\(fileName).mov")
        return videoPath
    }
    
    class func IsImageFileExists(fileName: String?) -> Bool {
        if let name = fileName {
            let filePath = self.getImageFilePath(fileName: name)
            return FileManager.default.fileExists(atPath: filePath!)
        } else {
            return false
        }
    }
    
    class func IsAudioFileExists(fileName: String?) -> Bool {
        if let name = fileName {
            let filePath = self.getAudioFilePath(fileName: name)
            return FileManager.default.fileExists(atPath: filePath!)
        } else {
            return false
        }
    }
    
    class func IsVideoFileExists(fileName: String?) -> Bool {
        if let name = fileName {
            let filePath = self.getVideoFilePath(fileName: name)
            return FileManager.default.fileExists(atPath: filePath!)
        } else {
            return false
        }
    }
    
    
    class func saveImageAtFileName(image: UIImage, fileName: String) {
        let imageFilePath = self.getImageFilePath(fileName: fileName)
        let url = URL(string: "file://\(imageFilePath!)")
        if !FileManager.default.fileExists(atPath: imageFilePath!) {
            let imageData = UIImagePNGRepresentation(image)
            
            do {
                try imageData?.write(to: url!, options: .atomic)
                if imageData != nil {
                    print("Saved at local in \(url)")
                } else {
                    print("Not saved...")
                }
            } catch {
                print(error)
            }
        }
    }

    class func saveVideoAtFileName(data: NSData, fileName: String) -> String?  {
        let videoFilePath = self.getVideoFilePath(fileName: fileName)
        let url = URL(string: "file://\(videoFilePath!)")
        print("Video url: \(url)")
        if !FileManager.default.fileExists(atPath: videoFilePath!) {
            do {
                try data.write(to: url!, options: .atomic)
                return url?.absoluteString
            } catch let error as NSError {
                print("Exception occured whil storing file to local...: \(error.localizedDescription)")
                return nil
            }
        }        
        return nil
    }

    class func saveAudioAtFileName(data: NSData, fileName: String) -> String? {
        let audioFilePath = self.getAudioFilePath(fileName: fileName)
        let url = URL(string: "file://\(audioFilePath!)")
        print("Video url: \(url)")
        if !FileManager.default.fileExists(atPath: audioFilePath!) {
            do {
                try data.write(to: url!, options: .atomic)
                return url?.absoluteString
            } catch let error as NSError {
                print("Exception occured whil storing file to local...: \(error.localizedDescription)")
                return nil
            }
        }
        return nil
    }

    class func getImage(fileName: String) -> UIImage? {
        if self.IsImageFileExists(fileName: fileName) {
            let filePath = self.getImageFilePath(fileName: fileName)
            let image = UIImage(contentsOfFile: filePath!)
            return image
        }
        
        return nil
    }
    
    class func removeAllFiles() {
        if let path = self.getMediaPath() {
            print(path)
            if FileManager.default.fileExists(atPath: path) {
                do {
                    return try FileManager.default.removeItem(atPath: path)
                }
                catch let error as NSError {
                    print("Ooops! Something went wrong: \(error)")
                }
            }
        }
    }
}


extension String {
    func stringByAppendingPathComponent(path: String) -> String {
        let nsSt = self as NSString
        return nsSt.appendingPathComponent(path)
    }
}
