//
//  FileUtils.swift
//  NetBank
//
//  Created by Oszkó Tamás on 06/04/15.
//  Copyright (c) 2015 TamasO. All rights reserved.
//

import UIKit

class FileUtils: NSObject {

    class func documentsDirectory() -> String {
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! as String
        return path
    }
}
