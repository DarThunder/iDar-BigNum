# iDar-BigNum
An efficient and flexible library for handling arbitrary-precision numbers in Lua.

## Table of Contents
- [Features](#features)
- [Getting started](#getting-started)
- [Usage](#usage)
- [FAQ](#faq)
- [Contributing](#contributing)
- [License](#license)

## Features
- RSA encryption and decryption (WIP)
- AES block cipher implementation
- SHA-256 hashing algorithm
- Lightweight and optimized for ComputerCraft: Tweaked
- Modular and extensible design

## Requirements
- Minecraft with the ComputerCraft: Tweaked mod installed
- Minecraft 1.20.1 or above (Below 1.20.1, only God knows if it is compatible).
- Basic knowledge of Lua programming

## Getting Started
### Install in ComputerCraft:
  1. use this command in the terminal of the computer/pocket computer to use.
```lua
wget run https://raw.githubusercontent.com/DarThunder/iDar-BigNum/refs/heads/main/installer.lua
```
  2. wait of the installation process.

### Load the library:
  1. Use require("idar-bn") to load the library into your ComputerCraft programs.

## Usage
```lua
local bigNum = require("idar-bn.bigNum")
local num = "2"

local bigger = bigNum.fastExp(num, "255")
print(bigger) -- a really big number
```
## FAQ
- Q: What is the purpose of this library?
- A: This library is designed to handle very large numbers with high precision in Lua, enabling you to perform arithmetic operations beyond the native limits of Lua's number type.

- Q: What kind of operations does this library support?
- A: The library supports basic arithmetic operations (addition, subtraction, multiplication, division), as well as advanced operations such as exponentiation, modular arithmetic, and square roots for extremely large numbers.

- Q: Is this library optimized for performance?
- A: While the library is designed for precision and can handle very large numbers efficiently, keep in mind that performance may vary depending on the size of the numbers being processed. Optimization is ongoing, and future versions will focus on improving speed without compromising accuracy.

- Q: What is the maximum size of numbers that this library can handle?
A: The library can handle numbers up to 2^4096(a tip: don't use bitwise operations with such large numbers — it won't work!), limited only by the available memory and system resources. It uses strings to represent large numbers, which allows it to handle very large values with high precision.

- Q: Can I perform cryptographic operations using this library?
- A: While the library is not specifically designed for cryptography, its precision and support for large integers make it suitable for use in cryptographic algorithms that require high-precision arithmetic, such as RSA and Diffie-Hellman/ECDHE.

- Q: How accurate are the calculations in this library?
- A: The library offers arbitrary precision, meaning calculations are only limited by the memory and system resources available. You can perform calculations with a high degree of accuracy, suitable for financial applications, scientific computing, and cryptographic operations.

Q: Can I contribute to this library?
A: Yes! Contributions are welcome. You can submit pull requests with improvements, optimizations, or new features. Make sure to check the contribution guidelines in the repository before submitting.

## Contributing
Contributions are welcome! Please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or fix.
3. Submit a pull request with a clear description.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
