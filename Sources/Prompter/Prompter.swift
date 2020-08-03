//
//  Prompter
//
//  Created by Matthew on 11/01/2016.
//  Copyright © 2016 Matthew Clarkson. All rights reserved.
//

public typealias Choice = String
public typealias Choices = [Choice]
public typealias Index = Int
public typealias ChoiceInfo = (Index, Choice)
public typealias Block = (AnyObject) -> ()

/**
  Protocol for preconfiguring the prompt display style.
  Not really implemented (only default message)
 **/
public protocol PrompterStyle {
    var defaultMessage: String { get }
}

/**
 Prompt class

 **/
public class Prompter {

    public private(set) var defaultMessage: String = "Invalid response. Please try again."

    /**
     Initialize the prompt with a display style

     - parameter withStyle: PromptStyle

     **/
    convenience public init(withStyle style: PrompterStyle) {
        self.init()
        defaultMessage = style.defaultMessage
    }

    /**
     Asks a question that requires a `String` response. A valid response must be provided before the user can proceed.

     - parameter question:  The question to ask the user to respond to.
     - parameter message:   Optional message to override the default message if the response is invalid.
     - parameter block:     Optional block
     - returns:             String

     **/
    public func askString(question: String, message: String? = nil, block: Block? = nil) -> String {
        return ask(question, type: .String, message: message, block: block).value
    }

    /**
     Asks a question that requires an `Int` response. A valid response (i.e. an integer) must be provided before the user can proceed.

     - parameter question:  The question to ask the user to respond to.
     - parameter message:   Optional message to override the default message if the response is invalid.
     - parameter block:     Optional block
     - returns:             Integer

     **/
    public func askInt(question: String, message: String? = nil, block: Block? = nil) -> Int {
        return ask(question, type: .Int, message: message, block: block).value
    }

    /**
     Asks a question that requires a `Bool` response. A valid response that can be converted to a boolean must be provided before the user can proceed.

     - parameter question:  The question to ask the user to respond to.
     - parameter message:   Optional message to override the default message if the response is invalid.
     - parameter block:     Optional block
     - returns:             Boolean

     **/
    public func askBool(question: String, message: String? = nil, block: Block? = nil) -> Bool? {
        return ask(question, type: .Bool, message: message, block: block).value
    }

    /**
     Asks a multiple choice question that requires a single response (via entering an integer). A valid response must be provided.

     - parameter question:  The question to ask the user to respond to.
     - parameter choices:   An array of choices to present to the user.
     - parameter message:   Optional message to override the default message if the response is invalid.
     - parameter block:     Optional block
     - returns:             (Index, String) - The index of the selected choice and the choice as a string

     **/
    public func askSingleChoice(text: String, choices: Choices, message: String? = nil, block: Block? = nil) -> ChoiceInfo? {
        return ask(text, type: .SingleChoice(choices), message: message, block: block).value
    }
}

//MARK: - Private methods

extension Prompter {

    private func ask<T>(_ text: String, type: QuestionType<T>, message: String?, block: Block?) -> Result<T> {
        display(text, type: type)
        return input(type, message: message, block: block)
    }

    private func input<T>(_ type: QuestionType<T>, message: String?, block: Block?) -> Result<T> {
        let msg = message != nil ? message! : defaultMessage

        guard let data = readLine(strippingNewline: true) else {
            return invalidResponse(type, message: msg, block: block)
        }

        if let result = type.result(data) {
            block?(result.value as AnyObject)
            return result
        }

        return invalidResponse(type, message: msg, block: block)
    }

    private func invalidResponse<T>(_ type: QuestionType<T>, message: String, block: Block?) -> Result<T> {
        showMessage(message)
        return input(type, message: message, block: block)
    }

    private func display<T>(_ text: String, type: QuestionType<T>) {
        print(text)

        if let options = type.options {
            displayOptions(options)
        }
    }

    private func displayOptions(_ list: [String]) {
        list.enumerated().forEach { print("[\($0+1)] \($1) ") }
    }

    private func showMessage(_ text: String) {
        print("*** \(text) ***")
    }
}

//MARK: - Supporting

private struct Result<T> {
    let value: T

    init(value: T) {
        self.value = value
    }
}

private enum QuestionType<T> {
    case String, Int, Bool, SingleChoice(Choices)

    var options: Choices? {
        switch self {
        case .SingleChoice(let choices):    return choices
        default:                            return nil
        }
    }

    func result(_ input: Choice) -> Result<T>? {

        var result: T?

        switch self {
        case .String:       result = input as? T
        case .Int:          result =  input.int as? T
        case .Bool:         result = input.bool as? T
        case .SingleChoice:
            if let int = input.int, 
               let options = self.options, 
               let item = options.getAt(index: int - 1)
            {
                result = (int - 1, item) as? T
            }
        }

        return result != nil ?  Result(value: result!) : nil
    }
}
