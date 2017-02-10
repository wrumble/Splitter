//
//  WhiteSpaceNewLineTrimmingHelper.swift
//  Splitter
//
//  Created by Wayne Rumble on 07/02/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import Foundation

extension String
{
    func trim() -> String
    {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
