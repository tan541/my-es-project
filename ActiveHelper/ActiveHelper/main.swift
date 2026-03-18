import Foundation
import SystemExtensions

let extensionIdentifier = "com.example.myproject.activehelper.EndpointSecurityExtension"

final class Activator: NSObject, OSSystemExtensionRequestDelegate {
    
    let semaphore = DispatchSemaphore(value: 0)
    var finalStatus = "Unknown"
    
    func request(_ request: OSSystemExtensionRequest,
                 actionForReplacingExtension existing: OSSystemExtensionProperties,
                 withExtension new: OSSystemExtensionProperties) -> OSSystemExtensionRequest.ReplacementAction {
        print("Replacing older version \(existing.bundleShortVersion) → \(new.bundleShortVersion)")
        return .replace
    }
    
    func requestNeedsUserApproval(_ request: OSSystemExtensionRequest) {
        finalStatus = "Activation requires manual approval:\n" +
                      "→ System Settings → Privacy & Security → Allow the extension"
        print(finalStatus)
        semaphore.signal()
    }
    
    func request(_ request: OSSystemExtensionRequest, didFinishWithResult result: OSSystemExtensionRequest.Result) {
        switch result {
        case .completed:
            finalStatus = "✅ Activation completed successfully"
        case .willCompleteAfterReboot:
            finalStatus = "✅ Activation completed successfully after reboot"
        @unknown default:
            finalStatus = "Finished with unknown result: \(result)"
        }
        print(finalStatus)
        semaphore.signal()
    }
    
    func request(_ request: OSSystemExtensionRequest, didFailWithError error: Error) {
        let nsError = error as NSError
        let code = nsError.code
        
        switch code {
        case OSSystemExtensionError.missingEntitlement.rawValue:
            finalStatus = "Missing entitlement (check signing & entitlements)"
        case OSSystemExtensionError.extensionNotFound.rawValue:
            finalStatus = "Extension not found in bundle"
        case OSSystemExtensionError.authorizationRequired.rawValue:
            finalStatus = "Authorization required (first-time approval needed)"
        case OSSystemExtensionError.codeSignatureInvalid.rawValue:
            finalStatus = "Code signature invalid (expected in dev mode)"
        default:
            finalStatus = "Activation failed: \(error.localizedDescription) (code \(code))"
        }
        
        print(finalStatus)
        semaphore.signal()
    }
}

print("ActiveHelperCLI – Activating Endpoint Security Extension")
print("Identifier: \(extensionIdentifier)\n")

let delegate = Activator()
let request = OSSystemExtensionRequest.activationRequest(
    forExtensionWithIdentifier: extensionIdentifier,
    queue: .main
)

request.delegate = delegate
OSSystemExtensionManager.shared.submitRequest(request)

_ = delegate.semaphore.wait(timeout: .distantFuture)

print("\nDone. Final status:")
print(delegate.finalStatus)
