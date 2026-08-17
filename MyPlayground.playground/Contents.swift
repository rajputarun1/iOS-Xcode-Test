import Foundation

print("======================================")
print(" XCODE PLAYGROUND")
print("======================================")

let name = "Arun"

print("")
print("Hello, \(name)!")
print("")

let numbers = [10, 20, 30, 40, 50]

print("Numbers:")
print(numbers)

let sum = numbers.reduce(0, +)

print("")
print("Sum = \(sum)")

let squares = numbers.map {
    $0 * $0
}

print("")
print("Squares:")
print(squares)

print("")
print("Swift Playground is running on macOS.")
print("Xcode/Swift environment is working.")
print("")
print("======================================")
