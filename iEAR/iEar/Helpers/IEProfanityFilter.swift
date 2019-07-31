//
//  ProfanityFilter.swift
//
// Copyright 2018 Adrian Bolinger
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the "Software"), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be included in all copies
// or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
// CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
// OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


import Foundation

// Usage:
// yourLabel.text = ProfanityFilter.cleanUp("your string")

class ProfanityFilter: NSObject {
    
  static func cleanUp(_ string: String) -> String {
    let dirtyWords = "\\b(fuck|fucker|stupid|idiot|fool|freak|sexy|useless|🖕)\\b"
    
    func matches(for regex: String, in text: String) -> [String] {
      
      do {
        let regex = try NSRegularExpression(pattern: regex)
        let results = regex.matches(in: text,
                                    range: NSRange(text.startIndex..., in: text))
        return results.compactMap {
          Range($0.range, in: text).map { String(text[$0]) }
        }
      } catch let error {
        print("invalid regex: \(error.localizedDescription)")
        return []
      }
    }
    
    let dirtyWordMatches = matches(for: dirtyWords, in: string)
    
    if dirtyWordMatches.count == 0 {
      return string
    } else {
      var newString = string
      
      dirtyWordMatches.forEach({ dirtyWord in
        let newWord = String(repeating: "🤬", count: dirtyWord.count)
        newString = newString.replacingOccurrences(of: dirtyWord, with: newWord, options: [.caseInsensitive])
      })
      
      return newString
    }
  }
}
