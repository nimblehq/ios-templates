//
//  Constants.swift
//  __PROJECTNAME__
//
//  Created by Pirush Prechathavanich on 3/13/18.
//  Copyright © 2018 Nimbl3. All rights reserved.
//

struct Constants {
    
    struct Congifuration {
        
        #if PRODUCTION
        static let baseUrl = "https://"
        #elseif STAGING
        static let baseUrl = "http://"
        #elseif TESTING
        static let baseUrl = "http://"
        #endif
        
    }
    
}
