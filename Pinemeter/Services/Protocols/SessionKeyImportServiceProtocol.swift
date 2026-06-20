import Foundation

/// User-selectable browser source for importing provider sessions.
enum BrowserImportSource: String, CaseIterable, Equatable, Sendable {
    case defaultBrowser
    case chrome
    case safari
    case brave
    case edge
    case arc
    case firefox

    static let setupOptions: [BrowserImportSource] = [
        .defaultBrowser,
        .chrome,
        .safari,
        .brave,
        .edge,
        .arc,
        .firefox,
    ]

    var displayName: String {
        switch self {
        case .defaultBrowser:
            return "Default Browser"
        case .chrome:
            return "Chrome"
        case .safari:
            return "Safari"
        case .brave:
            return "Brave"
        case .edge:
            return "Edge"
        case .arc:
            return "Arc"
        case .firefox:
            return "Firefox"
        }
    }

    var importButtonTitle: String {
        "Import from \(displayName)"
    }
}

/// Outcome for a single provider during combined browser import.
enum ProviderBrowserImportStatus: Equatable, Sendable {
    case imported(sourceDescription: String)
    case failed(message: String, offersFullDiskAccessSettings: Bool)

    var offersFullDiskAccessSettings: Bool {
        if case .failed(_, let offersFullDiskAccessSettings) = self {
            return offersFullDiskAccessSettings
        }
        return false
    }
}

/// Combined browser import outcome for both supported providers.
struct ProviderBrowserImportOutcome: Equatable, Sendable {
    let source: BrowserImportSource
    let claude: ProviderBrowserImportStatus
    let chatGPT: ProviderBrowserImportStatus

    var importedCount: Int {
        [claude, chatGPT].filter { status in
            if case .imported = status { return true }
            return false
        }.count
    }

    var offersFullDiskAccessSettings: Bool {
        claude.offersFullDiskAccessSettings || chatGPT.offersFullDiskAccessSettings
    }
}

/// Browser import result for a Claude session key.
struct ImportedSessionKey: Equatable, Sendable {
    let value: String
    let sourceDescription: String
}

/// Browser import result for a ChatGPT session cookie.
struct ImportedChatGPTSessionCookie: Equatable, Sendable {
    let cookieHeader: String
    let sourceDescription: String
}

/// Errors that can occur while importing provider credentials from browser cookies.
enum SessionKeyImportError: LocalizedError {
    case noSessionKeyFound
    case noChatGPTSessionCookieFound
    case accessDenied
    case safariAccessDenied
    case browserKeychainAccessDenied(String)
    case invalidImportedSessionKey
    case invalidImportedChatGPTSessionCookie

    var errorDescription: String? {
        switch self {
        case .noSessionKeyFound:
            return "No Claude browser session found. Sign in to claude.ai in your browser, then try again."
        case .noChatGPTSessionCookieFound:
            return "No ChatGPT browser session found. Sign in to chatgpt.com in your browser, then try again."
        case .accessDenied:
            return "Pinemeter could not access browser cookies. Allow the macOS prompt and try again."
        case .safariAccessDenied:
            return "Safari needs Full Disk Access to import cookies. Use Chrome/Arc/Brave, or grant Full Disk Access and try again."
        case .browserKeychainAccessDenied(let browserName):
            return "Allow \(browserName) Safe Storage in Keychain, then try again."
        case .invalidImportedSessionKey:
            return "The imported Claude browser session could not be validated."
        case .invalidImportedChatGPTSessionCookie:
            return "The imported ChatGPT browser session could not be validated."
        }
    }

    var offersFullDiskAccessSettings: Bool {
        if case .safariAccessDenied = self {
            return true
        }
        return false
    }
}

/// Protocol for importing and repairing provider browser sessions.
protocol SessionKeyImportServiceProtocol: Actor {
    func importSessionKey() async throws -> ImportedSessionKey
    func importSessionKey(from source: BrowserImportSource) async throws -> ImportedSessionKey
    func importChatGPTSessionCookie() async throws -> ImportedChatGPTSessionCookie
    func importChatGPTSessionCookie(from source: BrowserImportSource) async throws -> ImportedChatGPTSessionCookie
    func repairSavedSessionKey(account: String) async -> CredentialState
}
