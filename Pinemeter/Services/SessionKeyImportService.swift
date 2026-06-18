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
        let query = BrowserCookieQuery(domains: ["claude.ai"], domainMatch: .suffix)
        var sawAccessDenied = false
        var sawSafariAccessDenied = false
        var deniedKeychainBrowserName: String?

        for browser in browserImportOrder {
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
                Self.logger.debug("Browser cookie import failed for \(browser.displayName): \(error.localizedDescription)")
            } catch {
                Self.logger.debug("Browser cookie import failed for \(browser.displayName): \(error.localizedDescription)")
            }
        }

        if let deniedKeychainBrowserName {
            throw SessionKeyImportError.browserKeychainAccessDenied(deniedKeychainBrowserName)
        }
        if sawSafariAccessDenied {
            throw SessionKeyImportError.safariAccessDenied
        }
        if sawAccessDenied {
            throw SessionKeyImportError.accessDenied
        }
        throw SessionKeyImportError.noSessionKeyFound
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
