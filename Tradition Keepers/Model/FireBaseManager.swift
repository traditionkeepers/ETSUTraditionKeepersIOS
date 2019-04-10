//
//  FirebaseWrapper.swift
//  Tradition Keepers
//
//  Created by Ryan Thally on 3/17/19.
//  Copyright © 2019 East Tennessee State Univeristy. All rights reserved.
//
import Foundation

@objc protocol FireBaseManager {
    func Push()
    func Fetch(completion: {} )
    @objc optional func LogIn()
    @objc optional func LogOut()
}
