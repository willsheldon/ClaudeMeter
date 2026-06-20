import AppKit
import Foundation
import os
import SweetCookieKit

/// Imports Claude session keys from local browser cookies.
actor SessionKeyImportService: SessionKeyImportServiceProtocol {
    private static let logger = Logger(subsystem: "com.pinemeter", category: "SessionKeyImportService")

    private let cookieClient: BrowserCookieClient
    private let browserImportOrder: [Browser]
    private let keychainRepository: KeychainRepositoryProtocol

    init(
        cookieClient: BrowserCookieClient = BrowserCookieClient(),
        browserImportOrder: [Browser] = Browser.defaultImportOrder,
        keychainRepository: KeychainRepositoryProtocol = KeychainRepository()
    ) {
        self.cookieClient = cookieClient
        self.browserImportOrder = browserImportOrder
        self.keychainRepository = keychainRepository
    }

    func importSessionKey() async throws -> ImportedSessionKey {
        try await importSessionKey(from: .defaultBrowser)
    }

    func importSessionKey(from source: BrowserImportSource) async throws -> ImportedSessionKey {
        let query = BrowserCookieQuery(domains: ["claude.ai"], domainMatch: .suffix)
        var sawAccessDenied = false
        var sawSafariAccessDenied = false
        var deniedKeychainBrowserName: String?

        for browser in browsers(for: source) {
            do {
                let sources = try cookieClient.records(matching: query, in: browser)
                for source in sources {
                    if let imported = try importedSessionKey(from: source) {
                        return imported
                    }
                }
            } catch let error as BrowserCookieError {
                switch error {
                case .accessDenied:
                    sawAccessDenied = true
                    if browser == .safari {
                        sawSafariAccessDenied = true
                    } else if browser.usesKeychainForCookieDecryption {
                        deniedKeychainBrowserName = browser.displayName
                    }
                case .notFound, .loadFailed:
                    break
                }
            }
        }

        if sawSafariAccessDenied {
            throw SessionKeyImportError.safariAccessDenied
        }
        if let deniedKeychainBrowserName {
            throw SessionKeyImportError.browserKeychainAccessDenied(deniedKeychainBrowserName)
        }
        if sawAccessDenied {
            throw SessionKeyImportError.accessDenied
        }
        throw SessionKeyImportError.noSessionKeyFound
    }

    func importChatGPTSessionCookie() async throws -> ImportedChatGPTSessionCookie {
        try await importChatGPTSessionCookie(from: .defaultBrowser)
    }

    func importChatGPTSessionCookie(from source: BrowserImportSource) async throws -> ImportedChatGPTSessionCookie {
        let query = BrowserCookieQuery(domains: ["chatgpt.com", "chat.openai.com"], domainMatch: .suffix)
        var sawAccessDenied = false
        var sawSafariAccessDenied = false
        var deniedKeychainBrowserName: String?

        for browser in browsers(for: source) {
            do {
                let sources = try cookieClient.records(matching: query, in: browser)
                for source in sources {
                    if let imported = importedChatGPTSessionCookie(from: source) {
                        return imported
                    }
                }
            } catch let error as BrowserCookieError {
                switch error {
                case .accessDenied:
                    sawAccessDenied = true
                    if browser == .safari {
                        sawSafariAccessDenied = true
                    } else if browser.usesKeychainForCookieDecryption {
                        deniedKeychainBrowserName = browser.displayName
                    }
                case .notFound, .loadFailed:
                    break
                }
            }
        }

        if sawSafariAccessDenied {
            throw SessionKeyImportError.safariAccessDenied
        }
        if let deniedKeychainBrowserName {
            throw SessionKeyImportError.browserKeychainAccessDenied(deniedKeychainBrowserName)
        }
        if sawAccessDenied {
            throw SessionKeyImportError.accessDenied
        }
        throw SessionKeyImportError.noChatGPTSessionCookieFound
    }

    func repairSavedSessionKey(account: String) async -> CredentialState {
        let identity = CredentialIdentity(provider: .claude, kind: .sessionKey)
        let checkedAt = Date()

        do {
            let existingValue = try await keychainRepository.retrieve(account: account)
            let sessionKey = try SessionKey(existingValue)

            _ = try await keychainRepository.repairClaudeSessionKey(sessionKey.value, account: account)

            return CredentialState(identity: identity, health: .valid, checkedAt: checkedAt)
        } catch is SessionKeyError {
            return CredentialState(
                identity: identity,
                health: .invalid,
                failureCategory: .invalidFormat,
                checkedAt: checkedAt
            )
        } catch KeychainError.notFound {
            return CredentialState(
                identity: identity,
                health: .missing,
                failureCategory: .missing,
                checkedAt: checkedAt
            )
        } catch is KeychainError {
            Self.logger.error("Claude session key repair failed with sanitized Keychain storage error")
            return CredentialState(
                identity: identity,
                health: .unavailable,
                failureCategory: .storageUnavailable,
                checkedAt: checkedAt
            )
        } catch {
            Self.logger.error("Claude session key repair failed with sanitized unknown error")
            return CredentialState(
                identity: identity,
                health: .unavailable,
                failureCategory: .unknown,
                checkedAt: checkedAt
            )
        }
    }

    private func browsers(for source: BrowserImportSource) -> [Browser] {
        switch source {
        case .defaultBrowser:
            if let defaultBrowser = defaultWebBrowser() {
                return [defaultBrowser] + browserImportOrder.filter { $0 != defaultBrowser }
            }
            return browserImportOrder
        case .chrome:
            return [.chrome]
        case .safari:
            return [.safari]
        case .brave:
            return [.brave]
        case .edge:
            return [.edge]
        case .arc:
            return [.arc]
        case .firefox:
            return [.firefox]
        }
    }

    private func defaultWebBrowser() -> Browser? {
        guard let url = URL(string: "https://example.com"),
              let appURL = NSWorkspace.shared.urlForApplication(toOpen: url),
              let bundleIdentifier = Bundle(url: appURL)?.bundleIdentifier else {
            return nil
        }

        switch bundleIdentifier {
        case "com.apple.Safari":
            return .safari
        case "com.google.Chrome":
            return .chrome
        case "com.brave.Browser":
            return .brave
        case "com.microsoft.edgemac":
            return .edge
        case "company.thebrowser.Browser":
            return .arc
        case "org.mozilla.firefox":
            return .firefox
        default:
            return nil
        }
    }

    private func importedSessionKey(from source: BrowserCookieStoreRecords) throws -> ImportedSessionKey? {
        guard let cookie = source.records.first(where: { $0.name == "sessionKey" }) else {
            return nil
        }

        let sessionKey = try SessionKey(cookie.value)
        return ImportedSessionKey(
            value: sessionKey.value,
            sourceDescription: source.label
        )
    }

    private func importedChatGPTSessionCookie(from source: BrowserCookieStoreRecords) -> ImportedChatGPTSessionCookie? {
        let cookieHeader = source.records
            .filter { record in
                isChatGPTSessionCookieName(record.name)
            }
            .sorted { lhs, rhs in
                chatGPTSessionCookieSortKey(lhs.name) < chatGPTSessionCookieSortKey(rhs.name)
            }
            .map { "\($0.name)=\($0.value)" }
            .joined(separator: "; ")

        let normalizedHeader = ChatGPTUsageService.cookieHeader(from: cookieHeader)
        guard !normalizedHeader.isEmpty else { return nil }

        return ImportedChatGPTSessionCookie(
            cookieHeader: normalizedHeader,
            sourceDescription: source.label
        )
    }

    private func isChatGPTSessionCookieName(_ name: String) -> Bool {
        chatGPTSessionCookieNames.contains { cookieName in
            name == cookieName || name.hasPrefix("\(cookieName).")
        }
    }

    private func chatGPTSessionCookieSortKey(_ name: String) -> Int {
        for cookieName in chatGPTSessionCookieNames {
            let prefix = "\(cookieName)."
            if name == cookieName {
                return -1
            }
            if name.hasPrefix(prefix), let index = Int(name.dropFirst(prefix.count)) {
                return index
            }
        }
        return -1
    }

    private var chatGPTSessionCookieNames: [String] {
        [
            "__Secure-next-auth.session-token",
            "__Secure-authjs.session-token",
        ]
    }
}

private extension Browser {
    var usesKeychainForCookieDecryption: Bool {
        switch self {
        case .safari, .firefox, .zen:
            return false
        case .chrome, .chromeBeta, .chromeCanary,
             .arc, .arcBeta, .arcCanary,
             .chatgptAtlas,
             .chromium,
             .yandex,
             .brave, .braveBeta, .braveNightly,
             .edge, .edgeBeta, .edgeCanary,
             .helium,
             .vivaldi,
             .dia,
             .comet:
            return true
        @unknown default:
            return true
        }
    }
}
