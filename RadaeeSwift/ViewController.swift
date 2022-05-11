//
//  ViewController.swift
//  RadaeeSwift
//
//  Created by Emanuele Bortolami on 11/01/17.
//  Copyright © 2017 GEAR.it. All rights reserved.
//

import UIKit

class ViewController: UIViewController, RadaeePDFPluginDelegate {
    
    //NEEDED to retain the object for delegate methods
    var plugin: RadaeePDFPlugin!
    var externalUrl: String! = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    // MARK: Reader methods
    
    func pluginInit() -> RadaeePDFPlugin {
        
        let company: String = "Radaee"
        let email: String = "radaee_com@yahoo.cn"
        let key: String = "89WG9I-HCL62K-H3CRUZ-WAJQ9H-FADG6Z-XEBCAO"
        let type: Int32 = 2
        
        //Reader settings init
        plugin = RadaeePDFPlugin()
        
        //Activate license
        plugin.activateLicense(withBundleId: Bundle.main.bundleIdentifier, company: company, email: email, key: key, licenseType: type)
        
        //General settings
      
        //Set thumbnail view background
        plugin.setThumbnailBGColor(self.colorBitPattern(color: UIColor.init(white: 0, alpha: 0.2))) //AARRGGBB
        
        //Set reader background
        plugin.setReaderBGColor(self.colorBitPattern(color: UIColor.lightGray)) //AARRGGBB
        
        //Set thumbnail view height
        plugin.setThumbHeight(100);
        
        return plugin
    }
    
    @IBAction func ShowReader(_ sender: Any) {
        //Copy file to custom path (in this case is ../Library/customFolder/test.pdf
        let path: String = self.copyToCustomFolder(path: Bundle.main.path(forResource: "help", ofType: "pdf")!)
        
        //let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        //let path: String = documentsPath + "/help.pdf"
        
        
        let plugin: RadaeePDFPlugin = self.pluginInit()
        plugin.setDelegate(self);
        
        // Global properties (render mode, markup colors...)
        // Info: global.g_ink_color replaced "setColor forFeature"
        
        /*
         * 0: Vertical
         * 1: Horizontal LTOR
         * 2: Page Curling
         * 3: Single Page (LTOR, paging enabled)
         * 4: Double Page (LTOR, paging enabled)
         */
        
        RDVGlobal.sharedInstance().g_render_mode = 0
        
        //OPEN method
        
        //Create Reader instance from Bundle (readonly)
        //let reader = plugin.open(fromAssets: "test.pdf", withPassword: "")
        
        //Create Reader instance from custom path
        let reader = plugin.show(path, withPassword: "")
        
        if (reader != nil) {
            
            let vc: UIViewController = reader as! UIViewController
            
            //Title bar inherits the Navigation barTintColor
            self.navigationController?.navigationBar.barTintColor = UIColor.black
            self.navigationController?.navigationBar.isTranslucent = false;
            
            //Icons inherit the Navigation tintColor
            self.navigationController?.navigationBar.tintColor = UIColor.orange
            
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            let alert = UIAlertController(title: "Warning", message: "Cannot open the reader, please check the file path", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: Path Utils
    
    //Returns Documents folder path
    func getDocumentsFolder() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
    
    //Returns Library folder path
    func getLibraryFolder() -> String {
        return NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
    }
    
    //Returns Custom folder path
    func getCustomFolder() -> String {
        let libraryPath = self.getLibraryFolder()
        let customFolder = (libraryPath as NSString).appendingPathComponent("customFolder")
        
        return customFolder
    }
    
    //Create Custom folder
    func createCustomFolder() {
        do {
            try FileManager.default.createDirectory(atPath: self.getCustomFolder(), withIntermediateDirectories: false, attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }
    
    //Copy item to Custom folder (also create the folder if not exist)
    func copyToDocuments(path:String) {
        
        let documentsPath = self.getDocumentsFolder()
        let filePath = (documentsPath as NSString).appendingPathComponent((path as NSString).lastPathComponent)
        
        do {
            try FileManager.default.copyItem(atPath: path, toPath: filePath)
        } catch let error as NSError {
            print("An error occurred: \(error)")
        }
        
    }
    
    func copyToCustomFolder(path:String) -> String {
        
        let customPath = self.getCustomFolder()
        let filePath = (customPath as NSString).appendingPathComponent((path as NSString).lastPathComponent)
        
        //Create customFolder if not exist
        if !FileManager.default.fileExists(atPath: customPath) {
            self.createCustomFolder()
        }
        
        do {
            try FileManager.default.copyItem(atPath: path, toPath: filePath)
        } catch let error as NSError {
            print("An error occurred: \(error)")
        }
        
        //If the file exists, return the whole path
        if FileManager.default.fileExists(atPath: filePath){
            return filePath
        }
        
        return ""
    }
    
    // MARK: RadaeePDFPluginDelegate
    
    func willShowReader() {
        print("willShowReader")
    }
    
    func didShowReader() {
        print("didShowReader")
    }
    
    func willCloseReader() {
        print("willCloseReader")
    }
    
    func didCloseReader() {
        print("didCloseReader")
    }
    
    func didChangePage(_ page: Int32) {
        print("page: \(page)")
    }
    
    func didSearchTerm(_ term: String!, found: Bool) {
        if found {
            print("Found term: \(String(describing: term))")
            
            //Example: show alert from delegate method
            /*
             let alert = UIAlertController(title: "Notice", message: "\(term) found", preferredStyle: UIAlertControllerStyle.alert)
             alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
             self.present(alert, animated: true, completion: nil)
             */
        } else {
            print("\"\(String(describing: term))\" not found")
        }
    }
    
    func didTap(onPage page: Int32, at point: CGPoint) {
        print("Did tap on page: \(page) at point: x: \(point.x) y: \(point.y)")
    }
    
    func didTap(onAnnotationOfType type: Int32, atPage page: Int32, at point: CGPoint) {
        print("Did tap on annotation of type: \(type) at point: x: \(point.x) y: \(point.y)")
    }
    
    func didDoubleTap(onPage page: Int32, at point: CGPoint) {
        print("Did double tap on page: \(page) at point: x: \(point.x) y: \(point.y)")
    }
    
    func didLongPress(onPage page: Int32, at point: CGPoint) {
        print("Did long press on page: \(page) at point: x: \(point.x) y: \(point.y)")
    }
    
    func onAnnotExported(_ path: String!) {
        print("Did export to path: \(String(describing: path))")
    }
    
    // MARK: Cast Utils
    
    //Cast from UIColor to int value
    func colorBitPattern(color: UIColor) -> Int32 {
        // read colors to CGFloats and convert and position to proper bit positions in UInt32
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            
            var colorAsUInt: UInt32 = 0
            colorAsUInt += UInt32(red * 255.0) << 16 +
                UInt32(green * 255.0) << 8 +
                UInt32(blue * 255.0) +
                UInt32(alpha * 255.0) << 24
            
            return Int32(bitPattern: UInt32(colorAsUInt))
        }
        // return default color
        return Int32(bitPattern: UInt32(0xFF000000)) //Black Color
    }
}

