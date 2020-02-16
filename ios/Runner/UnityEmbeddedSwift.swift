import Foundation
import UnityFramework
 
class UnityEmbeddedSwift: UIResponder, UIApplicationDelegate, UnityFrameworkListener, NativeCallsProtocol {
    
    func showHostMainWindow(_ color: String!) {
        
        let delegate = UIApplication.shared.delegate
        let rootController = delegate?.window??.rootViewController
        guard let swiftVC = rootController?.presentedViewController as? SwiftViewController else { return }
        swiftVC.changeBackground(color: color)
        
        UnityEmbeddedSwift.hostMainWindow?.makeKeyAndVisible()
    }
    
 
    private struct UnityMessage {
        let objectName : String?
        let methodName : String?
        let messageBody : String?
    }
 
    private static var instance : UnityEmbeddedSwift!
    private var ufw : UnityFramework!
    private static var hostMainWindow : UIWindow! //Window to return to when exitting Unity window
    private static var launchOpts : [UIApplication.LaunchOptionsKey: Any]?
 
    private static var cachedMessages = [UnityMessage]()
    
    private static var didQuit = false
 
    //Static functions that can be called from other scripts
    static func setHostMainWindow(_ hostMainWindow : UIWindow?) {
        UnityEmbeddedSwift.hostMainWindow = hostMainWindow
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
   
    }
 
    static func setLaunchinOptions(_ launchingOptions :  [UIApplication.LaunchOptionsKey: Any]?) {
        UnityEmbeddedSwift.launchOpts = launchingOptions
    }
 
    static func showUnity() {
        
        if UnityEmbeddedSwift.didQuit {
            UnityEmbeddedSwift.showAlert("Error", "Unity cannot be initialized after quit, use unload instead!")
            return
        }
        
        if(UnityEmbeddedSwift.instance == nil || UnityEmbeddedSwift.instance.unityIsInitialized() == false) {
            UnityEmbeddedSwift().initUnityWindow()
        }
        else {
            UnityEmbeddedSwift.instance.showUnityWindow()
        }
    }
 
    static func hideUnity() {
        UnityEmbeddedSwift.instance?.hideUnityWindow()
    }
 
    static func unloadUnity() {
        UnityEmbeddedSwift.instance?.unloadUnityWindow()
    }
 
    static func sendUnityMessage(_ objectName : String, methodName : String, message : String) {
        let msg : UnityMessage = UnityMessage(objectName: objectName, methodName: methodName, messageBody: message)
   
   
        //Send the message right away if Unity is initialized, else cache it
        if(UnityEmbeddedSwift.instance != nil && UnityEmbeddedSwift.instance.unityIsInitialized()) {
            UnityEmbeddedSwift.instance.ufw.sendMessageToGO(withName: msg.objectName, functionName: msg.methodName, message: msg.messageBody)
        }
        else {
            UnityEmbeddedSwift.cachedMessages.append(msg)
        }
    }
 
    //Callback from UnityFrameworkListener
    func unityDidUnload(_ notification: Notification!) {
        ufw.unregisterFrameworkListener(self)
        ufw = nil
        UnityEmbeddedSwift.hostMainWindow?.makeKeyAndVisible()
    }
    
    //Callback from UnityFrameworkListener
    func unityDidQuit(_ notification: Notification!) {
        ufw.unregisterFrameworkListener(self)
        ufw = nil
        UnityEmbeddedSwift.didQuit = true
        UnityEmbeddedSwift.hostMainWindow?.makeKeyAndVisible()
    }
 
    //Private functions called within the class
    private func unityIsInitialized() -> Bool {
        return ufw != nil && (ufw.appController() != nil)
    }
 
    private func initUnityWindow() {
        
        if unityIsInitialized() {
            showUnityWindow()
            return
        }
   
        ufw = UnityFrameworkLoad()!
        ufw.setDataBundleId("com.unity3d.framework")
        ufw.register(self)
        NSClassFromString("FrameworkLibAPI")?.registerAPIforNativeCalls(self)
   
        ufw.runEmbedded(withArgc: CommandLine.argc, argv: CommandLine.unsafeArgv, appLaunchOpts: UnityEmbeddedSwift.launchOpts)
   
        sendUnityMessageToGameObject()
   
        UnityEmbeddedSwift.instance = self
        
        self.ufw.appController()?.quitHandler = { print("AppController.quitHandler called"); }
        
        addCustomViewOnTop()
    }
 
    private func showUnityWindow() {
        if unityIsInitialized() {
            ufw.showUnityWindow()
            sendUnityMessageToGameObject()
        }
    }
 
