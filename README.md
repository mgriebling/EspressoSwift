# Espresso Swift

Espresso Swift provides a simple Swift interface to the **Espresso** logic
simplifier. I've provided a very basic initializer to the **Espresso** C-based
library to give Swift users the ability to use **Espresso** in their
programs. Basically, I capture the **Espresso** outputs in a file and
then return this text to the user. Inputs can come from an **Espresso**-compatible
user-supplied file or a set of name and input/output vectors. Have a look
at the [documentation](espresso5.pdf)

## Features

1. Runs the Berkeley Version 2.3 of **Espresso** with some minor changes
   to allow me to capture the text output.
2. Works on MacOS or iOS.

## Installation

In your project's Package.swift file add a dependency like:

```
dependencies: [
  .package(url: "https://github.com/mgriebling/Espresso.git", from: "0.0.1"),
]
```

## Usage

Here are a few examples of to how to use this package:

```swift
	let vector = [
	"0000 1111 110",
	"0001 0110 000",
	"0010 1101 101",
	"0011 1111 001",
	"0100 0110 011",
	"0101 1011 011",
	"0110 1011 111",
	"0111 1110 000",
	"1000 1111 111",
	"1001 1111 011",
	"1010 ---- ---",
	"1011 ---- ---",
	"1100 ---- ---",
	"1101 ---- ---",
	"1110 ---- ---",
	"1111 ---- ---"]

	input = vector.joined(separator: "\n")
	let inputs = ["A", "B", "C", "D"]
	let outputs = ["a", "b", "c", "d", "e", "f", "g"]
	if let espresso = Espresso(inputs, outputs, vector, [.exact, .useNames]) {
		results = espresso.results
	}
```

to produce the following output:

```
```





