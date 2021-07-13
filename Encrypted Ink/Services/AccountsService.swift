// Copyright © 2021 Encrypted Ink. All rights reserved.

import Foundation
import WalletCore

struct AccountsService {
    
    static func validateAccountInput(_ input: String) -> Bool {
        if Mnemonic.isValid(mnemonic: input) {
            return true
        } else if let data = Data(hexString: input) {
            return PrivateKey.isValid(data: data, curve: CoinType.ethereum.curve)
        } else {
            return false
        }
    }
    
    static func addAccount(input: String) -> Account? {
        let key: PrivateKey
        if Mnemonic.isValid(mnemonic: input) {
            key = HDWallet(mnemonic: input, passphrase: "").getKeyForCoin(coin: .ethereum)
        } else if let data = Data(hexString: input), let privateKey = PrivateKey(data: data) {
            key = privateKey
        } else {
            return nil
        }
        
        let address = CoinType.ethereum.deriveAddress(privateKey: key).lowercased()
        // TODO: use checksum address
        let account = Account(privateKey: key.data.hexString, address: address)
        var accounts = getAccounts()
        guard !accounts.contains(where: { $0.address == address }) else { return nil }
        accounts.append(account)
        Keychain.save(accounts: accounts)
        return account
    }
    
    static func removeAccount(_ account: Account) {
        var accounts = getAccounts()
        accounts.removeAll(where: {$0.address == account.address })
        Keychain.save(accounts: accounts)
    }
    
    static func getAccounts() -> [Account] {
        return Keychain.accounts
    }
    
    static func getAccountForAddress(_ address: String) -> Account? {
        let allAccounts = getAccounts()
        return allAccounts.first(where: { $0.address == address.lowercased() })
    }
    
}
