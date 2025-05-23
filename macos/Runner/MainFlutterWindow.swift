import Cocoa
import FlutterMacOS
import CoreBluetooth

class MainFlutterWindow: NSWindow {
  private var bluetoothManager: CBCentralManager?
  private var methodChannel: FlutterMethodChannel?
  
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    
    methodChannel = FlutterMethodChannel(
      name: "com.respirit.device/macos",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    
    methodChannel?.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }
      
      switch call.method {
      case "checkBluetoothPermission":
        self.checkBluetoothPermission(result: result)
      case "requestBluetoothPermission":
        self.requestBluetoothPermission(result: result)
      case "checkNetworkPermission":
        self.checkNetworkPermission(result: result)
      case "requestNetworkPermission":
        self.requestNetworkPermission(result: result)
      case "showAlert":
        self.showAlert(call: call, result: result)
      case "saveFile":
        self.saveFile(call: call, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    RegisterGeneratedPlugins(registry: flutterViewController)
    
    super.awakeFromNib()
  }
  
  private func checkBluetoothPermission(result: @escaping FlutterResult) {
    if bluetoothManager == nil {
      bluetoothManager = CBCentralManager(delegate: nil, queue: nil)
    }
    
    let state = bluetoothManager?.state ?? .unknown
    result(state == .poweredOn)
  }
  
  private func requestBluetoothPermission(result: @escaping FlutterResult) {
    if bluetoothManager == nil {
      bluetoothManager = CBCentralManager(delegate: nil, queue: nil)
    }
    
    let state = bluetoothManager?.state ?? .unknown
    result(state == .poweredOn)
  }
  
  private func checkNetworkPermission(result: @escaping FlutterResult) {
    // Implement network permission check
    result(true)
  }
  
  private func requestNetworkPermission(result: @escaping FlutterResult) {
    // Implement network permission request
    result(true)
  }
  
  private func showAlert(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let title = args["title"] as? String,
          let message = args["message"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS",
                         message: "Invalid arguments for showAlert",
                         details: nil))
      return
    }
    
    let alert = NSAlert()
    alert.messageText = title
    alert.informativeText = message
    
    if let positiveButton = args["positiveButton"] as? String {
      alert.addButton(withTitle: positiveButton)
    }
    
    if let negativeButton = args["negativeButton"] as? String {
      alert.addButton(withTitle: negativeButton)
    }
    
    alert.runModal()
    result(nil)
  }
  
  private func saveFile(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let fileName = args["fileName"] as? String,
          let data = args["data"] as? [UInt8] else {
      result(FlutterError(code: "INVALID_ARGUMENTS",
                         message: "Invalid arguments for saveFile",
                         details: nil))
      return
    }
    
    let savePanel = NSSavePanel()
    savePanel.nameFieldStringValue = fileName
    
    savePanel.begin { response in
      if response == .OK {
        guard let url = savePanel.url else {
          result(FlutterError(code: "SAVE_FAILED",
                             message: "Failed to get save URL",
                             details: nil))
          return
        }
        
        do {
          try Data(data).write(to: url)
          result(nil)
        } catch {
          result(FlutterError(code: "SAVE_FAILED",
                             message: error.localizedDescription,
                             details: nil))
        }
      } else {
        result(FlutterError(code: "CANCELLED",
                           message: "Save operation cancelled",
                           details: nil))
      }
    }
  }
}
