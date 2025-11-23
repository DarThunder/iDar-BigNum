# Changelog

## Beta

### v1.0.0

- Initial release of the `bigNum` library.
- Added support for arbitrary-precision arithmetic, handling numbers up to 2^4096.
- Implemented fast exponentiation (`fastExp`) for efficient large power calculations.
- Added basic arithmetic operations: addition, subtraction, multiplication, and division for large numbers.
- Optimized for Lua and ComputerCraft environments with string-based number handling.
- Provided a simple API for handling large integers with minimal complexity.
- Included basic error handling for invalid operations (e.g., division by zero).
- Improved performance for number computations, with emphasis on large number support.

### v1.0.1

#### Changes

- Added support for handling negative numbers in basic operators (`add`, `sub`, `mul`, `div`).
- Fixed the generation of the `mod` operator, which was adding leading zeros.
- Improved overall performance.

#### Notes

Definitely, I never thought that creating and maintaining a big number library would be so complicated. Despite some issues with operating on large numbers, the project is going great. I hope to improve the algorithms I'm using in the coming weeks and address some pending details. Thanks for the support and for using this library!

### v2.0.0

#### Changes

- **Total Re-architecture (Base 256):** The library has been rewritten from the ground up. The internal engine no longer uses Base 10 strings; it now uses byte tables (`BASE = 256`). This provides a massive performance boost, especially for cryptographic operations.
- **Object-Oriented API:** Replaced the purely functional style (e.g., `bigNum.add(a, b)`) with a `bignum(n)` constructor that uses metatables for operations (`a + b`, `a % b`, `a < b`, etc.).
- **Crypto Support:** Added new functions essential for RSA and other algorithms: `fromBytes`, `toBytes`, `fromBinary`, `bitLength`, and `modExp`.
- **Bitwise Operations:** Implemented `band`, `bor`, `bxor`, `blshift`, and `brshift`, all optimized for the new Base 256 architecture.

#### Fixes/Improvements

- **Fixed "Too Long Without Yielding" Crashes!** Added `os.sleep(0)` yields to all computationally intensive operations (`modExp`, `mul_abs`, `divmod_abs`, `sqrt`). The library can now handle 256-bit operations (and larger) without being killed by the ComputerCraft watchdog.
- **Optimized Algorithms:** Replaced the slow, repeated-subtraction division algorithm with a fast, Knuth-style long division, dramatically improving `div` and `mod` speed.
- **Prime Generation:** Optimized `sqrt` to yield, allowing the prime-finding functions in `rsa.lua` to run without freezing.

Notes
This is "Beta 2"! It's a fundamental rewrite focused on stability and performance.

This version **solves the "Known Issue"** from [iDar-CryptoLib](https://github.com/DarThunder/iDar-CryptoLib). The bottleneck that limited RSA to 32 bits has been eliminated. [iDar-BigNum](https://github.com/DarThunder/iDar-BigNum) now supports the generation and operation of much larger RSA keys.

### v2.0.1

#### Added

- **Package Manager Support:** Added `manifest.lua` to enable direct installation and dependency resolution via **iDar-Pacman**.
