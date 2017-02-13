//
//  WhiteSpaceNewLineTrimmingHelper.swift
//  Splitter
//
//  Created by Wayne Rumble on 07/02/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import Foundation

//Remove any white spaces or new lines from the end of a string.
extension String
{
    func trim() -> String
    {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
