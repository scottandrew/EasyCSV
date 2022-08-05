import Foundation

typealias LineIterator = AsyncLineSequence<URL.AsyncBytes>.AsyncIterator

public struct EasyCSV: AsyncSequence, AsyncIteratorProtocol {
    public typealias Element = Line
    
    private let url: URL
    private var lineIterator: LineIterator
    private let seperator: Character
    private let quoteCharacter: Character = "\""
    private var lineNumber = 0
    
    init(url: URL, seperator: Character = ",") {
        self.url = url
        self.seperator = seperator
        self.lineIterator = url.lines.makeAsyncIterator()
    }
    
    public mutating func next() async throws -> Line? {
        if let string = try await lineIterator.next() {
            defer { lineNumber += 1 }
            return Line(
                lineNumber: lineNumber,
                data: split(line: string)
            )
        }
        
        return  nil
    }
    
    public func makeAsyncIterator() -> EasyCSV {
        return self
    }
    
    private func split(line: String) -> [String?] {
        var data = [String?]()
        var inQuote = false
        var currentString = ""
        
        for character in line {
            switch character {
            case quoteCharacter:
                inQuote = !inQuote
                continue
                
            case seperator:
                if (!inQuote) {
                    data.append(currentString.isEmpty ? nil : currentString)
                    currentString = ""
                    continue
                }
                break;
                
            default:
                break;
            }
            
            currentString.append(character)
        }
        
        data.append(currentString.isEmpty ? nil : currentString)
        
        return data
    }
}
