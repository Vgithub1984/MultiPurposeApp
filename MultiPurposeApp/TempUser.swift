//
//  TempUser.swift
//  MultiPurposeApp
//
//  Created by Varun Patel on 7/29/25.
//

import Foundation

struct TempUser: Codable {
    let firstName: String
    let lastName: String
    let userId: String // This will be the email
    let password: String

    // Default user
    static let `default` = TempUser(
        firstName: "Vicky",
        lastName: "Patel",
        userId: "user@example.com",
        password: "Password123"
    )
}