    private func hideUnityWindow() {
        if(UnityEmbeddedSwift.hostMainWindow == nil) {
            print("WARNING: hostMainWindow is nil! Cannot switch from Unity window to previous window")
        }
        else {
            UnityEmbeddedSwift.hostMainWindow?.makeKeyAndVisible()
        }
    }
 
    private func unloadUnityWindow() {
        if unityIsInitialized() {
            UnityEmbeddedSwift.cachedMessages.removeAll()
            ufw.unloadApplication()
            UnityEmbeddedSwift.showAlert("Success", "Unloaded Successfully");
        } else {
            UnityEmbeddedSwift.showAlert("Unity is not initialized", "Initialize Unity first");
        }
    }
 
    private func sendUnityMessageToGameObject() {
        if(UnityEmbeddedSwift.cachedMessages.count >= 0 && unityIsInitialized())
        {
            for msg in UnityEmbeddedSwift.cachedMessages {
                ufw.sendMessageToGO(withName: msg.objectName, functionName: msg.methodName, message: msg.messageBody)
            }
       
            UnityEmbeddedSwift.cachedMessages.removeAll()
        }
    }
    
    @objc func sendMessageToUnity() {
        ufw.sendMessageToGO(withName: "Cube", functionName: "ChangeColor", message: "yellow")
    }
 
    private func UnityFrameworkLoad() -> UnityFramework? {
        let bundlePath: String = Bundle.main.bundlePath + "/Frameworks/UnityFramework.framework"
   
        let bundle = Bundle(path: bundlePath )
        if bundle?.isLoaded == false {
            bundle?.load()
        }
   
        let ufw = bundle?.principalClass?.getInstance()
        if ufw?.appController() == nil {
            // unity is not initialized
            //            ufw?.executeHeader = &mh_execute_header
       
            let machineHeader = UnsafeMutablePointer<MachHeader>.allocate(capacity: 1)
            machineHeader.pointee = _mh_execute_header
       
            ufw!.setExecuteHeader(machineHeader)
        }
        return ufw
    }
    
    private func addCustomViewOnTop() {
        
        let view = ufw.appController()?.rootView

        let showUnityOffButton = UIButton(type: .system)
        showUnityOffButton.setTitle("Show Main", for: .normal)
        showUnityOffButton.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
        showUnityOffButton.center = CGPoint(x: 50, y: 300)
        showUnityOffButton.backgroundColor = UIColor.green
        view?.addSubview(showUnityOffButton)
        showUnityOffButton.addTarget(self, action: #selector(showMainView), for: .touchUpInside)

        let btnSendMsg = UIButton(type: .system)
        btnSendMsg.setTitle("Send Msg", for: .normal)
        btnSendMsg.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
        btnSendMsg.center = CGPoint(x: 150, y: 300)
        btnSendMsg.backgroundColor = UIColor.yellow
        view?.addSubview(btnSendMsg)
        btnSendMsg.addTarget(self, action: #selector(sendMessageToUnity), for: .touchUpInside)
        
        let unloadBtn = UIButton(type: .system)
        unloadBtn.setTitle("Unload", for: .normal)
        unloadBtn.frame = CGRect(x: 250, y: 0, width: 100, height: 44)
        unloadBtn.center = CGPoint(x: 250, y: 300)
        unloadBtn.backgroundColor = UIColor.red
        unloadBtn.addTarget(self, action: #selector(unloadButtonTouched), for: .touchUpInside)
        view?.addSubview(unloadBtn)

        // Quit
        let quitBtn = UIButton(type: .system)
        quitBtn.setTitle("Quit", for: .normal)
        quitBtn.frame = CGRect(x: 250, y: 0, width: 100, height: 44)
        quitBtn.center = CGPoint(x: 250, y: 350)
        quitBtn.backgroundColor = UIColor.red
        quitBtn.addTarget(self, action: #selector(quitButtonTouched), for: .touchUpInside)
        
        view?.addSubview(quitBtn)
    }
    
    @objc func unloadButtonTouched(sender: UIButton)
    {
        UnityEmbeddedSwift.unloadUnity()
    }

    @objc func quitButtonTouched(sender: UIButton)
    {
        if(!unityIsInitialized()) {
            UnityEmbeddedSwift.showAlert("Unity is not initialized", "Initialize Unity first");
        } else {
            ufw.quitApplication(0)
        }
    }
    
    @objc func showMainView(sender: UIButton) {
        showHostMainWindow("")
    }
    
    static func showAlert(_ title: String?, _ msg: String?) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Ok", style: .default, handler: { action in
            })
        alert.addAction(defaultAction)
        let delegate = UIApplication.shared.delegate
        var rootController = delegate?.window??.rootViewController
        
        guard let topVC = rootController?.presentedViewController else { return }
        topVC.present(alert, animated: true)
    }
}
