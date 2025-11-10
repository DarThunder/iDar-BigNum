# BigNum Library

A custom arbitrary-precision arithmetic library implemented in pure Lua, designed to handle very large integers for cryptographic operations in ComputerCraft environments.

## Overview

The BigNum library provides mathematical operations for integers of unlimited size, which is essential for implementing cryptographic algorithms like RSA and ECC that require numbers far beyond Lua's native number limits.

## Features

- **Arithmetic Operations**: Addition, subtraction, multiplication, division, modulus
- **Bitwise Operations**: AND, OR, XOR, left/right shifts
- **Modular Arithmetic**: Modular exponentiation (crucial for RSA)
- **Number Conversion**: Binary, decimal, and byte array conversions
- **Memory Efficient**: Uses base-256 internal representation
- **Optimized Algorithms**: Efficient division and multiplication

## Installation

```lua
local bignum = require("idar-bn.bigNum")
```

## Basic Usage

### Creating BigNums

```lua
-- From decimal string
local a = bignum("12345678901234567890")
local b = bignum("-98765432109876543210")

-- From number
local c = bignum(42)

-- From binary string
local d = bignum.fromBinary("1010101010101010")

-- From bytes
local e = bignum.fromBytes("Hello")

-- Zero and constants
local zero = bignum(0)
local one = bignum(1)
```

### Arithmetic Operations

```lua
local x = bignum("123456789")
local y = bignum("987654321")

-- Basic arithmetic
local sum = x + y
local diff = x - y
local product = x * y
local quotient = x / y
local remainder = x % y

-- Power and square root
local power = x ^ bignum(3)
local sqrt = x:sqrt()

-- Modular exponentiation (for RSA)
local mod_exp = x:modExp(y, z)
```

### Bitwise Operations

```lua
local a = bignum.fromBinary("1101")
local b = bignum.fromBinary("1011")

local and_result = a:band(b)    -- 1001
local or_result = a:bor(b)      -- 1111
local xor_result = a:bxor(b)    -- 0110

-- Shifts
local left_shift = a:lshift(2)  -- 110100
local right_shift = a:rshift(1) -- 110
```

### Conversion Methods

```lua
local num = bignum("123456789")

-- To string
print(tostring(num))  -- "123456789"
print(num:toString()) -- "123456789"

-- To bytes
local bytes = num:toBytes()

-- From bytes and back
local original = bignum.fromBytes(bytes)

-- Binary conversion
local bin_str = bignum.fromBinary("10101"):toString()
```

### Comparison Operations

```lua
local a = bignum("100")
local b = bignum("200")

print(a == b)  -- false
print(a < b)   -- true
print(a <= b)  -- true
print(a > b)   -- false
```

## Advanced Features

### Modular Arithmetic

```lua
-- Essential for RSA operations
local base = bignum("65537")
local exponent = bignum("123456789")
local modulus = bignum("999999999")

local result = base:modExp(exponent, modulus)
```

### Bit Length and Information

```lua
local num = bignum("123456789")
print(num:bitLength())  -- Number of bits required

-- Clone numbers
local copy = num:clone()
```

### Specialized Constructors

```lua
-- For cryptographic key generation
local random_large = bignum.fromBytes(random_bytes)

-- For binary operations
local bitmask = bignum.fromBinary("11110000")
```

## Internal Representation

The library uses a **base-256** digit system internally, making it efficient for:

- Cryptographic operations
- Byte-level manipulations
- Memory optimization

Each number is stored as:

- `sign`: 1 for positive, -1 for negative
- `digits`: Array of base-256 digits (least significant first)

## Performance Considerations

- **Division/Multiplication**: Most computationally expensive operations
- **Memory Usage**: Grows with number size, but optimized for base-256
- **Cryptographic Use**: Highly optimized for modular exponentiation (RSA)
- **ComputerCraft**: Includes `os.sleep(0)` in long operations to prevent timeouts

## Use in Cryptography

This library enables all cryptographic operations in iDar-CryptoLib:

```lua
-- RSA key generation and operations
local p = bignum(large_prime)
local q = bignum(another_large_prime)
local n = p * q  -- RSA modulus

-- Modular exponentiation for encryption/decryption
local encrypted = message:modExp(e, n)
local decrypted = encrypted:modExp(d, n)

-- ECC operations
local private_key = bignum.randomLargeNumber()
local public_key = base_point * private_key
```

## Limitations

- **Performance**: Pure Lua implementation, slower than native bignum libraries
- **ComputerCraft**: Limited by Lua VM performance in Minecraft
- **Memory**: Large numbers consume significant memory

## Examples

### 1. **Financial Calculations**

```lua
local bignum = require("bigNum")

-- Large currency calculations (avoid floating-point errors)
local salary = bignum("7500000000000000")  -- 7.5 trillion
local tax_rate = bignum("325")  -- 32.5% as integer (325/1000)
local tax_amount = (salary * tax_rate) / bignum("1000")
local net_salary = salary - tax_amount

print("Tax: " .. tostring(tax_amount))
print("Net: " .. tostring(net_salary))

-- Interest compounding
local principal = bignum("1000000000000")  -- 1 trillion
local rate = bignum("105")  -- 10.5% as integer
local years = 50

local final_amount = principal * (bignum("100") + rate) ^ years / (bignum("100") ^ years)
print("After " .. years .. " years: " .. tostring(final_amount))
```

### 2. **Scientific Computing & Large Numbers**

