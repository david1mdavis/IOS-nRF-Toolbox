//
//  NORUARTViewController.swift
//  nRF Toolbox
//
//  Created by Mostafa Berg on 11/05/16.
//  Copyright © 2016 Nordic Semiconductor. All rights reserved.
//

import UIKit
import CoreBluetooth
extension UIImage {
    
    /// Returns a image that fills in newSize
    func resizedImage(newSize: CGSize) -> UIImage {
        // Guard newSize is different
        guard self.size != newSize else { return self }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(x: 0, y:0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// Returns a resized image that fits in rectSize, keeping it's aspect ratio
    /// Note that the new image size is not rectSize, but within it.
    func resizedImageWithinRect(rectSize: CGSize) -> UIImage {
        let widthFactor = size.width / rectSize.width
        let heightFactor = size.height / rectSize.height
        
        var resizeFactor = widthFactor
        if size.height > size.width {
            resizeFactor = heightFactor
        }
        
        let newSize = CGSize(width: size.width/resizeFactor, height: size.height/resizeFactor)
        let resized = resizedImage(newSize:newSize)
        return resized
    }
    
}


extension UInt16 {
    var red_565 : UInt8 {
        get {
            return UInt8((self & 0xf800) >> 11)
        }
    //    set(newValue) {
      //      self = UInt16(UInt16(self & 0xf800) | UInt16(newValue & 0xf800) << 11)
        //}
    }
    
    var green_565 : UInt8 {
        get {
            return UInt8((self & 0x7e0) >> 6)
        }
    //     set(newValue) {
      //      self = UInt16(UInt16(self & 0x7e0) | UInt16((newValue & 0x7e0) << 6))
       // }
    }
    
    var blue_565 : UInt8 {
        get {
            return UInt8(self & 0x1F)
        }
        set(newValue) {
           self = UInt16(UInt16(self & 0x1F) | UInt16((newValue & 0x1F) ))
        }
    }
}


class NORUARTViewController: UIViewController, NORBluetoothManagerDelegate, NORScannerDelegate, UIPopoverPresentationControllerDelegate, ButtonConfigureDelegate {
    
    //MARK: - View Properties
    var bluetoothManager    : NORBluetoothManager?
    var uartPeripheralName  : String?
    var buttonsCommands     : NSMutableArray?
    var buttonsHiddenStatus : NSMutableArray?
    var buttonsImageNames   : NSMutableArray?
    var imagaArray           : NSMutableArray?
    var buttonIcons         : NSArray?
    var selectedButton      : UIButton?
    var logger              : NORLogViewController?
    var editMode            : Bool?
    var pixels: RGBAImage?
    @IBOutlet weak var camImage: UIImageView!
    func createImage(){
        
    }
    
    //MARK: - View Actions
    @IBAction func connectionButtonTapped(_ sender: AnyObject) {
        bluetoothManager?.cancelPeripheralConnection()
    }
    var dataReadCount = 0
    @IBAction func editButtonTapped(_ sender: AnyObject) {
        
        var value_red : UInt8?
        var value_green : UInt8?
        var value_blue : UInt8?
        var value16     : UInt16?
        
        
        
        //setEditMode(mode: !currentEditMode)
    }
    @IBAction func showLogButtonTapped(_ sender: AnyObject) {
        
        DispatchQueue.main.async {
            //TODO: this is a bad fix to get things done, do not release!
            if self.logger?.displayLogTextTable != nil {
                self.logger?.displayLogTextTable!.reloadData()
          //      self.logger?.crollDisplayViewDown()
            }
        }
        self.revealViewController().revealToggle(animated: true)
        
    }
    @IBAction func buttonTapped(_ sender: AnyObject){
        if editMode == true
        {
            self.selectedButton = sender as? UIButton;
            self.showPopoverOnButton()
        }
        else
        {
            let command = buttonsCommands![sender.tag-1]
            self.send(value: String(describing: command))
        }
    }

    //MARK: - View OUtlets
    @IBOutlet weak var verticalLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var connectionButton: UIButton!
    
    //MARK: - UIViewControllerDelegate
    required init?(coder aDecoder: NSCoder) {
       
        
        super.init(coder: aDecoder)
       //   imagaData = NSMutableData()
        buttonIcons = ["Stop","Play","Pause","FastForward","Rewind","End","Start","Shuffle","Record","Number_1",
        "Number_2","Number_3","Number_4","Number_5","Number_6","Number_7","Number_8","Number_9",]
    // var  pix = self.pixels?.pixels[0]
      //  NSLog("%d",pix?.R ?? -1)
    }
     // var  count : Int = 0
    func updateTime(){
        let data = bluetoothManager?.cameradata  //  NSData(/* ... */)
        // the number of elements:
        let count = (data?.length)! // MemoryLayout<UInt16>.size
        
        // create array of appropriate length:
        var array16 = [UInt16](repeating: 0xffff, count: count/2)
        // var array8 = [UInt8](repeating: 0, count: count/2+count)
        
        // copy bytes into array
        data?.getBytes(&array16, length:count/2 * MemoryLayout<UInt16>.size)
        bluetoothManager?.cameradata = NSMutableData()
        
        var pixel = Pixel(value: 0)
        let num_255 :UInt16 = 255
        let num_31  :UInt16 = 31
        let num_63  :UInt16 = 63
        var d1 : UInt16
        var d2 : UInt16
        for value16 in array16 {
            
            
            
        //    printf("%d,%d,%d ",(t->red * 527 + 23 ) >> 6,(t->green  * 259 + 33 ) >> 6,(t->blue * 527 + 23 ) >> 6);
            
          //  value16
            d1 = value16 & 0xFF00
            d2 = value16 & 0x00FF
            d1 = d1 >> 8;

            
           pixel.B = UInt8((d1 & 0x1F) << 3);
           pixel.G = UInt8((((d1 & 0xE0) >> 3) | ((d2 & 0x07) << 5)));
           pixel.R = UInt8((d2 & 0xF8));
            
           // pixel.R = UInt8((UInt16(value16.red_565)   * 527 + 23) >> 6)
           // pixel.B = UInt8((UInt16(value16.blue_565)  * 527 + 23) >> 6)
            //pixel.G = UInt8((UInt16(value16.green_565) * 259 + 33) >> 6)
            
            
            
          //  pixel.R = UInt8(UInt16(value16.red_565) * num_255 / num_31 )
           // pixel.B = UInt8(UInt16(value16.blue_565) * num_255 / num_31)
           // pixel.G = UInt8(UInt16(value16.green_565) *   num_255 / num_63)
            
            pixel.A = 255
            
            
            let s =  camImage.image?.size
         //    let y = dataReadCount / Int((160))
           // let x = dataReadCount % Int((160))
              let y = dataReadCount / Int((s?.width)!)
              let x = dataReadCount % Int((s?.width)!)
            
            
            pixels?.pixel(x: x, y, pixel)
            dataReadCount += 1
      //       NSLog("x=%d,y=%dR=%d,G=%d,B=%d",x,y,pixel.R,pixel.G,pixel.B)
            
            
        }
        
        DispatchQueue.main.async {
            self.camImage.image = self.pixels?.toUIImage()
        }
        
        
        

        NSLog("%d",count)
      //  count += 1
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Rotate the vertical label
        self.verticalLabel.transform = CGAffineTransform(translationX: -(verticalLabel.frame.width/2) + (verticalLabel.frame.height / 2), y: 0.0).rotated(by: CGFloat(-M_PI_2));
        
        // Retrieve three arrays (icons names (NSString), commands (NSString), visibility(Bool)) from NSUserDefaults
        retrieveButtonsConfiguration()
        editMode = false
        
        // Configure the SWRevealViewController
        let revealViewController = self.revealViewController()
        if revealViewController != nil {
            self.view.addGestureRecognizer((revealViewController?.panGestureRecognizer())!)
            logger = revealViewController?.rearViewController as? NORLogViewController
        }
     
        camImage?.image = camImage?.image?.resizedImageWithinRect(rectSize: CGSize(width: 160, height: 120))
        pixels = RGBAImage(image:(camImage?.image)!)!
        
        Timer.scheduledTimer(timeInterval: 10,
                             target: self,
                             selector: #selector(self.updateTime),
                             userInfo: nil,
                             repeats: true)
    }
    
    //MARK: - Segue methods
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // The 'scan' seque will be performed only if bluetoothManager == nil (if we are not connected already).
        return identifier != "scan" || self.bluetoothManager == nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "scan" else {
            return
        }
        
        // Set this contoller as scanner delegate
        let nc = segue.destination as! UINavigationController
        let controller = nc.childViewControllerForStatusBarHidden as! NORScannerViewController
        // controller.filterUUID = CBUUID.init(string: NORServiceIdentifiers.uartServiceUUIDString)
        controller.delegate = self
    }
    
    //MARK: - UIPopoverPresentationCtonrollerDelegate
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    //MARK: - NORScannerViewDelegate
    func centralManagerDidSelectPeripheral(withManager aManager: CBCentralManager, andPeripheral aPeripheral: CBPeripheral) {
        // We may not use more than one Central Manager instance. Let's just take the one returned from Scanner View Controller
        bluetoothManager = NORBluetoothManager(withManager: aManager)
        bluetoothManager!.delegate = self
        bluetoothManager!.logger = logger
        logger!.clearLog()
        
        if let name = aPeripheral.name {
            self.uartPeripheralName = name
            self.deviceName.text = name
        } else {
            self.uartPeripheralName = "device"
            self.deviceName.text = "No name"
        }
        self.connectionButton.setTitle("CANCEL", for: UIControlState())
        bluetoothManager!.connectPeripheral(peripheral: aPeripheral)
    }
    
    //MARK: - BluetoothManagerDelegate
    func peripheralReady() {
        print("Peripheral is ready")
    }
    
    func peripheralNotSupported() {
        print("Peripheral is not supported")
    }
    
    func didConnectPeripheral(deviceName aName: String?) {
        // Scanner uses other queue to send events. We must edit UI in the main queue
        DispatchQueue.main.async(execute: {
            self.logger!.bluetoothManager = self.bluetoothManager
            self.connectionButton.setTitle("DISCONNECT", for: UIControlState())
        })
        
        //Following if condition display user permission alert for background notification
        if UIApplication.instancesRespond(to: #selector(UIApplication.registerUserNotificationSettings(_:))){
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert], categories: nil))
        }

        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidEnterBackgroundCallback), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidBecomeActiveCallback), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }

    func didDisconnectPeripheral() {
            // Scanner uses other queue to send events. We must edit UI in the main queue
            DispatchQueue.main.async(execute: {
                self.logger!.bluetoothManager = nil
                self.connectionButton.setTitle("CONNECT", for: UIControlState())
                self.deviceName.text = "DEFAULT UART"
                
                if NORAppUtilities.isApplicationInactive() {
                    NORAppUtilities.showBackgroundNotification(message: "Peripheral \(self.uartPeripheralName!) is disconnected")
                }

                self.uartPeripheralName = nil
            })
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        bluetoothManager = nil
    }

    //MARK: - ButtonconfigureDelegate
    func didConfigureButton(_ aButton: UIButton, withCommand aCommand: String, andIconIndex index: Int, shouldHide hide: Bool) {
        let userDefaults = UserDefaults.standard
        let buttonTag = (selectedButton?.tag)!-1
        buttonsHiddenStatus![(selectedButton?.tag)!-1] = NSNumber(value: hide as Bool)
        
        userDefaults.set(buttonsHiddenStatus, forKey: "buttonsHiddenStatus")
        if hide == true {
            selectedButton?.setImage(nil, for: UIControlState())
        }else{
            let image = UIImage(named: buttonIcons![index] as! String)
            selectedButton?.setImage(image, for: UIControlState())
        }
        
        buttonsImageNames![buttonTag] = buttonIcons![index]
        buttonsCommands![buttonTag] = aCommand
        
        userDefaults.set(buttonsImageNames, forKey: "buttonsImageNames")
        userDefaults.set(self.buttonsCommands, forKey: "buttonsCommands")
        userDefaults.synchronize()
    }
    
    //MARK: - NORUArtViewController Implementation
    func retrieveButtonsConfiguration() {
        let userDefaults = UserDefaults.standard
        
        if userDefaults.object(forKey: "buttonsCommands") != nil {
            //Buttons configurations already saved in NSUserDefaults
            buttonsCommands = NSMutableArray(array: userDefaults.object(forKey: "buttonsCommands") as! NSArray)
            buttonsHiddenStatus = NSMutableArray(array: userDefaults.object(forKey: "buttonsHiddenStatus") as! NSArray)
            buttonsImageNames   = NSMutableArray(array: userDefaults.object(forKey: "buttonsImageNames") as! NSArray)
            self.showButtonsWithSavedConfiguration()
        } else {
            //First time viewcontroller is loaded and there is no saved buttons configurations in NSUserDefaults
            //Setting up the default values for the first time
            self.buttonsCommands = NSMutableArray(array: ["","","","","","","","",""])
            self.buttonsHiddenStatus = NSMutableArray(array: [true,true,true,true,true,true,true,true,true])
            self.buttonsImageNames = NSMutableArray(array: ["Play","Play","Play","Play","Play","Play","Play","Play","Play"])
            userDefaults.set(buttonsCommands, forKey: "buttonsCommands")
            userDefaults.set(buttonsHiddenStatus, forKey: "buttonsHiddenStatus")
            userDefaults.set(buttonsImageNames, forKey: "buttonsImageNames")
            userDefaults.synchronize()
        }
    }
    
    func showButtonsWithSavedConfiguration() {
        for aButton : UIButton in buttons! {
            if (buttonsHiddenStatus![aButton.tag-1] as AnyObject).boolValue == true {
                aButton.backgroundColor = UIColor(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0)
                aButton.setImage(nil, for: UIControlState())
                aButton.isEnabled = false
            } else {
                aButton.backgroundColor = UIColor(red: 0.0/255.0, green:156.0/255.0, blue:222.0/255.0, alpha: 1.0)
                aButton.setImage(UIImage(named: buttonsImageNames![aButton.tag-1] as! String), for: UIControlState())
                aButton.isEnabled = true
            }
        }
    }
    
    func showPopoverOnButton() {
        let popOverViewController = storyboard?.instantiateViewController(withIdentifier: "StoryboardIDEditPopup") as! NOREditPopupViewController
        popOverViewController.delegate = self
        popOverViewController.isHidden = false
        popOverViewController.command = buttonsCommands![(selectedButton?.tag)!-1] as? String
        let buttonImageName = buttonsImageNames![(selectedButton?.tag)!-1]
        popOverViewController.setIconIndex((buttonIcons?.index(of: buttonImageName))!)
        popOverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
        popOverViewController.popoverPresentationController?.delegate = self
        self.present(popOverViewController, animated: true, completion: nil)

        popOverViewController.popoverPresentationController?.sourceView = self.view!
        popOverViewController.popoverPresentationController?.sourceRect = self.view.bounds
        popOverViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        popOverViewController.preferredContentSize = CGSize(width: 300.0, height: 300.0)
    }

    func setEditMode(mode aMode : Bool){
        editMode = aMode
        
        if editMode == true {
            editButton.setTitle("Done", for: UIControlState())
            for aButton : UIButton in buttons {
                aButton.backgroundColor = UIColor(red: 222.0/255.0, green: 74.0/266.0, blue: 19.0/255.0, alpha: 1.0)
                aButton.isEnabled = true
            }
        } else {
            editButton.setTitle("Edit", for: UIControlState())
            showButtonsWithSavedConfiguration()
        }
    }

    func applicationDidEnterBackgroundCallback(){
        NORAppUtilities.showBackgroundNotification(message: "You are still connected to \(self.uartPeripheralName!)")
    }
    
    func applicationDidBecomeActiveCallback(){
        UIApplication.shared.cancelAllLocalNotifications()
    }
    
    //MARK: - UART API
    func send(value aValue : String) {
        if self.bluetoothManager != nil {
            bluetoothManager?.send(text: aValue)
        }
    }
}
