import Foundation
import SystemExtensions

class ExtensionDelegate: NSObject, OSSystemExtensionRequestDelegate {
    func request(
        _ request: OSSystemExtensionRequest,
        actionForReplacingExtension existing: OSSystemExtensionProperties,
        withExtension replacement: OSSystemExtensionProperties
    ) -> OSSystemExtensionRequest.ReplacementAction {
        return .replace
    }

    func requestNeedsUserApproval(_ request: OSSystemExtensionRequest) {
        print("Please allow the extension in System Settings -> Privacy & Security.")
    }

    func request(
        _ request: OSSystemExtensionRequest,
        didFinishWithResult result: OSSystemExtensionRequest.Result
    ) {
        print("Extension activation result: \(result.rawValue)")
        exit(0)
    }

    func request(_ request: OSSystemExtensionRequest, didFailWithError error: Error) {
        print("Extension activation failed: \(error.localizedDescription)")
        exit(1)
    }
}

// Activation Logic
let identifier = "com.example.myproject.activehelper.EndpointSecurityExtension"  // Must match your bundle ID
let request = OSSystemExtensionRequest.activationRequest(
    forExtensionWithIdentifier: identifier, queue: .main)
let delegate = ExtensionDelegate()
request.delegate = delegate

OSSystemExtensionManager.shared.submitRequest(request)
RunLoop.main.run()
