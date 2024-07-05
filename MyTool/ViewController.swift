//
//  ViewController.swift
//  MyTool
//
//  Created by Kavisha Rajapaksha on 05.07.24.
//

import Cocoa

class ViewController: NSViewController {
    
    
    @IBOutlet weak var SNT: NSTextField!
    @IBOutlet weak var ModeT: NSTextField!
    @IBOutlet weak var vert: NSTextField!
    @IBOutlet weak var ACTT: NSTextField!
    
    
    @IBAction func GetDeviceInfoBTN(_ sender: Any) {
        self.GetDEV()
    }
    
    @IBAction func Step1(_ sender: Any) {
        self.PutDevMode()
    }
    
    
    @IBAction func Step2(_ sender: Any) {
        self.PostReq()
    }
    
    @IBAction func Step3(_ sender: Any) {
        self.curl()
    }
    
    
    @IBAction func step4(_ sender: Any) {
        self.openFileFromFinder()
    }
    
    func GetDEV() -> Int32 {
         let output = executeCommand(command: "cd /usr/local/bin/ && ./ideviceinfo | grep -w SerialNumber: | cut -d ' ' -f 2-")
            print(output)
            self.SNT.stringValue = "\(output)"
    
        let output2 = executeCommand(command: "cd /usr/local/bin/ && ./ideviceinfo | grep -w HardwareModel: | cut -d ' ' -f 2-")
           print(output2)
           self.ModeT.stringValue = "\(output2)"
        let output3 = executeCommand(command: "cd /usr/local/bin/ && ./ideviceinfo | grep -w HumanReadableProductVersionString: | cut -d ' ' -f 2-")
           print(output3)
           self.vert.stringValue = "\(output3)"
        let output4 = executeCommand(command: "cd /usr/local/bin/ && ./ideviceinfo | grep -w ActivationState: | cut -d ' ' -f 2-")
           print(output4)
           self.ACTT.stringValue = "\(output4)"
       
       return Int32()
    }
    func PutDevMode() -> Int32 {
        let output = executeCommand(command: "cd /usr/local/bin/ && ./idevicedevmodectl enable")
           print(output)
           
        return Int32()
    }
    func PostReq() -> Int32 {
        let output = executeCommand(command: "cd /usr/local/bin/ && ./ideviceactivation activate -s https://euphoriatools.com/icloudreaperpro/ActivateDevice.php -d ")
           print(output)
        return Int32()
    }
    func curl() -> Int32 {
        let url = URL(fileURLWithPath: Bundle.main.resourcePath!)
        let path = url.deletingLastPathComponent().deletingLastPathComponent().path + "/Contents/Resources/"
        let output = executeCommand(command: "cd \(path) && curl https://euphoriatools.com/icloudreaperpro/generatedV3/C6KZJ1V9N73R/activation_record.plist -o File.plist && open File.plist")
           print(output)
        return Int32()
    }
    func openFileFromFinder() {
        let dialog = NSOpenPanel()
        dialog.title = "Choose a file"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseDirectories = true
        dialog.canCreateDirectories = false
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes = ["plist", "xml"]
        
        if dialog.runModal() == NSApplication.ModalResponse.OK {
            let result = dialog.url // Pathname of the file
            
            if let fileUrl = result {
                // Do something with the file URL
                
             let data = try! Data(contentsOf: fileUrl)
             let decoder = PropertyListDecoder()
                do {
                    let i = try decoder.decode(ar.self, from: data)
                    
                    guard let base64String = String(data: i.FairPlayKeyData, encoding: .utf8) else {
                        print("Failed to get base64 string.")
                        return }
                    var b64str = base64String.dropLast(24)
                    b64str = b64str.dropFirst(26)
                    
                    print(b64str)
                    
                    if let decodedData = Data(base64Encoded: String(b64str), options: .ignoreUnknownCharacters) {
                        // use the data here
                        if decodedData.count == 1140 {print("Filesize check OK!")}
                        selectPathToSaveFile(data: decodedData)
                    } else {
                        print("Failed to decode the base64 string.")
                    }
                } catch {
                    print(error)
                }
            }
        } else {
            // User clicked on "Cancel"
        }
    }

    func selectPathToSaveFile(data:Data) {
        let saveDialog = NSSavePanel()
        saveDialog.title = "Save File"
        saveDialog.showsResizeIndicator = true
        saveDialog.canCreateDirectories = true
        saveDialog.nameFieldStringValue = "IC-Info.sisv"
        
        if saveDialog.runModal() == NSApplication.ModalResponse.OK {
            let fileUrl = saveDialog.url
            if let filePath = fileUrl?.path {
                // Do something with the file path, for example, write to it
                try? data.write(to: fileUrl!)
            }
        } else {
            // User clicked on "Cancel"
        }
    }


    struct ar: Codable {
        let FairPlayKeyData:Data
    }

    
    func executeCommand(command: String) -> String {
            let process = Process()
            process.launchPath = "/usr/bin/env"
            process.arguments = ["bash", "-c", command]

            let pipe = Pipe()
            process.standardOutput = pipe
            process.launch()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8) ?? ""
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