```lua
-- Astronomical calculations
local light_speed = bignum("299792458")  -- m/s
local seconds_in_year = bignum("31557600")
local light_year = light_speed * seconds_in_year

print("One light year: " .. tostring(light_year) .. " meters")

-- Large factorials
function factorial(n)
    local result = bignum(1)
    for i = 2, n do
        result = result * bignum(i)
        if i % 10 == 0 then os.sleep(0) end  -- Yield for large numbers
    end
    return result
end

local fact_100 = factorial(100)
print("100! = " .. tostring(fact_100))

-- Combinatorics: "How many possible lottery combinations?"
local function combinations(n, k)
    return factorial(n) / (factorial(k) * factorial(n - k))
end

local lottery_combinations = combinations(50, 6)
print("50 choose 6 = " .. tostring(lottery_combinations))
```

### 3. **Game Development & Statistics**

```lua
-- Large score tracking
local player_score = bignum("9999999999999999999")
local bonus_points = bignum("1234567890123456789")
local new_score = player_score + bonus_points

print("New score: " .. tostring(new_score))

-- Probability calculations
function binomial_probability(trials, successes, prob_success)
    local prob = bignum(prob_success)  -- As integer percentage
    local combos = combinations(trials, successes)
    local prob_term = (prob ^ successes) * ((bignum(100) - prob) ^ (trials - successes))
    return (combos * prob_term) / (bignum(100) ^ trials)
end

-- Chance of getting 7 heads in 10 coin flips
local prob = binomial_probability(10, 7, 50)
print("Probability: " .. tostring(prob) .. "%")
```

### 4. **Data Processing & ID Generation**

```lua
-- Large unique ID generation
local current_id = bignum("18446744073709551615")  -- Max uint64
local new_id = current_id + bignum(1)

print("New ID: " .. tostring(new_id))

-- Bitmask operations for permissions systems
local USER_READ = bignum.fromBinary("0001")
local USER_WRITE = bignum.fromBinary("0010")
local USER_EXECUTE = bignum.fromBinary("0100")
local USER_ADMIN = bignum.fromBinary("1000")

local user_permissions = USER_READ:bor(USER_WRITE)

function has_permission(user_perm, required_perm)
    return user_perm:band(required_perm) == required_perm
end

print("Can user read? " .. tostring(has_permission(user_permissions, USER_READ)))
print("Can user execute? " .. tostring(has_permission(user_permissions, USER_EXECUTE)))
```

### 5. **File Size & Data Management**

```lua
-- Large file size calculations
local bytes_in_gb = bignum("1073741824")  -- 2^30
local database_size_gb = bignum("5000")
local total_bytes = database_size_gb * bytes_in_gb

print("Database size: " .. tostring(total_bytes) .. " bytes")

-- Data transfer time estimation
local network_speed = bignum("100000000")  -- 100 Mbps in bits/sec
local transfer_time_seconds = (total_bytes * bignum(8)) / network_speed
local transfer_time_hours = transfer_time_seconds / bignum(3600)

print("Transfer time: " .. tostring(transfer_time_hours) .. " hours")
```

### 6. **Mathematics & Number Theory**

```lua
-- Fibonacci sequence with large numbers
function fibonacci(n)
    if n <= 1 then return bignum(n) end
    local a, b = bignum(0), bignum(1)
    for i = 2, n do
        a, b = b, a + b
        if i % 100 == 0 then os.sleep(0) end
    end
    return b
end

local fib_200 = fibonacci(200)
print("Fibonacci(200) = " .. tostring(fib_200))

-- Greatest Common Divisor (using your internal gcd)
function gcd(a, b)
    a, b = bignum(a), bignum(b)
    while b ~= bignum(0) do
        a, b = b, a % b
    end
    return a
end

local result = gcd("12345678901234567890", "98765432109876543210")
print("GCD = " .. tostring(result))
```

### 7. **Serialization & Data Storage**

```lua
-- Convert large numbers to compact byte representation
local huge_number = bignum("123456789012345678901234567890")
local byte_representation = huge_number:toBytes()
local reconstructed = bignum.fromBytes(byte_representation)

print("Original: " .. tostring(huge_number))
print("Reconstructed: " .. tostring(reconstructed))
print("Bytes used: " .. #byte_representation)

-- Efficient storage of large configuration values
local config = {
    max_users = bignum("1000000000000"),
    max_storage_bytes = bignum("1000000000000000000"),
    start_timestamp = bignum("1704067200000")  -- Unix timestamp in milliseconds
}
```

### 8. **Education & Learning Tool**

```lua
-- Demonstrate number theory concepts
function is_even(n)
    return (bignum(n) % bignum(2)) == bignum(0)
end

function is_power_of_two(n)
    local num = bignum(n)
    return num:band(num - bignum(1)) == bignum(0) and num ~= bignum(0)
end

local test_num = bignum("1099511627776")  -- 2^40
print(tostring(test_num) .. " is even: " .. tostring(is_even(test_num)))
print(tostring(test_num) .. " is power of two: " .. tostring(is_power_of_two(test_num)))
```

## Why Use BigNum Over Native Numbers?

| Use Case                        | Native Lua Numbers    | BigNum Library             |
| ------------------------------- | --------------------- | -------------------------- |
| Financial calculations          | Floating-point errors | **Exact precision**        |
| Large IDs (> 2^53)              | Lose precision        | **Perfect accuracy**       |
| Bit operations on large numbers | Limited to 32 bits    | **Unlimited bits**         |
| Scientific computing            | Limited range         | **Arbitrary size**         |
| Educational purposes            | Opaque internals      | **Transparent operations** |
