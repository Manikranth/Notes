# Go Lang:
------------

## Introduction

  Go is a new language. Although it borrows ideas from existing languages, it has unusual properties that make effective Go programs different in character from programs written in its relatives. A straightforward translation of a C++ or Java program into Go is unlikely to produce a satisfactory result—Java programs are written in Java, not Go. On the other hand, thinking about the problem from a Go perspective could produce a successful but quite different program. In other words, to write Go well, it's important to understand its properties and idioms. It's also important to know the established conventions for programming in Go, such as naming, formatting, program construction, and so on, so that programs you write will be easy for other Go programmers to understand.

  This document gives tips for writing clear, idiomatic Go code. It augments the language specification, the Tour of Go, and How to Write Go Code, all of which you should read first.




## Syntax:

  Go uses C-style syntax with semicolons optional at the end of statements.
  Variables are declared using the var keyword, followed by the variable name and its type. You can also use the short variable declaration syntax := to declare and initialize a variable in one line.
  Functions are declared with the func keyword, followed by the function name, parameters, and return type(s).
  Packages are imported using the import keyword, and package names are lowercase.

### **Data Structures:**

  **Arrays**: Fixed-size, indexed collections of elements of the same type.

  **Slices**: Dynamic-sized, indexed collections of elements of the same type. Slices are built on top of arrays.

  **Maps**: Unordered collections of key-value pairs, where keys are unique. Maps are created using the make function and the map keyword, followed by the key and value types.

  **Structs**: Custom data types that group together fields of different data types. Structs are defined using the type keyword, followed by the struct name and the struct keyword with the fields and their types inside curly braces.

### Control Structures:
  **If statements**: Conditional statements that execute a block of code if a specified condition is true. Go does not have a ternary operator like other languages.

  **For loops**: Go only has the for keyword for loops, which can be used in various ways, such as traditional for loops, while loops, and range loops.

  **Switch statement**s: Multi-branch selection statements that allow you to execute different blocks of code based on the value of a specified expression or condition. Go automatically breaks after each case, so there is no need for a break statement.

  **Defer, Panic, and Recover:** Go has built-in functions for managing resources and handling errors. defer is used to ensure that a function call is executed later in a program's execution, usually for cleanup purposes. panic stops the normal execution of the current goroutine and propagates the error up the call stack. recover is used to regain control of a panicking goroutine and resume normal execution.
  By familiarizing yourself with these aspects of Go, you'll have a solid foundation to build on when working with Go code and discussing the language in an interview setting.





Go's concurrency model is built around goroutines and channels, making it easier to write concurrent and parallel programs. Here's an overview:

### Goroutines:
A goroutine is a lightweight thread managed by the Go runtime. Goroutines run concurrently with other functions and have a lower overhead compared to traditional threads. To create a goroutine, simply use the go keyword followed by the function call.

**Example**:

```go

package main

import (
    "fmt"
    "time"
)

func printMessage(message string) {
    for i := 0; i < 5; i++ {
        fmt.Println(message)
        time.Sleep(1 * time.Second)
    }
}

func main() {
    go printMessage("Hello")
    go printMessage("World")
    time.Sleep(6 * time.Second) // Give enough time for goroutines to finish
}
```
In this example, we have two goroutines running concurrently, each printing a message five times with a one-second delay between prints.

### Channels:
Channels are a synchronization mechanism that allows you to pass data between goroutines safely. A channel is a typed conduit through which you can send and receive values with the channel operator <-.

**Example**:

```go

package main

import (
    "fmt"
    "time"
)

func sendToChannel(channel chan string) {
    for i := 0; i < 5; i++ {
        channel <- "Hello, World!"
        time.Sleep(1 * time.Second)
    }
    close(channel)
}

func main() {
    messages := make(chan string)

    go sendToChannel(messages)

    for message := range messages {
        fmt.Println(message)
    }
}
```
In this example, we create a channel named messages and a goroutine that sends "Hello, World!" to the channel five times. The main function reads from the channel and prints the received messages.


**When working with goroutines and channels, remember these key points:**

  - Goroutines are lightweight threads that are managed by the Go runtime.
  - Use the go keyword to create a goroutine.
  - Channels are used to communicate and synchronize between goroutines.
  - Use the make function to create a channel, and the channel operator <- to send and receive values.
  - Use close to close a channel when no more values will be sent on it.
















https://go.dev/tour/welcome/1
