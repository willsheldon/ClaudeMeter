import Foundation
@testable import Pinemeter

actor SessionKeyImportServiceStub: SessionKeyImportServiceProtocol {
    let result: Result<ImportedSessionKey, Error>
    let repairState: CredentialState

    init(
        result: Result<ImportedSessionKey, Error>,
        repairState: CredentialState = CredentialState(
            identity: CredentialIdentity(provider: .claude, kind: .sessionKey),
            health: .valid
        )
    ) {
        self.result = result
        self.repairState = repairState
    }

    func importSessionKey() async throws -> ImportedSessionKey {
        switch result {
        case .success(let imported):
            return imported
        case .failure(let error):
            throw error
        }
    }

    func repairSavedSessionKey(account: String) async -> CredentialState {
        repairState
    }
}
