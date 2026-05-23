# iDar-BigNum

An efficient and flexible library for handling arbitrary-precision numbers in Lua, built for ComputerCraft: Tweaked.

## Table of Contents

- [Features](#features)
- [Getting started](#getting-started)
- [Usage](#usage)
- [FAQ](#faq)
- [Contributing](#contributing)
- [License](#license)

## Features

- **Optimized Backend:** High-performance arithmetic using a Base 2²⁶ backend — benchmarked on CC:Tweaked running secp256k1, public key generation dropped from ~5s to ~0.85s (~6x speedup over the previous Base 256 implementation).
- **Modern Object-Oriented API:** Uses metatables for clean, readable operations (e.g., `a + b`, `a % b`, `a ^ b`).
- **ComputerCraft Stable:** **Solves "too long without yielding" crashes** by correctly yielding in all heavy operations (`mul`, `div`, `modExp`, `sqrt`).
- **Full Cryptographic Support:** Built for cryptography with essential functions like `modExp`, `fromBytes`, `toBytes`, and `bitLength`.
- **Efficient Bitwise Operations:** Full set of bitwise functions (`band`, `bor`, `bxor`, `lshift`, `rshift`) operating efficiently on the Base 2²⁶ internal representation.
- **Arbitrary-precision arithmetic** for very large numbers.
- **Fast and efficient algorithms** (Knuth's division) for all core operations.
- **Built-in safety checks** for invalid operations (e.g., division by zero).

## Requirements

- Minecraft with the ComputerCraft: Tweaked mod installed
- Minecraft 1.21.1 or above (below 1.21.1, only God knows if it is compatible)
- Basic knowledge of Lua programming

## Getting Started

### Recommended Installation (via iDar-Pacman):

```lua
pacman -S idar-bignum
```

### Manual Installation:

1. Download the library files from the releases page
2. Place them in your ComputerCraft computer's `/Bignum/` directory
3. Use absolute paths to require the module

### Load the library:

```lua
local bignum = require("Bignum.bigNum")
```

## Usage

```lua
local bignum = require("Bignum.bigNum")
local ZERO = bignum("0")
local P = bignum("115792089237316195423570985008687907853269984665640564039457584007908834671663") -- secp256k1 P

-- Create bignum objects
local a = bignum("12345678901234567890")
local b = bignum("98765432109876543210")
local key = bignum(256)

-- Object-Oriented API
print("A + B = " .. (a + b))
print("A * B = " .. (a * b))

-- Cryptographic operations
local result = key:modExp(key + 1, P)
print("Key^257 mod P = " .. result)

-- Bitwise operations
local shifted = key:lshift(8)
print("256 << 8 = " .. shifted)
```

## FAQ

- **Q: What is the purpose of this library?**

  A: This library is designed to handle very large numbers with high precision in Lua, enabling arithmetic operations beyond the native limits of Lua's number type.

- **Q: What kind of operations does this library support?**

  A: The library supports all basic arithmetic operations (addition, subtraction, multiplication, division, modulus), as well as advanced operations such as **modular exponentiation** (`modExp`), **square roots** (`sqrt`), full **bitwise operations**, and **byte-to-number conversions** (`fromBytes`/`toBytes`).

- **Q: Is this library optimized for performance?**

  A: **Yes.** This version uses a Base 2²⁶ backend instead of the previous Base 256 implementation. The difference is significant: in real-world benchmarks running secp256k1 ECC on CC:Tweaked, secp256k1 public key generation went from ~5s down to ~0.85s — roughly a **6x speedup**. It is also optimized for ComputerCraft by solving all "too long without yielding" crashes, making it stable for heavy calculations.

- **Q: What is the maximum size of numbers that this library can handle?**

  A: The library can handle numbers limited only by available memory and system resources. Operations (including bitwise) are efficient even on very large numbers.

- **Q: Can I perform cryptographic operations using this library?**

  A: **Yes.** This library is ideal for cryptography. It provides the essential `modExp`, `fromBytes`, `toBytes`, and `bitLength` functions needed for key generation and ciphers, and is the required backend for `iDar-CryptoLib`.

- **Q: Can I contribute to this library?**

  A: Yes! Contributions are welcome. Submit pull requests with improvements, optimizations, or new features. Check the contribution guidelines in the repository before submitting.

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a new branch for your feature or fix
3. Submit a pull request with a clear description

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
