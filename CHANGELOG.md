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
