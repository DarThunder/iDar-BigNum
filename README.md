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

- **Optimized Backend:** High-performance arithmetic using a Base 256 (byte table) backend, significantly faster than Base 10 strings.
- **Modern Object-Oriented API:** Uses metatables for clean, readable operations (e.g., `a + b`, `a % b`, `a ^ b`).
- **ComputerCraft Stable:** **Solves "too long without yielding" crashes** by correctly yielding in all heavy operations (`mul`, `div`, `modExp`, `sqrt`).
- **Full Cryptographic Support:** Built for cryptography (like RSA) with essential functions like `modExp`, `fromBytes`, `toBytes`, and `bitLength`.
- **Efficient Bitwise Operations:** Full set of bitwise functions (`band`, `bor`, `bxor`, `lshift`, `rshift`) that operate efficiently on the new byte backend.
- **Arbitrary-precision arithmetic** for very large numbers.
- **Fast and efficient algorithms** (like Knuth's division) for all core operations.
- **Built-in safety checks** for invalid operations (e.g., division by zero).

## Requirements

- Minecraft with the ComputerCraft: Tweaked mod installed
- Minecraft 1.20.1 or above (Below 1.20.1, only God knows if it is compatible).
- Basic knowledge of Lua programming

## Getting Started

### Install in ComputerCraft:

1.  use this command in the terminal of the computer/pocket computer to use.

```lua
wget run https://raw.githubusercontent.com/DarThunder/iDar-BigNum/refs/heads/main/installer.lua
```

2.  wait of the installation process.

### Load the library:

1.  Use `require("idar-bn.bigNum")` to load the library into your ComputerCraft programs.

## Usage

```lua
local bignum = require("idar-bn.bigNum")
local ZERO = bignum("0")
local P = bignum("115792089237316195423570985008687907853269984665640564039457584007908834671663") -- secp256k1 P

-- Create bignum objects
local a = bignum("12345678901234567890")
local b = bignum("98765432109876543210")
local key = bignum(256)

-- Use the new Object-Oriented API
print("A + B = " .. (a + b))
print("A * B = " .. (a * b))

-- Essential Cryptography Operations (Fast & Yielding)
local result = key:modExp(key + 1, P)
print("Key^257 mod P = " .. result)

-- Bitwise Operations on Base 256
local shifted = key:lshift(8)
print("256 << 8 (bytes) = " .. shifted)
```

## FAQ

- Q: What is the purpose of this library?

- A: This library is designed to handle very large numbers with high precision in Lua, enabling you to perform arithmetic operations beyond the native limits of Lua's number type.

- Q: What kind of operations does this library support?

- A: The library supports all basic arithmetic operations (addition, subtraction, multiplication, division, modulus), as well as advanced operations such as **modular exponentiation** (`modExp` or `a:pow(e, m)`), **square roots** (`sqrt`), full **bitwise operations**, and **byte-to-number conversions** (`fromBytes`/`toBytes`).

- Q: Is this library optimized for performance?

- A: **Yes.** This version (v2.0+) has been re-architected for performance using a Base 256 backend. Most importantly, it is **optimized for ComputerCraft** by solving all "too long without yielding" crashes, making it stable for very large calculations.

- Q: What is the maximum size of numbers that this library can handle?

- A: The library can handle numbers limited only by the available memory and system resources. Operations (including bitwise) are efficient even on very large numbers.

- Q: Can I perform cryptographic operations using this library?

- A: **Yes.** This library is now **ideal for cryptography**. It was redesigned with RSA in mind, providing the essential `modExp`, `fromBytes`, `toBytes`, and `bitLength` functions needed for key generation and ciphers. It is the required backend for `iDar-CryptoLib`.

- Q: Can I contribute to this library?

- A: Yes! Contributions are welcome. You can submit pull requests with improvements, optimizations, or new features. Make sure to check the contribution guidelines in the repository before submitting.

## Contributing

Contributions are welcome! Please follow these steps:

1.  Fork the repository.
2.  Create a new branch for your feature or fix.
3.  Submit a pull request with a clear description.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
